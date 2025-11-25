import json
import os
import re
from dotenv import load_dotenv
from langgraph.graph import StateGraph, END, START
from typing import TypedDict, Optional
#from langchain.tools import ToolNode
#from langgraph.nodes import LLMNode
#from langgraph.checkpoint.memory import MemorySaver
from langgraph.checkpoint.memory import MemorySaver
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_community.vectorstores import FAISS
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_core.documents import Document
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain.retrievers import EnsembleRetriever, BM25Retriever
from langchain_community.document_loaders import PyPDFLoader
from pymongo import MongoClient
from sentence_transformers import CrossEncoder
import google.generativeai as genai
from langgraph.prebuilt import ToolNode, tools_condition
from langgraph.checkpoint.redis import RedisSaver
from redis import Redis

load_dotenv()
api_key = os.environ.get("GEMINI_API_KEY")
genai.configure(api_key=api_key)
#memory = MemorySaver()
redis_client = Redis(host="localhost", port=6379, db=1)
checkpointer = RedisSaver(
    redis_client = redis_client,
    #namespace="rag-mem:"
)
#checkpointer.setup()

from redis_cache import (
    exact_cache_get, exact_cache_set, semantic_cache_get, semantic_cache_set, clear_cache
)
def load_product_data():
    client = MongoClient("mongodb+srv://krithiperu2002:Shiroboy123@clusterapp.bbvbt.mongodb.net/")
    db = client["ecomdb"]
    collection = db["products"]

    docs = []
    for item in collection.find():
        content = f"Product ID: {item['id']}\nProduct category: {item['category']}\nProduct Name: {item['productName']}\nDescription: {item['description']}\nPrice: ₹{item['price']}\nRating: ₹{item['rating']}"
        docs.append(Document(page_content=content))
    return docs

def build_vectorstore(index_path: str = "vectorstores/faiss_index"):
    os.makedirs(os.path.dirname(index_path), exist_ok=True)
    embeddings = HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2")
    docs = load_product_data()
    splitter = RecursiveCharacterTextSplitter(chunk_size=500, chunk_overlap=50)
    split_docs = splitter.split_documents(docs)
    if os.path.exists(index_path):
        print(f"FAISS index already exists at {index_path}, skipping save.")
        try:
            vectorstore = FAISS.load_local(index_path, embeddings, allow_dangerous_deserialization=True)
            return vectorstore, split_docs
        except Exception as e:
            print(f"Error loading FAISS index: {e}. Rebuilding vector store...")
            pass
    print("Building vector store ...")
    os.makedirs(os.path.dirname(index_path), exist_ok=True)
    vectorstore = FAISS.from_documents(split_docs, embeddings)
    vectorstore.save_local(index_path)
    return vectorstore, split_docs

def faq_vectorstore(
    pdf_path: str,
    index_path: str = "vectorstores/faq_faiss_index"
):
    os.makedirs(os.path.dirname(index_path), exist_ok=True)
    embeddings = HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2")
    loader = PyPDFLoader(pdf_path)
    documents = loader.load()
    print(f"Loaded {len(documents)} pages. Splitting text...")
    text_splitter = RecursiveCharacterTextSplitter(
        chunk_size=1000,
        chunk_overlap=150,
        length_function=len,
        separators=["\n\n", "\n", ".", "!", "?"]
    )
    chunks = text_splitter.split_documents(documents)
    if os.path.exists(index_path):
        print(f"Loading existing FAISS index from {index_path}")
        vectorstore = FAISS.load_local(index_path, embeddings, allow_dangerous_deserialization=True)
        return vectorstore, chunks
    if not os.path.exists(pdf_path):
        raise FileNotFoundError(f"PDF not found at: {pdf_path}")
    vectorstore = FAISS.from_documents(chunks, embeddings)
    #os.makedirs(os.path.dirname(index_path), exist_ok=True)
    print(f"Saving FAISS index to {index_path}")
    vectorstore.save_local(index_path)
    print("FAISS index built and saved successfully.")
    return vectorstore, chunks

llm = ChatGoogleGenerativeAI(
    model="gemini-2.0-flash",
    google_api_key=os.environ["GEMINI_API_KEY"],
    temperature=0.1
)

