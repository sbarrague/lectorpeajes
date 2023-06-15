import re


def extraer_patentes(text):
    patentes = re.findall(r"Dominio:([A-Za-z0-9]+)", text)
    patentes_sin_bonif = [patente.replace("Bonif", "") for patente in patentes]
    patentes_modificadas = []
    for patente in patentes_sin_bonif:
        if len(patente) == 6:
            modified_domain = f"{patente[:3]}-{patente[3:]}"
            patentes_modificadas.append(modified_domain)
        else:
            patentes_modificadas.append(patente)
    return patentes_modificadas
