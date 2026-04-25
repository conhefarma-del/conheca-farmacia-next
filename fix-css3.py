with open(r'C:\Users\bapti\Documents\Criação de WebSites\Conheça Farmácia\src\input.css', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace mobile-active styles - exact match with proper spacing
content = content.replace(
    '.nav-links.mobile-active {\n transform: translateY(0);\n opacity: 1;\n }',
    '.nav-links.mobile-active {\n transform: translateY(0);\n opacity: 1;\n display: flex;\n }'
)

with open(r'C:\Users\bapti\Documents\Criação de WebSites\Conheça Farmácia\src\input.css', 'w', encoding='utf-8') as f:
    f.write(content)

print('Done!')