def retrieve_context(state, vectorstore, docs, k=3):
    query = state["query"]
    query_category = state["category"]
    print(f"Query category: {query_category}")
    if query_category == "products":
        product_category = detect_category(query)
        filtered_docs = [
            d for d in docs
            if f"Product category: {product_category}" in d.page_content
            ]
        if not filtered_docs:
            filtered_docs = docs
    bm25_retriever = BM25Retriever.from_documents(docs if query_category != "products" else filtered_docs)
    semantic_retriever = vectorstore.as_retriever(search_kwargs={"k": 3})
    hybrid_retriever = EnsembleRetriever(
        retrievers=[bm25_retriever, semantic_retriever],
        weights=[0.3, 0.7]
    )
    retrieved_docs = hybrid_retriever.invoke(query)
    reranked_docs = rerank_with_cross_encoder(query, retrieved_docs, top_n=3)
    context = "\n".join([d.page_content for d in reranked_docs])
    return reranked_docs, context
    # a normal search:
    #docs = vectorstore.similarity_search(query)
    # context = "\n".join([d.page_content for d in docs])
    # return context

def rerank_with_cross_encoder(query, docs, model_name="cross-encoder/ms-marco-MiniLM-L-6-v2", top_n=3):
    model = CrossEncoder(model_name)
    pairs = [(query, d.page_content) for d in docs]
    scores = model.predict(pairs)
    ranked_results = sorted(zip(docs, scores), key=lambda x: x[1], reverse=True)
    top_docs = [doc for doc, _ in ranked_results[:top_n]]
    return top_docs

def classify_query(query):
    """
    Classify the user query into one of six e-commerce-related categories using Gemini.
    """
    classification_prompt = f"""
    You are an intent classification assistant for an e-commerce AI chatbot.
    Classify the user query into one of the following categories:
    1. products – Questions about product details, availability, prices, or comparisons.
    2. general – Informative questions about shopping or technology (e.g., "things to consider before buying a laptop").
    3. irrelevant – Personal or unrelated queries (e.g., "do you know me", "what’s your favourite movie").
    4. faq_orders_returns_shipping – General FAQ queries related to the orders, shipping (e.g., "how to track my orders?", "how to return a product?", "what are the shipping options", "where i can contact the support team?").
    5. faq_payment_methods - General FAQ queries related to payment methods, billing, invoices (e.g., "what payment methods are accepted?", "how to get a copy of my invoice?", "is cash on delivery available?").
    6. faq_account_settings - General FAQ queries related to account settings, privacy, security (e.g., "how to change my account settings?", "how do you handle my data privacy?", "how to enable two-factor authentication?").
    7. customer_service - Queries related to customer support, complaints, feedback (e.g., "how to contact customer service?", "I want to file a complaint", "how to provide feedback on my shopping experience?").
    
    Output strictly in JSON format:
    {{
      "category": "<category_name>",
      "reason": "<brief explanation>"
    }}

    Query: "{query}"
    """

    model = genai.GenerativeModel("gemini-2.0-flash")
    response = model.generate_content(classification_prompt)
    text = response.text.strip()

    json_match = re.search(r'\{.*\}', text, re.DOTALL)
    if json_match:
        try:
            result = json.loads(json_match.group())
        except json.JSONDecodeError:
            result = {"category": "unknown", "reason": "Failed to parse JSON"}
    else:
        result = {"category": "unknown", "reason": "No JSON found"}

    return result.get("category", "unknown").lower()

CATEGORIES = ["clothes", "accessories", "electronics", "footwear"]

def detect_category(query: str) -> str:
    # simple keyword match first
    query_lower = query.lower()
    for cat in CATEGORIES:
        if cat in query_lower:
            return cat
    prompt = f"""
    Given the query: "{query}"
    Choose the most likely product category from this list: {', '.join(CATEGORIES)}.
    Respond with only one category name.
    """
    response = llm.invoke(prompt)
    return response.content.strip().lower()

class AppState(TypedDict):
    query: str
    category: Optional[str] 
    context: Optional[str]
    answer: Optional[str]

# Initialize the LLM
llm = ChatGoogleGenerativeAI(
    model="gemini-2.0-flash",
    google_api_key=os.environ["GEMINI_API_KEY"],
    temperature=0.1
)

# Define nodes
def classify_node(state):
    category = classify_query(state["query"])
    state["category"] = category
    return state

def product_retrieval_node(state):
    vectorstore, docs = build_vectorstore()
    retrieved_docs, state["context"] = retrieve_context(state, vectorstore, docs)
    products = []
    for d in retrieved_docs:
        match_id = re.search(r"Product ID:\s*(\S+)", d.page_content)
        match_name = re.search(r"Product Name:\s*(.+)", d.page_content)
        if match_id and match_name:
            products.append({
                "id": match_id.group(1).strip(),
                "name": match_name.group(1).strip()
            })

    state["answer"] = {"products": products}
    return state

