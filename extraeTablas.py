import PyPDF2
import pandas as pd
import re

# Abrir el archivo PDF
pdf_file = open("Cpte_Pas_951093_908030707441514.pdf", "rb")
pdf_reader = PyPDF2.PdfReader(pdf_file)

# Definir el patrón para buscar la patente
patente_pattern = re.compile(r"Dominio:(.+?)\b")

# Buscar páginas que contengan el texto "Dominio:" y "Patente"
pages_with_table = []
for page_num in range(len(pdf_reader.pages)):
    page = pdf_reader.pages[page_num]
    page_text = page.extract_text()
    if re.search(r"Dominio:", page_text) and re.search(r"Patente", page_text):
        pages_with_table.append(page_num)

# Extraer las tablas de cada página que contenga el texto
tables = []
for page_num in pages_with_table:
    page = pdf_reader.getPage(page_num)
    page_text = page.extractText()
    patente_match = patente_pattern.search(page_text)
    patente = patente_match.group(1) if patente_match else None
    start_index = patente_match.end() if patente_match else None
    table_text = page_text[start_index:]
    table = pd.read_csv(pd.compat.StringIO(table_text), sep="\s+")
    if patente:
        table["Patente"] = patente
    tables.append(table)

# Concatenar todas las tablas en un solo DataFrame
df = pd.concat(tables)

# Guardar la tabla en un archivo Excel
df.to_excel("tabla.xlsx", index=False)

# Cerrar el archivo PDF
pdf_file.close()
