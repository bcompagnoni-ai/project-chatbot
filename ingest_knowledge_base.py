import os
import shutil
from langchain_community.document_loaders import PyPDFDirectoryLoader, DirectoryLoader, TextLoader
from langchain_community.document_loaders.word_document import Docx2txtLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_community.vectorstores import Chroma

# Paths
SOURCE_DIR = os.path.expanduser("~/talexcel_ai_bot/source_docs")
DB_DIR = os.path.expanduser("~/talexcel_ai_bot/chroma_db")

def run_ingestion():
    print("================================================================================")
    print("INITIALIZING Semantic Ingestion ENGINE (Llama-3 Ready Architecture)")
    print("================================================================================")
    
    # 1. Initialize our Text Splitter for RAG window sizing
    splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=150)
    all_chunks = []
    
    # ---- SUB-PHASE A: Loading High-Value Document prose ----
    print("\n[ Processing Human-Readable Prose ]")
    
    # Process PDFs
    if os.path.exists(SOURCE_DIR):
        print("-> Scanning for PDF resources...")
        pdf_loader = PyPDFDirectoryLoader(SOURCE_DIR)
        try:
            pdf_docs = pdf_loader.load()
            if pdf_docs:
                pdf_chunks = splitter.split_documents(pdf_docs)
                all_chunks.extend(pdf_chunks)
                print(f"   Success: Loaded {len(pdf_docs)} PDF pages split into {len(pdf_chunks)} vectors.")
        except Exception as e:
            print(f"   Warning parsing PDFs: {e}")
            
        # Process Word Docs (.docx)
        print("-> Scanning for Microsoft Word (.docx) resources (Recursive)...")
        docx_loader = DirectoryLoader(
            SOURCE_DIR, 
            glob="**/*.docx", 
            loader_cls=Docx2txtLoader,
            show_progress=True,
            use_multithreading=True
        )
        try:
            docx_docs = docx_loader.load()
            if docx_docs:
                docx_chunks = splitter.split_documents(docx_docs)
                all_chunks.extend(docx_chunks)
                print(f"   Success: Loaded {len(docx_docs)} Word documents split into {len(docx_chunks)} vectors.")
        except Exception as e:
            print(f"   Warning parsing Word Docs: {e}")

    # ---- SUB-PHASE B: Loading Custom Extracted TCC Assets ----
    print("\n[ Processing Extracted Technical TCC Assets ]")
    tcc_txt = os.path.expanduser("~/talexcel_ai_bot/source_docs/tcc/extracted_class_strings.txt")
    if os.path.exists(tcc_txt):
        try:
            tcc_loader = TextLoader(tcc_txt, encoding='utf-8')
            tcc_docs = tcc_loader.load()
            tcc_chunks = splitter.split_documents(tcc_docs)
            all_chunks.extend(tcc_chunks)
            print(f"   Success: Loaded TCC string digests split into {len(tcc_chunks)} vectors.")
        except Exception as e:
            print(f"   Warning loading TCC text log: {e}")

    # Process extracted XSL folder
    xsl_dir = os.path.expanduser("~/talexcel_ai_bot/source_docs/tcc/extracted_xsl")
    if os.path.exists(xsl_dir):
        try:
            xsl_loader = DirectoryLoader(xsl_dir, glob="*.txt", loader_cls=TextLoader)
            xsl_docs = xsl_loader.load()
            if xsl_docs:
                xsl_chunks = splitter.split_documents(xsl_docs)
                all_chunks.extend(xsl_chunks)
                print(f"   Success: Loaded {len(xsl_docs)} XSL logic files split into {len(xsl_chunks)} vectors.")
        except Exception as e:
            print(f"   Warning loading XSL documents: {e}")

    # ---- SUB-PHASE C: Mathematical Embedding Generation ----
    if not all_chunks:
        print("\n❌ Error: No text vectors compiled. Aborting database initialization.")
        return
        
    print(f"\n[ Vectorization Phase - Total Vectors Compiled: {len(all_chunks)} ]")
    print("-> Downloading/Loading lightweight semantic embedding model (bge-small-en-v1.5)...")
    
    embeddings = HuggingFaceEmbeddings(
        model_name="BAAI/bge-small-en-v1.5",
        model_kwargs={'device': 'cpu'}
    )
    
    print("-> Computing vector matrix embeddings and saving to disk at ~/talexcel_ai_bot/chroma_db...")
    if os.path.exists(DB_DIR):
        shutil.rmtree(DB_DIR)
        
    vector_db = Chroma.from_documents(
        documents=all_chunks,
        embedding=embeddings,
        persist_directory=DB_DIR
    )
    
    print("\n================================================================================")
    print("🏆 SUCCESS: CHROMADB COMPLETELY PERSISTED TO MEMORY DRIVE")
    print("================================================================================")

if __name__ == "__main__":
    run_ingestion()
