import os
import json
import requests
import streamlit as st
from langchain_community.vectorstores import Chroma
from langchain_community.embeddings import HuggingFaceEmbeddings

# Page configurations to keep the main background clean
st.set_page_config(page_title="Talexcel Workspace", page_icon="🤖", layout="wide")

DB_DIR = os.path.expanduser("~/talexcel_ai_bot/chroma_db")

# Initialize back-end session engines quietly in the background
@st.cache_resource
def load_rag_context():
    embeddings = HuggingFaceEmbeddings(model_name="BAAI/bge-small-en-v1.5", model_kwargs={'device': 'cpu'})
    return Chroma(persist_directory=DB_DIR, embedding_function=embeddings)

vector_db = load_rag_context()

# Initialize session state arrays for conversation tracking
if "chat_history" not in st.session_state:
    st.session_state.chat_history = []
if "widget_open" not in st.session_state:
    st.session_state.widget_open = False

# Main page background filler so the screen isn't completely empty
st.title("🌐 Talexcel Systems Operations Center")
st.caption("The core integration daemon is active. Tally is monitoring inbound requests from the widget below.")

# --- FLOATING CHAT WIDGET UI INJECTION ---
# Custom CSS injection to create a floating chat icon and panel in the lower right
st.markdown("""
    <style>
    /* Absolute positioning for the floating action button */
    .floating-btn {
        position: fixed;
        bottom: 25px;
        right: 25px;
        background-color: #1E88E5;
        color: white;
        border-radius: 50%;
        width: 60px;
        height: 60px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 24px;
        box-shadow: 0px 4px 10px rgba(0,0,0,0.3);
        cursor: pointer;
        z-index: 999999;
        border: none;
    }
    .floating-btn:hover { background-color: #1565C0; }
    </style>
""", unsafe_allowed_code=True)

# Layout splitting: Sidebar panel triggers widget state toggling cleanly
with st.sidebar:
    st.header("🎛️ Widget Controller")
    if st.button("💬 Toggle Tally Window", use_container_width=True):
        st.session_state.widget_open = not st.session_state.widget_open
    
    if st.button("🛑 End Conversation", use_container_width=True, type="primary"):
        st.session_state.chat_history = []
        st.success("Session memory wiped cleanly.")
        st.rerun()

# --- ACTIVE CHAT DISPLAY PANEL ---
if st.session_state.widget_open:
    # Render the chat box window structure in the main view
    st.markdown("---")
    st.subheader("💬 Chatting with Tally")
    
    # Custom styling container for dialogue tracking
    chat_container = st.container(height=400)
    with chat_container:
        # Default opening greeting assertion
        st.markdown("**💬 Tally:** Hi, I'm Tally. How can I help you today?")
        
        # Stream the message history seamlessly
        for message in st.session_state.chat_history:
            if message["role"] == "user":
                st.markdown(f"**👤 Casper:** {message['text']}")
            else:
                st.markdown(f"**💬 Tally:** {message['text']}")

    # Inbound message box wrapper input
    with st.form(key="chat_input_form", clear_on_submit=True):
        col1, col2 = st.columns([0.85, 0.15])
        with col1:
            user_input = st.text_input("Type your message here...", label_visibility="collapsed")
        with col2:
            submit_button = st.form_submit_button(label="Send", use_container_width=True)

    if submit_button and user_input.strip():
        # Append user input to tracking thread instantly
        st.session_state.chat_history.append({"role": "user", "text": user_input})
        
        # Build vector query string
        search_query = f"{user_input} xmlns:quer projectedClass subQueries cli:ClientConfig PagingPreStep RemoveHTMLPostStep"
        docs = vector_db.similarity_search(search_query, k=4)
        
        # Layer 2 Anonymization Filter
        cleaned_chunks = []
        for doc in docs:
            content = doc.page_content
            content = content.replace("HCA_", "ENTERPRISE_")
            content = content.replace("hca.taleo.net", "zone.taleo.net")
            cleaned_chunks.append(content)
            
        code_blueprints = "\n\n".join([f"=== REFERENCE BLUEPRINT ===\n{text}" for text in cleaned_chunks])
        
        system_instruction = (
            "You are Tally, an expert HRIS Support Analyst.\n"
            "Your style is clear, professional, helpful, and conversational. You assist with general HRIS inquiries, "
            "data configuration support, and system workflows, while possessing a deep, expert capability in writing "
            "Taleo Connect Client (TCC) integration scripts when requested.\n\n"
            "--- OPERATIONAL PROTOCOLS ---\n"
            "1. If the user is just chatting or asking general questions, respond naturally as a helpful human peer. Never bring up code definitions unprompted.\n"
            "2. When asked for TCC scripts, output the ENTIRE, 100% complete code blocks without placeholders.\n"
            "3. Never leak metadata, background sources, or raw paths.\n\n"
            f"--- REFERENCE Blueprints ---\n{code_blueprints}"
        )
        
        # Gather previous turn states
        history_context = "\n".join([f"{m['role']}: {m['text']}" for m in st.session_state.chat_history[-4:]])
        
        # Inbound payload mapping for local engine orchestration
        url = "http://localhost:11434/api/generate"
        payload = {
            "model": "llama3",
            "prompt": f"{system_instruction}\n\nHistory:\n{history_context}\n\nInput: {user_input}\n\nResponse:",
            "options": {"temperature": 0.2, "top_p": 0.9},
            "stream": False
        }
        
        try:
            with st.spinner("Tally is thinking..."):
                response = requests.post(url, json=payload, timeout=90)
                if response.status_code == 200:
                    reply = response.json().get("response", "").strip()
                    st.session_state.chat_history.append({"role": "tally", "text": reply})
                else:
                    st.error("Error processing text from server backbone engine.")
        except Exception as e:
            st.error(f"Backbone runtime connection failure: {e}")
            
        st.rerun()