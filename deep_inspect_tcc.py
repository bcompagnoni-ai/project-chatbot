import zipfile

jar_path = "/home/jasper/talexcel_ai_bot/source_docs/tcc/touchpoints-bombardier/lib/TCCCustomSteps_1.5.3.jar"

with zipfile.ZipFile(jar_path, 'r') as jar:
    file_list = jar.namelist()
    
    print("================================================================================")
    print("[ CONTENT OF META-INF ]")
    meta_inf_files = [f for f in file_list if f.startswith("META-INF/")]
    for f in meta_inf_files:
        print(f" ⚙️ {f}")
        
    print("\n[ CONTENT OF XSL DIRECTORY ]")
    xsl_files = [f for f in file_list if f.startswith("xsl/")]
    for f in xsl_files:
        print(f" 🗺️ {f}")

    print("\n[ JAVA PACKAGE STRUCTURE (Sample of Classes) ]")
    com_files = [f for f in file_list if f.startswith("com/") and f.endswith(".class")]
    print(f" Total compiled Java classes: {len(com_files)}")
    # Show just the first 15 to map out the package names
    for f in sorted(com_files)[:15]:
        print(f" ☕ {f}")
    if len(com_files) > 15:
        print("  ... (truncated)")
print("================================================================================")
