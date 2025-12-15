# E-Commerce Application using Flutter + Node.js with AI assistance using RAG pipeline (Langchain and Langgraph)

An **AI-enhanced full-stack e-commerce platform** featuring a modern Flutter mobile application, a scalable Node.js backend, secure Stripe payments, and an intelligent **RAG-based AI assistant** for product discovery and user support.

---

## 🚀 Overview

This project is a **production-oriented e-commerce system** built with real-world architecture and deployment practices.  
It integrates traditional commerce workflows with **Generative AI** to deliver a smarter shopping experience.

---

## Frontend (Flutter)

The mobile application is built using **Flutter** with a clean, modular architecture.

### Features

#### User Authentication
- Login & Registration  
- JWT-based session handling  

####  Product Browsing
- View product listings  
- Search products  
- Filter & sort by price, category, and relevance  

#### Wishlist
- Add/remove products  
- Persistent user wishlist  

#### Cart Management
- Add to cart  
- Quantity updates  
- Order summary  

#### Secure Payments
- Stripe checkout integration  
- Payment intent handling  

#### Profile Page
- User details  
- Order history  

#### AI Shopping Assistant
- Natural language queries  
- Product recommendations  
- Semantic product search  

---

## Backend (Node.js + Express)

The backend service handles **business logic, authentication, payments, and database operations**.

### Tech Stack
- Node.js  
- Express.js  
- MongoDB (Mongoose)  
- Stripe API  
- JWT Authentication  
- AWS EC2  

### Responsibilities
- User authentication & authorization  
- Product & inventory management  
- Cart & order processing  
- Stripe payment flow  
- Secure REST API layer  
- Integration with AI Assistant service  

### Deployment
- Hosted on **Amazon EC2**  
- Environment-based configuration  
- Production-ready API setup  

---

## AI Assistant (RAG-Based)

The AI assistant is the **core differentiator** of this project.

It uses **Retrieval-Augmented Generation (RAG)** to provide **accurate, context-aware responses** instead of hallucinated answers.

### What the AI Can Do
- Answer user queries like:
  - *"Phones under 5000"*  
  - *"Best product for students"*  
- Perform semantic product search  
- Provide summarized, explainable results  
- Combine keyword + vector search results  

---

## RAG Pipeline Workflow

1. User Query  
2. Query Classification  
3. Exact Match Retrieval  
   - Cached using **Redis**  
4. Semantic Search  
   - FAISS vector similarity search  
5. Hybrid Ranking  
   - BM25 + embedding similarity  
6. LLM Response Generation  
   - Context-aware answers via **Google Generative AI**  

---

## AI & Data Technologies Used

- Python  
- LangChain  
- LangGraph  
- Google Generative AI (Gemini)  
- Sentence Transformers  
- FAISS (Vector Store)  
- Redis (Caching Layer)  
- Flask API  
- Docker (Containerization)  

---

## Performance Optimizations

- Redis caching for:
  - Exact match queries  
  - Frequently asked questions  
- Vector index persistence for faster retrieval  
- Hybrid retrieval strategy for improved accuracy  

---

## Containerization & Deployment

- AI service is **Dockerized**  
- Linux **AMD64-compatible** image  
- Production-ready **Gunicorn** setup  
- Deployed independently from backend for scalability  

---
