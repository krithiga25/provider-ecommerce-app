from dotenv import load_dotenv
from langchain_community.vectorstores import FAISS
from langchain_huggingface import HuggingFaceEmbeddings
from langchain_core.documents import Document
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_classic.retrievers import EnsembleRetriever, BM25Retriever
from langchain_community.document_loaders import PyPDFLoader
from pymongo import MongoClient
from sentence_transformers import CrossEncoder
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_classic.tools import tool
from langchain_core.tools import Tool
from langchain_classic.agents import initialize, agent_types
import google.generativeai as genai
import json
import os
import re
api_key = os.environ.get("GEMINI_API_KEY")
genai.configure(api_key=api_key)
load_dotenv()

def load_product_data():
    client = MongoClient("mongodb+srv://krithiperu2002:Shiroboy123@clusterapp.bbvbt.mongodb.net/")
    db = client["ecomdb"]
    collection = db["products"]

    docs = []
    for item in collection.find():
        content = f"Product ID: {item['id']}\nProduct Name: {item['productName']}\nDescription: {item['description']}\nPrice: ₹{item['price']}"
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
    #os.makedirs(os.path.dirname(index_path), exist_ok=True)
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

def retrieve_context(query, vectorstore, docs, k=3):
    bm25_retriever = BM25Retriever.from_documents(docs)
    semantic_retriever = vectorstore.as_retriever(search_kwargs={"k": 3})
    hybrid_retriever = EnsembleRetriever(
        retrievers=[bm25_retriever, semantic_retriever],
        weights=[0.3, 0.7]
    )
    docs = hybrid_retriever.invoke(query)
    reranked_docs = rerank_with_cross_encoder(query, docs, top_n=3)
    context = "\n".join([d.page_content for d in reranked_docs])
    return context
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

@tool
def product_query_tool(query: str) -> str:
    """Fetches relevant product info from vector DB."""
    vectorstore, docs = build_vectorstore()
    context = retrieve_context(query, vectorstore, docs)
    if not context.strip():
        context = "No product data found related to the question."
    return context

@tool
def faq_query_tool(query: str) -> str:
    """Fetches relevant FAQ info from the FAQ vector store."""
    vectorstore, documents = faq_vectorstore("EcomCase - FAQS.pdf")#can't unpack the faiss object
    context = retrieve_context(query, vectorstore, documents)
    if not context.strip():
        context = "No FAQ data found related to the question."
    return context


dummy_tool = Tool(
    name="DummyTool",
    description="A simple tool that echoes the user's query.",
    func=lambda query: "I'm a general assistant without specific tools."
)

kb_tools = [product_query_tool, faq_query_tool]

kb_agent = initialize.initialize_agent(
    tools=kb_tools,
    llm=llm,
    agent_type=agent_types.AgentType.ZERO_SHOT_REACT_DESCRIPTION,
    verbose=True
)

general_agent = initialize.initialize_agent(
   tools=[dummy_tool],
   llm=llm,
   agent_type=agent_types.AgentType.ZERO_SHOT_REACT_DESCRIPTION,
   verbose=True
)

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
    4. faq – General FAQ queries related to the orders, account settings, shipping, payment methods, customer service(e.g., "how to track my orders?", "how to return a product?", "how to reset my account password", "what are the shipping options", "what payment methods do you accept?", "where i can contact the support team?").

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

def run_rag_query(query):
    print(f"\n🔹 Query: {query}")
    query_type = classify_query(query)
    print(f"Classified as: {query_type} query")
    if query_type == "products":
        print("🧠 Using KnowledgeBase Agent (Product Data)...")
        context = product_query_tool.run(query)
        answer = kb_agent.run(f"Use this context to answer accurately:\n{context}\n\nQuestion: {query}")
        return {"query_type": "products", "answer": answer}
    # for now:
    elif query_type == "general":
        print("💬 Using General Reasoning Agent...")
        answer = general_agent.run(f"Answer concisely in points if possible:\n{query}")
        return {"query_type": "general", "answer": answer}
    # elif query_type == "orders":
    #     return {"query_type": query_type, "answer": "For information on your orders, please visit the Orders page: "}
    elif query_type == "irrelevant":
        return {"query_type": query_type, "answer": "I don’t have personal information, but I can help you with product or order-related queries!"}
    # elif query_type == "customer_service":
    #     return {"query_type": query_type, "answer": "For customer service inquiries, please contact our support team at"}
    # elif query_type == "account_related":
    #     return {"query_type": query_type, "answer": "For account-related issues, please visit the Account Settings page: "}
    elif query_type == "faq":
        print("📘 Using KnowledgeBase Agent (FAQ Data)...")
        context = faq_query_tool.run(query)
        answer = kb_agent.run(f"Use this FAQ context to answer:\n{context}\n\nQuestion: {query}")
        return {"query_type": "faq", "answer": answer}
