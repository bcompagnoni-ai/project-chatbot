import os
import zipfile

jar_path = "/home/jasper/talexcel_ai_bot/source_docs/tcc/touchpoints-bombardier/lib/TCCCustomSteps_1.5.3.jar"
output_dir = "/home/jasper/talexcel_ai_bot/source_docs/tcc/extracted_xsl"
os.makedirs(output_dir, exist_ok=True)

with zipfile.ZipFile(jar_path, 'r') as jar:
    for file_name in jar.namelist():
        if file_name.startswith("xsl/") and file_name.endswith(".xsl"):
            base_name = os.path.basename(file_name)
            output_path = os.path.join(output_dir, base_name + ".txt")
            
            with open(output_path, "w", encoding="utf-8") as f:
                f.write(f"--- START OF XSL FILE: {base_name} ---\n")
                f.write(jar.read(file_name).decode("utf-8", errors="ignore"))
                f.write(f"\n--- END OF XSL FILE: {base_name} ---\n")
            print(f"Extracted transformation logic to: {output_path}")

print("XSL extraction completed successfully.")
