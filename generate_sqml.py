import os
import json
import warnings
import requests

# Suppress the LangChain and HF Hub console clutter warnings cleanly
warnings.filterwarnings("ignore", category=UserWarning)
os.environ["TOKENIZERS_PARALLELISM"] = "false"

from langchain_community.vectorstores import Chroma
from langchain_community.embeddings import HuggingFaceEmbeddings

DB_DIR = os.path.expanduser("~/talexcel_ai_bot/chroma_db")

print("================================================================================")
print("? INITIALIZING TALEXCEL CORE: INTEGRATION SYSTEM INSTANCE")
print("================================================================================")
print("-> Loading structural vector matrices safely into active memory...")

embeddings = HuggingFaceEmbeddings(model_name="BAAI/bge-small-en-v1.5", model_kwargs={'device': 'cpu'})
vector_db = Chroma(persist_directory=DB_DIR, embedding_function=embeddings)

def generate_tcc_package(integration_name, functional_requirement):
    # Enriched cross-product search dictionary keys
    search_query = (
        "xmlns:quer projectedClass subQueries cli:ClientConfig PagingPreStep RemoveHTMLPostStep "
        "Candidate Requisition Application ProfileInformation OLF Location Organization User"
    )
    docs = vector_db.similarity_search(search_query, k=6)
    
    # Layer 2: Securely filter company context tokens out of text chunks completely
    cleaned_chunks = []
    for doc in docs:
        content = doc.page_content
        content = content.replace("HCA_", "ENTERPRISE_")
        content = content.replace("hca.taleo.net", "zone.taleo.net")
        cleaned_chunks.append(content)
        
    code_blueprints = "\n\n".join([f"=== VALIDATED REFERENCE STRUCTURE ===\n{text}" for text in cleaned_chunks])
    
    # Refined System Prompt: Re-branded to Tally with strict architectural guidelines
    system_instruction = (
        "You are Tally, an elite, expert Taleo Connect Client (TCC) systems architect.\n"
        "Your style is helpful, clean, and highly precise. You operate under strict data privacy mandates:\n"
        "- Never output raw background file paths, training names, or references.\n"
        "- Focus purely on generating complete, production-ready code blocks without using shortcuts or placeholders.\n\n"
        
        "--- SCRIPT 1: EXPORT QUERY RULES (*_sq.xml) ---\n"
        "1. Root element must be lowercase <quer:query> and include all target formatting parameters:\n"
        "   <quer:query productCode=\"RC1502\" model=\"http://www.taleo.com/ws/tee800/2009/01\" projectedClass=\"Application\" locale=\"en\" mode=\"CSV\" csvheader=\"true\" csvdelimiter=\"|\" largegraph=\"true\" preventDuplicates=\"false\" xmlns:quer=\"http://www.taleo.com/ws/integration/query\">\n"
        "2. Fields must follow complex comma-separated data dictionary paths (e.g., <quer:field path=\"Candidate,Number\"/>, <quer:field path=\"Candidate,FirstName\"/>, <quer:field path=\"Candidate,EmailAddress\"/>).\n"
        "3. Locations from SmartOrg inside Recruiting exports use deep relation lookups (e.g., <quer:field path=\"Application,Requisition,Location,Code\"/>).\n\n"
        
        "--- SCRIPT 2: CLIENT CONFIGURATION RULES (*_cfg.xml) ---\n"
        "1. Root element must be exactly: <cli:ClientConfig xmlns:cli=\"http://www.taleo.com/ws/integration/client\">\n"
        "2. <cli:Global> must wrap a complete <cli:General> block and a <cli:RequestMessage> detailing the SQ-XML target [CFGFOLDER]/[ScriptName]_sq.xml.\n"
        "3. Paging steps must follow the multi-element parameter block syntax precisely:\n"
        "   <cli:CustomStep>\n"
        "       <cli:JavaClass>com.taleo.integration.client.customstep.paging.PagingPreStep</cli:JavaClass>\n"
        "       <cli:Parameters>\n"
        "           <cli:Parameter><cli:Name>pagingSize</cli:Name><cli:Value>500</cli:Value></cli:Parameter>\n"
        "           <cli:Parameter><cli:Name>pagingFilename</cli:Name><cli:Value>[TEMP_FOLDER]/[ScriptName].pgn</cli:Value></cli:Parameter>\n"
        "       </cli:Parameters>\n"
        "   </cli:CustomStep>\n"
        "4. PostProcess must close with: <cli:JavaClass>com.taleo.integration.client.customstep.paging.PagingPostStep</cli:JavaClass> inside its own <cli:CustomStep> container.\n\n"
        
        f"--- ARCHITECTURAL REFERENCE PATTERNS ---\n{code_blueprints}\n=================================================="
    )
    
    prompt = (
        f"Integration Name: {integration_name}\n"
        f"Functional Intent: {functional_requirement}\n"
    )
    
    url = "http://localhost:11434/api/generate"
    payload = {
        "model": "llama3",
        "prompt": f"{system_instruction}\n\nUser Request:\n{prompt}\n\nArchitect Output:",
        "options": {
            "temperature": 0.1,
            "top_p": 0.9
        },
        "stream": True
    }
    
    try:
        response = requests.post(url, json=payload, stream=True)
        print(f"======================= PRODUCTION OUTPUT BUNDLE =======================")
        for line in response.iter_lines():
            if line:
                chunk = json.loads(line.decode('utf-8'))
                print(chunk.get("response", ""), end="", flush=True)
        print("\n==========================================================================")
    except Exception as e:
        print(f"\n? Local Ollama Connection Refused: {e}")

if __name__ == "__main__":
    # Tally's Official Interactive Initialization Greeting
    print("\n? Tally: \"Hi, I'm Tally. How can I help you today?\"\n")
    
    name = "Recruiting_Org_Sync"
    req = (
        "Export Candidate Application fields including Candidate Number, First Name, Last Name, "
        "and Email Address, combined with associated SmartOrg Location mappings showing Location Code, "
        "State Location Network Abbreviation, and Country Location Network Name. Utilize productCode RC1502. "
        "Format the output file as a pipe-delimited CSV, and construct an automated PreProcess/PostProcess "
        "paging loop limited to 500 records per execution block."
    )
    generate_tcc_package(name, req)