import os
import re
import zipfile

jar_path = "/home/jasper/talexcel_ai_bot/source_docs/tcc/touchpoints-bombardier/lib/TCCCustomSteps_1.5.3.jar"
output_file = "/home/jasper/talexcel_ai_bot/source_docs/tcc/extracted_class_strings.txt"

# Regex to find printable string sequences longer than 5 characters
string_regex = re.compile(b'[a-zA-Z0-9_\-\.\:\s\{\}\[\]\/\\\<\>\=\,\?\!\*\+\(\)\&\;\#\@]{6,}')

with open(output_file, "w", encoding="utf-8") as out:
    out.write("================================================================================\n")
    out.write("TCC CUSTOM STEPS - CLASS STRING DIGEST FOR LLM TRACEABILITY\n")
    out.write("================================================================================\n\n")
    
    with zipfile.ZipFile(jar_path, 'r') as jar:
        for file_name in sorted(jar.namelist()):
            if file_name.startswith("com/") and file_name.endswith(".class"):
                # Skip internal anonymous or subclass structures to reduce noise
                if "$" in file_name:
                    continue
                    
                class_data = jar.read(file_name)
                matches = string_regex.findall(class_data)
                
                out.write(f"CLASS: {file_name.replace('.class', '').replace('/', '.')}\n")
                out.write("-" * 60 + "\n")
                
                for match in matches:
                    try:
                        clean_str = match.decode('utf-8').strip()
                        # Only save strings that look like parameters, log lines, or readable English
                        if any(keyword in clean_str.lower() for keyword in ['step', 'error', 'file', 'param', 'invalid', 'path', 'zip', 'count', 'xml', 'lrd']):
                            out.write(f"  • {clean_str}\n")
                    except UnicodeDecodeError:
                        continue
                out.write("\n")

print(f"Class string parameters scraped successfully into: {output_file}")
