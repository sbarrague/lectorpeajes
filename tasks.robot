*** Settings ***
Documentation       Read the text contained in PDF files and save it to a
...                 corresponding text file.

Library             RPA.PDF
Library             RPA.FileSystem
Library             OperatingSystem
Library             Collections
Library             String
Library             leercontenido.py
Library             RPA.Database
Library             String
Library             RPA.Tables
Library             RPA.Assistant
Library             RPA.Desktop


*** Variables ***
@{patentes}     patente,Baja


*** Tasks ***
Extract text from PDF files
    ${archivo}    Subir PDF
    Conectarse a Softland
    Extraer texto de PDF a txt    ${archivo}
    ${dominios}    Leer Archivo y Extraer Dominios    ${archivo}
    ${result}    Consultar si patente esta dada de baja en Softland    @{dominios}
    log    ${result}
    Write table to CSV    ${result}    ${archivo}.csv


*** Keywords ***
Subir PDF
    Add heading    Peajes
    Add Text Input    Nombre Archivo con extensión    default=archivo.pdf
    Add submit buttons    buttons=Cargar    default=Cargar
    ${response}    Run dialog
    Log    ${response}
    Log    ${response}[Nombre Archivo con extensión]
    ${archivo}    Set Variable    R:\\COMPARTIDA\\Robocorp\\Peajes\\${response}[Nombre Archivo con extensión]
    log    ${archivo}
    RETURN    ${archivo}

Extraer texto de PDF a txt
    [Arguments]    ${archivo}
    ${text}    Get Text From Pdf    ${archivo}
    Create File    ${archivo}.txt    overwrite=True
    FOR    ${page}    IN    @{text.keys()}
        Append To File    ${archivo}.txt    ${text[${page}]}
    END

Leer Archivo y Extraer Dominios
    [Arguments]    ${archivo}
    ${archivotxt}    Set Variable    ${archivo}.txt    # Reemplaza con la ruta real de tu archivo
    ${contenido}    Get File    ${archivotxt}
    ${dominios}    Extraer Patentes    ${contenido}
    RETURN    ${dominios}

Conectarse a Softland
    Connect To Database
    ...    pymssql
    ...    GRUPO_BERALDI
    ...    SA
    ...    Power2020*
    ...    SRVBERALDIERP

Consultar si patente esta dada de baja en Softland
    [Arguments]    @{dominios}
    ${dominios_in_query}    Create List
    FOR    ${dominio}    IN    @{dominios}
        Append To List    ${dominios_in_query}    ${dominio}
    END
    ${formatted_dominios}    Evaluate    ', '.join(["'{}'".format(domain) for domain in @{dominios}])
    ${query}    Set Variable
    ...    SELECT MEMEQH_CODIGO, MEMEQH_DEBAJA FROM MEMEQH WHERE MEMEQH_CODIGO IN (${formatted_dominios})
    ${result}    Query    ${query}
    RETURN    ${result}
