import redis
import json
import time
import hashlib
import numpy as np
from langchain_huggingface import HuggingFaceEmbeddings

redis_client = redis.Redis(host="localhost", port=6379, db=0)

def make_hash(query, context=""):
    raw = query + "|" + context
    return hashlib.sha256(raw.encode()).hexdigest()

def embed(text):
    model = HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2")
    vector = model.embed_query(text)
    return vector

def exact_cache_get(query):
    key = f"exact:{make_hash(query)}"
    print(f"[CACHE GET] Key: {key}")
    value = redis_client.get(key)
    if value:
        return json.loads(value)
    return None

def exact_cache_set(query, answer, category):
    key = f"exact:{make_hash(query)}"
    redis_client.set(key, json.dumps({"category": category, "answer": answer}))
    print(f"[CACHE SET] Key: {key}")

SEMANTIC_META_PREFIX = "semantic:meta:"
SEMANTIC_ANSWER_PREFIX = "semantic:answer:"


def semantic_cache_set(query, answer, category):
    # Generate deterministic key (hash of query text)
    key = make_hash(query)
    
    # Create metadata
    metadata = {
        "query": query,
        "embedding": embed(query),    # store vector
        "timestamp": time.time()
    }

    # Save metadata
    redis_client.set(
        SEMANTIC_META_PREFIX + key,
        json.dumps(metadata)
    )

    # Save corresponding answer
    redis_client.set(
        SEMANTIC_ANSWER_PREFIX + key,
        json.dumps({"category": category, "answer": answer})
    )

    print(f"[SEM-CACHE SET] Key: {key}")
    return key

def cosine_similarity(v1, v2):
    v1 = np.array(v1)
    v2 = np.array(v2)
    return np.dot(v1, v2) / (np.linalg.norm(v1) * np.linalg.norm(v2))

def semantic_cache_get(query, threshold=0.80):
    # Embed the new incoming query
    new_vec = embed(query)

    # Fetch all metadata keys
    keys = redis_client.keys(SEMANTIC_META_PREFIX + "*")

    if not keys:
        print("[SEM-CACHE MISS] No semantic metadata stored.")
        return None

    best_key = None
    best_score = -1

    # Check similarity with each stored metadata
    for key in keys:
        raw = redis_client.get(key)
        metadata = json.loads(raw)

        stored_vec = metadata["embedding"]
        similarity = cosine_similarity(new_vec, stored_vec)

        print(f"[SEM-CACHE CHECK] {metadata['query']} → sim={similarity:.3f}")

        if similarity >= threshold and similarity > best_score:
            best_score = similarity
            best_key = key

    # No match found
    if not best_key:
        print("[SEM-CACHE MISS] No embedding passed threshold.")
        return None
    best_key_str = best_key.decode("utf-8")       # convert bytes → str
    hashed_key = best_key_str.replace(SEMANTIC_META_PREFIX, "")
    answer_raw = redis_client.get(SEMANTIC_ANSWER_PREFIX + hashed_key)
    print(f"[SEM-CACHE HIT] {best_key} with sim={best_score:.3f}")
    return json.loads(answer_raw)

def clear_cache():
    patterns = ["exact:*", "semantic:meta:*", "semantic:answer:*"]

    for pattern in patterns:
        keys = redis_client.keys(pattern)
        if keys:
            redis_client.delete(*keys)
            print(f"Deleted {len(keys)} keys for pattern {pattern}")
        else:
            print(f"No keys found for {pattern}")