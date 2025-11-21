from langchain_community.vectorstores import FAISS
#from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain.docstore.document import Document
from langchain.text_splitter import RecursiveCharacterTextSplitter
from pymongo import MongoClient
from transformers import pipeline
from crewai import Agent, Task, Crew
#from langchain_community.llms.huggingface_pipeline import HuggingFacePipeline
from langchain_huggingface import HuggingFaceEmbeddings, HuggingFacePipeline
from langchain.chains import RetrievalQA

# -----------------------------
# 1. Load Data from MongoDB
# -----------------------------
def load_product_data():
    client = MongoClient("mongodb+srv://krithiperu2002:Shiroboy123@clusterapp.bbvbt.mongodb.net/")
    db = client["ecomdb"]
    collection = db["products"]

    docs = []
    for item in collection.find():
        content = f"Product Name: {item['productName']}\nDescription: {item['description']}\nPrice: ₹{item['price']}"
        docs.append(Document(page_content=content))
    return docs  # ✅ Return the list of documents


# -----------------------------
# 2. Build FAISS Vector Store
# -----------------------------
def build_vectorstore():
    docs = load_product_data()

    splitter = RecursiveCharacterTextSplitter(chunk_size=500, chunk_overlap=50)
    split_docs = splitter.split_documents(docs)

    embeddings = HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2")
    vectorstore = FAISS.from_documents(split_docs, embeddings)
    return vectorstore


# -----------------------------
# 3. Initialize models
# -----------------------------
# RAG model for product-specific QA
rag_model = pipeline(
    "text2text-generation",
    model="google/flan-t5-small",
    device=-1
)

# Fallback model for general knowledge QA
general_model = pipeline(
    "text2text-generation",
    model="facebook/bart-large-cnn",
    device=-1
)


# -----------------------------
# 4. Hybrid RAG agent
# -----------------------------
class HybridRAGAgent:
    def __init__(self, rag_model, general_model, vectorstore):
        self.rag_model = rag_model
        self.general_model = general_model
        self.vectorstore = vectorstore
        self.embeddings = HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2")

    def run(self, query):
        retriever = self.vectorstore.as_retriever(search_kwargs={"k": 3})
        docs_and_scores = self.vectorstore.similarity_search_with_score(query, k=3)

        # Get top score to measure confidence
        if docs_and_scores:
            best_doc, best_score = docs_and_scores[0]
        else:
            best_doc, best_score = None, 0

        # If confidence (similarity) is too low → fallback to general model
        if best_score < 0.3:
            print("⚙️ Using general knowledge model (fallback)...")
            result = self.general_model(
                f"Answer this question in detail:\n{query}",
                max_length=250,
                do_sample=True
            )
            return result[0]["generated_text"]

        # Otherwise use RAG with context
        docs = [d.page_content for d, s in docs_and_scores]
        context = "\n\n".join(docs)

        prompt = f"Answer the question based on the context below:\n\n{context}\n\nQuestion: {query}\nAnswer:"
        result = self.rag_model(prompt, max_length=250, do_sample=True)
        return result[0]["generated_text"]


# -----------------------------
# 5. Test
# -----------------------------
if __name__ == "__main__":
    print("🔹 Building vector store ...")
    vectorstore = build_vectorstore()

    print("🔹 Initializing hybrid RAG agent ...")
    agent = HybridRAGAgent(rag_model, general_model, vectorstore)

    queries = [
        "Suggest laptops under ₹70000",
        "Things to consider before buying a laptop",
        "What are the features of Apple iPhone 13?"
    ]

    for q in queries:
        print(f"\n🔹 Query: {q}")
        print("Answer →", agent.run(q))