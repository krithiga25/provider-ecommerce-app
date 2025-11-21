from pymongo import MongoClient
from langchain.docstore.document import Document
from langchain.text_splitter import RecursiveCharacterTextSplitter
#new:
#from langchain.embeddings import HuggingFaceInferenceAPIEmbeddings
from langchain_community.llms import HuggingFaceHub
from langchain.chains import RetrievalQA
from langchain_community.vectorstores import FAISS

# from langchain_community.llms import HuggingFaceHubRetriever 
# from langchain.chains.qa import RetrievalQA
# from langchain.models import FlanModel
from transformers import AutoModel, AutoTokenizer, AutoModelForSeq2SeqLM
import faiss
import numpy as np

# Connect to MongoDB
client = MongoClient("mongodb+srv://krithiperu2002:Shiroboy123@clusterapp.bbvbt.mongodb.net/")
db = client["ecomdb"]
collection = db["products"]

# Fetch and format documents
docs = []
for item in collection.find():
    content = f"Product Name: {item['productName']}\nDescription: {item['description']}\nPrice: ₹{item['price']}"
    docs.append(Document(page_content=content))

# Chunk the documents
splitter = RecursiveCharacterTextSplitter(chunk_size=500, chunk_overlap=50)
chunks = splitter.split_documents(docs)
# print("\nChunks:")
# for chunk in chunks:
#     print(chunk.page_content)

#embeddings:
# embeddings = HuggingFaceInferenceAPIEmbeddings(
#     api_key = HF_token,model_name = "BAAI/bge-base-en-v1.5"
# )

model_name = "sentence-transformers/all-MiniLM-L6-v2"
model = AutoModel.from_pretrained(model_name)
tokenizer = AutoTokenizer.from_pretrained(model_name)

# Define a function to embed a chunk
def embed_chunk(chunk):
    inputs = tokenizer(chunk, return_tensors="pt")
    outputs = model(**inputs)
    embeddings = outputs.pooler_output.detach().numpy()[0]
    return embeddings

# Initialize the Faiss index
index = faiss.IndexFlatL2(384)  # 128 is the dimensionality of the embeddings
# Embed the chunks and add to the Faiss index
for chunk in chunks:
    embedding = embed_chunk(chunk.page_content)
    index.add(embedding.reshape(1, -1))  # reshape to (1, 128) for Faiss
# Print the number of vectors in the index
print("Number of vectors in the index:", index.ntotal)
# faiss.write_index(index, "faiss_index.ivf")

def retrieve_chunks(query, model, tokenizer, index, chunks, top_k=5):
    inputs = tokenizer(query, return_tensors="pt")
    outputs = model(**inputs)
    query_embedding = outputs.pooler_output.detach().numpy()[0]
    D, I = index.search(query_embedding.reshape(1, -1), top_k)
    retrieved = [chunks[i].page_content for i in I[0]]
    return retrieved

def build_prompt(retrieved_chunks, query):
    context = "\n".join(retrieved_chunks)
    #prompt = f"Context:\n{context}\n\nQuestion: {query}\nAnswer:"
    prompt = f"""
    You are a helpful shopping assistant.

    Context:
    {context}

    Question: {query}

    Please provide a detailed and helpful answer based on the context above.
    """
    return prompt


flan_tokenizer = AutoTokenizer.from_pretrained("google/flan-t5-base")
flan_model = AutoModelForSeq2SeqLM.from_pretrained("google/flan-t5-base")

def generate_answer(prompt):
    inputs = flan_tokenizer(prompt, return_tensors="pt", truncation=True)
    outputs = flan_model.generate(**inputs, max_length=300)
    answer = flan_tokenizer.decode(outputs[0], skip_special_tokens=True)
    return answer

query = "What are the best headphones under ₹2000?"
retrieved = retrieve_chunks(query, model, tokenizer, index, chunks)
prompt = build_prompt(retrieved, query)
answer = generate_answer(prompt)

print("Answer:", answer)
