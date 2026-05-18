import os
import json
import warnings
import requests

# Suppress console clutter warnings cleanly
warnings.filterwarnings("ignore", category=UserWarning)
os.environ["TOKENIZERS_PARALLELISM"] = "false"

from langchain_community.vectorstores import Chroma
from langchain_community.embeddings import HuggingFaceEmbeddings

DB_DIR = os.path.expanduser("~/talexcel_ai_bot/chroma_db")

print("================================================================================")
print("💬 INITIALIZING TALLY: HRIS INTELLIGENCE ENGINE")
print("================================================================================")
print("-> Loading structural data dictionaries into session memory...")

embeddings = HuggingFaceEmbeddings(model_name="BAAI/bge-small-en-v1.5", model_kwargs={'device': 'cpu'})
vector_db = Chroma(persist_directory=DB_DIR, embedding_function=embeddings)

def run_tally_chat_loop():
    chat_history = []
    
    # Tally's official introductory greeting
    print('\n💬 Tally: "Hi, I\'m Tally. How can I help you today?"')
    
    while True:
        try:
            user_input = input("\n👤 Casper: ")
            if not user_input.strip():
                continue
            if user_input.lower() in ["exit", "quit", "bye"]:
                print('\n💬 Tally: "Goodbye! Let me know if you need help with anything else."\n')
                break
                
            # Cleaned up processing status marker
            print("\nThinking...")
            
            # Contextual vector search query across multi-model schemas
            search_query = f"{user_input} xmlns:quer projectedClass subQueries cli:ClientConfig PagingPreStep RemoveHTMLPostStep"
            docs = vector_db.similarity_search(search_query, k=5)
            
            # Secure Filter: Dynamically strip structural metadata and proprietary company markers
            cleaned_chunks = []
            for doc in docs:
                content = doc.page_content
                content = content.replace("HCA_", "ENTERPRISE_")
                content = content.replace("hca.taleo.net", "zone.taleo.net")
                cleaned_chunks.append(content)
                
            code_blueprints = "\n\n".join([f"=== REFERENCE SYNTAX TEMPLATE ===\n{text}" for text in cleaned_chunks])
            
            # Refined System Instruction: Pivoted to an HRIS Support Expert
            system_instruction = (
                "You are Tally, an expert HRIS Support Analyst.\n"
                "Your style is clear, professional, helpful, and conversational. You assist with general HRIS inquiries, "
                "data configuration support, and system workflows, while possessing a deep, expert capability in writing "
                "Taleo Connect Client (TCC) integration scripts when requested.\n\n"
                
                "--- OPERATIONAL PROTOCOLS ---\n"
                "1. If the user is just chatting, changing topics, or asking a general HRIS/functional question, respond naturally "
                "   as a helpful human peer. Never bring up your programming rules, technical parameters, or assert your identity unprompted.\n"
                "2. When explicitly asked to generate TCC integration code, seamlessly switch to technical delivery and provide the ENTIRE, "
                "   100% complete code blocks for both files without truncation or placeholders.\n"
                "3. You operate under a strict data privacy mandate. Never output raw background file paths, training names, or reference sources.\n\n"
                
                "--- TECHNICAL BASELINES (FOR TCC REQUESTS) ---\n"
                "- Recruiting (RC1502): <quer:query productCode=\"RC1502\" model=\"http://www.taleo.com/ws/tee800/2009/01\" projectedClass=\"Application\" mode=\"CSV\" csvheader=\"true\" csvdelimiter=\"|\" largegraph=\"true\" preventDuplicates=\"false\" xmlns:quer=\"http://www.taleo.com/ws/integration/query\">\n"
                "- SmartOrg (SO1502): model=\"http://www.taleo.com/ws/soap/tee800/2009/01\"\n"
                "- Transitions (TR1502): model=\"http://www.taleo.com/ws/tx800/2009/01\"\n"
                "- Client Configurations: Root element is <cli:ClientConfig xmlns:cli=\"http://www.taleo.com/ws/integration/client\">. Wrap configurations within a full <cli:Global> block and manage large pulls using explicit <cli:PreProcess>/<cli:PostProcess> PagingPreStep / PagingPostStep parameters.\n\n"
                
                f"--- CONTEXT REFERENCE MATERIAL ---\n{code_blueprints}"
            )
            
            # Compile historical turns alongside the current input prompt block
            history_context = "\n".join([f"Turn: {h}" for h in chat_history[-6:]])
            
            url = "http://localhost:11434/api/generate"
            payload = {
                "model": "llama3",
                "prompt": f"{system_instruction}\n\nChat History Context:\n{history_context}\n\nCurrent Request:\n{user_input}\n\nResponse:",
                "options": {"temperature": 0.2, "top_p": 0.9},
                "stream": True
            }
            
            response = requests.post(url, json=payload, stream=True)
            print(f"================================ TALLY OUTPUT ================================")
            full_response_text = ""
            for line in response.iter_lines():
                if line:
                    chunk = json.loads(line.decode('utf-8'))
                    chunk_text = chunk.get("response", "")
                    print(chunk_text, end="", flush=True)
                    full_response_text += chunk_text
            print("\n==============================================================================")
            
            chat_history.append(f"User: {user_input}")
            chat_history.append(f"Assistant: {full_response_text}")
            
        except KeyboardInterrupt:
            print('\n\n💬 Tally: "Session interrupted safely. Type exit to quit."')
        except Exception as e:
            print(f"\n❌ Local Connection Fault: {e}")

if __name__ == "__main__":
    run_tally_chat_loop()