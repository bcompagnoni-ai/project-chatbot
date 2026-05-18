import os
import zipfile

jar_path = "/home/jasper/talexcel_ai_bot/source_docs/tcc/touchpoints-bombardier/lib/TCCCustomSteps_1.5.3.jar"

print("================================================================================")
print(f"EXTRACTING ARCHIVE SCHEMAS: {os.path.basename(jar_path)}")
print("================================================================================")

if not os.path.exists(jar_path):
    print(f"Error: Archive not found at {jar_path}")
else:
    with zipfile.ZipFile(jar_path, 'r') as jar:
        file_list = jar.namelist()
        print(f"Total internal records: {len(file_list)}")
        
        # Pull text-based configurations, docs, or properties
        doc_files = [f for f in file_list if any(ext in f.lower() for ext in ['.txt', '.md', '.properties', '.xml', '.html', '.json'])]
        
        print("\n[ INTERNAL INSTRUCTION & CONFIGURATION FILES ]")
        if doc_files:
            for doc in doc_files:
                print(f" 📄 {doc}")
        else:
            print("  No plaintext meta-files found inside the package.")

        print("\n[ TOP-LEVEL STRUCTURAL DIRECTORIES ]")
        top_dirs = set(f.split('/')[0] for f in file_list if '/' in f)
        for d in sorted(top_dirs):
            print(f" 📂 {d}/")
