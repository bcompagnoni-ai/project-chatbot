import os
import json
import requests
from flask import Flask, request, jsonify
from flask_cors import CORS
from langchain_chroma import Chroma
from langchain_huggingface import HuggingFaceEmbeddings

app = Flask(__name__)
CORS(app)  # Allows secure cross-origin communication with your web browser

# Set local directory path for the vector storage matrix
DB_DIR = os.path.expanduser("~/talexcel_ai_bot/chroma_db")

# Modernized LangChain initialization to bypass deprecation tracking lines
embeddings = HuggingFaceEmbeddings(model_name="BAAI/bge-small-en-v1.5", model_kwargs={'device': 'cpu'})
vector_db = Chroma(persist_directory=DB_DIR, embedding_function=embeddings)

@app.route('/api/chat', methods=['POST'])
def web_chat_handler():
    data = request.json
    if not data:
        return jsonify({"reply": "Invalid or missing JSON payload structure."}), 400
        
    user_input = data.get("message", "")
    clean_input = user_input.strip()
    
    if not clean_input:
        return jsonify({"reply": "Input field empty."})

    # INTENT DISPATCHER: Identify short casual phrases to bypass database overhead
    greetings = ["hi", "hello", "hey", "greetings", "test", "yo", "sup", "howdy"]
    is_casual_greeting = clean_input.lower().rstrip('.,!?') in greetings

    code_blueprints = ""
    if not is_casual_greeting:
        # Search Vector Matrix across all indexed data dictionaries
        search_query = f"{clean_input} xmlns:quer projectedClass subQueries cli:ClientConfig PagingPreStep"
        docs = vector_db.similarity_search(search_query, k=2)
        
        # Layer 2 Scrubbing: Anonymize memory structures completely before inference execution
        cleaned_chunks = []
        for doc in docs:
            content = doc.page_content
            content = content.replace("HCA_", "ENTERPRISE_")
            content = content.replace("hca.taleo.net", "zone.taleo.net")
            cleaned_chunks.append(content)
            
        code_blueprints = "\n\n".join([f"=== REFERENCE STRUCT ===\n{text}" for text in cleaned_chunks])
    
    # Establish base system persona rules
    system_instruction = (
        "You are Tally, an expert HRIS Support Analyst.\n"
        "Your style is clear, professional, helpful, and conversational. You assist with general HRIS inquiries, "
        "data configuration support, and system workflows, while possessing a deep, expert capability in writing "
        "Taleo Connect Client (TCC) integration scripts when requested.\n\n"
        "--- OPERATIONAL PROTOCOLS ---\n"
        "1. If the user is just chatting or asking general questions, respond naturally as a helpful human peer. Never bring up code definitions unprompted.\n"
        "2. When asked for TCC scripts, output the ENTIRE, 100% complete code blocks without placeholders.\n"
        "3. Never leak metadata, background sources, or raw paths.\n\n"
    )
    
    if code_blueprints:
        system_instruction += f"--- REFERENCE MATERIAL ---\n{code_blueprints}"

    url = "http://localhost:11434/api/generate"
    payload = {
        "model": "llama3",
        "prompt": f"{system_instruction}\n\nUser Prompt: {clean_input}\n\nResponse:",
        "options": {
            "temperature": 0.2, 
            "top_p": 0.9,
            "num_predict": 512   # Prevents processing runaway on local hardware
        },
        "stream": False
    }

    try:
        response = requests.post(url, json=payload, timeout=300)
        reply = response.json().get("response", "").strip()
        return jsonify({"reply": reply})
    except Exception as e:
        return jsonify({"reply": f"Backend communication error mapping route trace: {e}"})

if __name__ == "__main__":
    # Launch multi-threaded internal socket listener on loopback interface
    app.run(host='127.0.0.1', port=5000, threaded=True)