*** Settings ***
Documentation    Banco de massa em SQLite: guarda os usuários criados nos testes
...              para que outros testes possam reaproveitá-los.
...              Atenção: o banco guarda senhas de teste (sintéticas) e não vai para o Git.

Library          DatabaseLibrary
Library          OperatingSystem

*** Variables ***
# Raiz do projeto/data/massa.db (resources/configs -> ../../data).
${DB_PASTA}      ${CURDIR}${/}..${/}..${/}data
${DB_ARQUIVO}    ${DB_PASTA}${/}massa.db

*** Keywords ***
Preparar base de dados
    [Documentation]    Cria a pasta e a tabela (se não existirem) e abre a conexão.
    Create Directory    ${DB_PASTA}
    Connect To Database    sqlite3
    ...    database=${DB_ARQUIVO}
    ...    isolation_level=${None}

    ${sql}=    Catenate    SEPARATOR=${SPACE}
    ...    CREATE TABLE IF NOT EXISTS usuarios_teste (
    ...    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ...    email TEXT NOT NULL UNIQUE,
    ...    senha TEXT NOT NULL,
    ...    perfil TEXT NOT NULL,
    ...    criado_em TEXT DEFAULT (datetime('now'))
    ...    )

    Execute Sql String    ${sql}

Registrar usuário no banco
    [Documentation]    Grava o usuário (dicionário com email e password) com o perfil informado.
    [Arguments]    ${usuario}    ${perfil}

    @{parametros}=    Create List
    ...    ${usuario}[email]
    ...    ${usuario}[password]
    ...    ${perfil}

    ${sql}=    Catenate    SEPARATOR=${SPACE}
    ...    INSERT OR REPLACE INTO usuarios_teste
    ...    (email, senha, perfil)
    ...    VALUES (?, ?, ?)

    Execute Sql String
    ...    ${sql}
    ...    parameters=${parametros}

Obter usuário administrador
    [Documentation]    Devolve um dicionário (email e password) do último administrador gravado.
    ${sql}=    Catenate    SEPARATOR=${SPACE}
    ...    SELECT email, senha
    ...    FROM usuarios_teste
    ...    WHERE perfil = 'admin'
    ...    ORDER BY id DESC
    ...    LIMIT 1

    ${linhas}=    Query    ${sql}

    Should Not Be Empty
    ...    ${linhas}
    ...    Nenhum administrador encontrado no banco de massa.

    &{usuario}=    Create Dictionary
    ...    email=${linhas}[0][0]
    ...    password=${linhas}[0][1]

    RETURN    ${usuario}
