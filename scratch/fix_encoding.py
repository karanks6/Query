import os

replacements = {
    'Ã¢â€ â‚¬': '─',
    'Ã¢â€\x80â€™': '→',
    'Ã¢â‚¬â€ ': '—',
    'ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â ': '—',
    'Ã¢Ëœâ€¦': '★',
    'ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Å“': '–',
    'Ãƒâ€”': '×',
}

def fix_encoding(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                try:
                    with open(filepath, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    original = content
                    for bad, good in replacements.items():
                        content = content.replace(bad, good)
                    
                    if content != original:
                        with open(filepath, 'w', encoding='utf-8') as f:
                            f.write(content)
                        print(f"Fixed {filepath}")
                except Exception as e:
                    print(f"Error processing {filepath}: {e}")

if __name__ == '__main__':
    fix_encoding('lib')
