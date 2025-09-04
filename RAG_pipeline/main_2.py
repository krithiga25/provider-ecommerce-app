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
from transformers import AutoModel, AutoTokenizer
#import faiss
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

# retrival part using vector store:
vectorstore = FAISS.from_documents(split_documents, embeddings)
vectorstore.save("faiss_index")
new_vectorstore = FAISS.load_local(
       "faiss_index_react", embeddings, allow_dangerous_deserialization=True
   )

# # Retreival part:
# query = "Engagement ring for women?"
# # Embed the query using the same model and tokenizer as before
# query_embedding = embed_chunk(query)
# # Search for the top-k most similar documents in the index
# k = 1
# distances, indices = index.search(query_embedding.reshape(1, -1), k)
# # Print the top-k results
# print("Top-{} results:".format(k))
# for i, (distance, index) in enumerate(zip(distances[0], indices[0])):
#     print("Rank {}: Chunk {} (Distance: {:.4f})".format(i+1, index, distance))
#     print("Chunk text:", chunks[index].page_content)
#     print()

# generational phase:
prompt = f"""
<|system|>>
You are an AI Assistant that follows instructions extremely well.
Please be truthful and give direct answers. Please tell 'I don't know' if user query is not in context
</s>
<|user|>
{query}
</s>
<|assistant|>
"""
model = HuggingFaceHub(repo_id="google/flan-t5-small",
huggingfacehub_api_token = "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",
                       model_kwargs={"temperature":0.5,
                                     "max_new_tokens":512,
                                     "max_length":64
                                    })

qa = RetrievalQA.from_chain_type(llm=model,retriever=retriever,chain_type="stuff")
response = qa(prompt)
print(response['result'])


# # Initialize the FLAN model
# flan_model = FlanModel.from_pretrained("google/flan-t5-base")

# retriever = HuggingFaceRetriever(
#     index=index,  # assuming you have an index created earlier
#     embedding_model=model_name,  # assuming you have a FLAN model created earlier
#     top_k=5,  # retrieve the top 5 most relevant documents
# )

# # Initialize the RetrievalQA chain
# retrieval_qa = RetrievalQA(
#     model=flan_model,
#     index=index,  # assuming you have an index created earlier
#     retriever=retriever,  # assuming you have a retriever created earlier
# )

# # Define a prompt for the RetrievalQA chain
# prompt = "I'm looking for a new pair of shoes. Can you tell me more about the Nike Air Max 270?"

# # Run the RetrievalQA chain
# response = retrieval_qa(prompt)

# # Print the response
# print("Generated response:", response)