from flask import Flask, request, jsonify
#from rag import run_rag_query
from rag_graph import query_app

app = Flask(__name__)

@app.route("/")
def home():
    return "Flask API is running successfully! 🚀"

@app.route("/ask", methods=["POST"])
def ask_query():
    data = request.get_json()
    if not data or "query" not in data:
        return jsonify({"error": "Please provide a 'query' in JSON body"}), 400

    query = data["query"]
    #print(f"🔹 Received query: {query}")
    #result = run_rag_query(query)
    result = query_app(data)
    #print(result)
    return jsonify({
        "status": True,
        "category": result["category"],
        "answer": result["answer"]
    }), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=True)
