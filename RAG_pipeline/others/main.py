from pymongo import MongoClient
from langchain.schema import Document
from langchain.text_splitter import RecursiveCharacterTextSplitter
#from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_community.vectorstores import FAISS
#from langchain_community.llms import HuggingFacePipeline
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM, pipeline
from langchain.chains import RetrievalQA
from langchain_huggingface import HuggingFaceEmbeddings, HuggingFacePipeline
#from sklearn.metrics.pairwise import cosine_similarity
#from sklearn.feature_extraction.text import TfidfVectorizer

client = MongoClient("mongodb+srv://krithiperu2002:Shiroboy123@clusterapp.bbvbt.mongodb.net/")
db = client["ecomdb"]
collection = db["products"]

docs = []
for item in collection.find():
    content = f"Product Name: {item['productName']}\nDescription: {item['description']}\nPrice: ₹{item['price']}"
    docs.append(Document(page_content=content))

splitter = RecursiveCharacterTextSplitter(chunk_size=500, chunk_overlap=50)
chunks = splitter.split_documents(docs)


embedding_model = HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2")
vectorstore = FAISS.from_documents(chunks, embedding_model)
vectorstore.save_local("faiss_index")

retriever = FAISS.load_local("faiss_index", embedding_model, allow_dangerous_deserialization=True).as_retriever(search_kwargs={"k": 1})


model_id = "google/flan-t5-base"
tokenizer = AutoTokenizer.from_pretrained(model_id)
model = AutoModelForSeq2SeqLM.from_pretrained(model_id)

pipe = pipeline("text2text-generation", model=model, tokenizer=tokenizer, max_length=300)
llm = HuggingFacePipeline(pipeline=pipe)


qa_chain = RetrievalQA.from_chain_type(llm=llm, retriever=retriever, return_source_documents=True)
def get_answer(query):
    response = qa_chain.invoke(query)
    prompt = "Here is the best footwear for women: {} ({}) - {}".format(
        response['source_documents'][0].page_content.split('\n')[0].split(': ')[1],
        response['source_documents'][0].page_content.split('\n')[2].split(': ')[1],
        response['source_documents'][0].page_content.split('\n')[1].split(': ')[1]
    )
    generated_response = llm.generate(prompts=[prompt], max_length=200)
    #text_response = generated_response.generations[0].text
    return generated_response

#generated_response = llm.generate(prompts=[response["result"]], max_length=200)

# prompt based:
# prompt = "Based on the product details, what would you recommend for someone looking for a good pair of headphones under ₹2000?"

# vectorizer = TfidfVectorizer()
# query_vector = vectorizer.fit_transform([query])
# response_vector = vectorizer.transform([response["result"]])

# similarity = cosine_similarity(query_vector, response_vector)
# print("Query:", query_vector)
# print("Response:", response_vector)
# print("Similarity:", similarity)
# if similarity < 0.5:
#     generated_response = "I'm not sure what you're asking about."
# else:
#     generated_response = llm.generate(prompts=[response["result"]], max_length=200)

query = "Best footwear for women?"
answer = get_answer(query)
print("Generated Response:", answer)
