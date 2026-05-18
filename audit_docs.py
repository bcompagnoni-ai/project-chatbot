import os

def audit_directory(path):
    stats = {"total_files": 0, "extensions": {}}
    
    print(f"\nScanning: {path}")
    print("-" * 40)
    
    for root, dirs, files in os.walk(path):
        for file in files:
            stats["total_files"] += 1
            ext = os.path.splitext(file)[1].lower() or ".no_ext"
            stats["extensions"][ext] = stats["extensions"].get(ext, 0) + 1
            
            # Print nested files to verify recursive depth
            rel_path = os.path.relpath(os.path.join(root, file), path)
            print(f"FOUND: {rel_path}")

    print("-" * 40)
    print(f"Total Files: {stats['total_files']}")
    print("Breakdown by Extension:")
    for ext, count in stats["extensions"].items():
        print(f"  {ext}: {count}")

if __name__ == "__main__":
    source_path = os.path.expanduser("~/talexcel_ai_bot/source_docs")
    audit_directory(source_path)