def product_summary_node(state):
    #print(state)
    products = state["answer"].get("products", [])
    product_ids = [p["id"] for p in products if "id" in p]
    product_names = [p["name"] for p in products]
    #print("Retrieved product IDs:", product_ids)
    if not product_ids:
        return {
            "query_type": "product",
            "answer": {
                "products": [],
                "summary": "No products found for your query."
            }
        }
    prompt = f"""
    You are a helpful e-commerce assistant.
    The user searched for: "{state['query']}".
    The relevant product IDs are: {', '.join(product_names)}.
    Write a short, friendly one-sentence message introducing these products 
    and encouraging the user to explore them further.
    """
    summary_response = llm.invoke(prompt)
    state["answer"] = {
        "products": product_ids,
        "summary": summary_response.content.strip()
    }
    return state

def faq_retrieval_node(state):
    vectorstore, docs = faq_vectorstore("EcomCase - FAQS.pdf")
    state["context"] = retrieve_context(state, vectorstore, docs)
    return state

def llm_answer_node(state):
    context = state.get("context", "")
    category = state["category"]
    print(category)
    query = state["query"]
    if category == "faq_orders_returns_shipping":
        prompt = f"""
    You are a helpful e-commerce assistant.
    The user searched for: "{query}".
    Use this FAQ context:\n{context}\n\n
    At the end of the answer, suggest the user to navigate to the orders and returns section for more details.
    """
    elif category == "faq_payment_methods":
        prompt = f"""
    You are a helpful e-commerce assistant.
    The user searched for: "{query}".
    Use this FAQ context:\n{context}\n\n
    """
    elif category == "faq_account_settings":
        prompt = f"""
    You are a helpful e-commerce assistant.
    The user searched for: "{query}".
    Use this FAQ context:\n{context}\n\n
    At the end of the answer, suggest the user to navigate to their profile section for more details.
    """
    elif category == "customer_service":
        prompt = f""
    elif category == "general":
        prompt = f"Answer concisely:\n{query}"
    elif category == "irrelevant":
        state["answer"] = "I don\'t have personal information, but I can help you with product or orders and return related queries!"
        return state
    response = llm.invoke(prompt)
    state["answer"] = response.content
    return state

graph = StateGraph(AppState)

# Add nodes
graph.add_node("classify", classify_node)
graph.add_node("product_retrieve", product_retrieval_node)
graph.add_node("product_summary", product_summary_node)
graph.add_node("faq_retrieve", faq_retrieval_node)
graph.add_node("llm_answer", llm_answer_node)

# Conditional routing from "classify" node
def route_category(state: AppState):
    if state["category"] == "products":
        return "product_retrieve"
    elif state["category"] == "faq_orders_returns_shipping" or state["category"] == "faq_payment_methods" or state["category"] == "faq_account_settings":
        return "faq_retrieve"
    else:
        return "llm_answer"

graph.add_conditional_edges("classify", route_category)
#graph.add_edge("detect_category", "product_retrieve")

# Continue linear flow
graph.add_edge("product_retrieve", "product_summary")
graph.add_edge("faq_retrieve", "llm_answer")
graph.add_edge("llm_answer", END)
graph.add_edge(START, "classify")

app = graph.compile()#checkpointer=checkpointer

config = { 'configurable': { 'thread_id': '1'} }

def query_app(state):
    #clear_cache()
    cached = exact_cache_get(state["query"])
    print("Cached value:", cached)
    if cached:
        print("[CACHE HIT - EXACT]")
        return cached
    cached_semantic = semantic_cache_get(state["query"])
    if cached_semantic:
        print("[CACHE HIT - SEMANTIC]")
        return cached_semantic
    else:
        print("[CACHE MISS - EXACT]")
        result = app.invoke(state, config={"configurable": {"thread_id": "user_123"}})
        exact_cache_set(result["query"], result["answer"], result["category"])
        semantic_cache_set(result["query"], result["answer"], result["category"])
        return result
#print(query_app({"query": "what phones are available under 50000?"}))
#print(query_app({"query": "can you suggest the best one among the ones you have suggested?"}))








# for memory testing:
# thread_id = "session-1"
# state1 = {"query": "best rated shoes for women?"}
# result1 = app.invoke(state1, config={"configurable": {"thread_id": thread_id}})
# print(result1["answer"])

# prev_state = app.get_state(config={"configurable": {"thread_id": thread_id}})
# print("**************the value of the state is **************")
# print(prev_state.values)

# new_input = prev_state.values | {"query": "which one is the least expensive among the ones you have suggested previously?"}
# result2 = app.invoke(new_input, config={"configurable": {"thread_id": thread_id}})
# print(result2["answer"])

#print(query_app({"query": "things you would suggest before buying a phone?"})) #what are the best headphones under ₹2000?
#print(query_app({"query": "phone under 50000"}))

# state = app.invoke(
#     {"query": "things you would suggest before buying a phone?"},
#     config=config1
# )
# print(state["answer"])

# state = app.invoke(
#     {"query": "then provide me the best one under 50000"},
#     config=config1
# )
# print(state["answer"])  


