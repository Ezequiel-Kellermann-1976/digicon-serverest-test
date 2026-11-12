*** Settings ***
Documentation    Keywords construtoras de dados de teste (data builders).
...              Geram dados aleatórios com a FakerLibrary para que os testes
...              possam rodar várias vezes sem colisão.

Library          FakerLibrary    locale=pt_BR
Library          String

*** Keywords ***
Gerar usuário administrador
    [Documentation]    Monta e devolve um dicionário com os dados de um novo
    ...                usuário administrador (nome, email, senha e administrador).
    ${nome}=     FakerLibrary.Name
    ${login}=    Generate Random String    10    [LOWER]
    ${senha}=    FakerLibrary.Password    length=12    special_chars=${False}
    ${usuario}=    Create Dictionary
    ...    nome=${nome}
    ...    email=${login}@academy.dev
    ...    password=${senha}
    ...    administrador=${True}
    RETURN    ${usuario}

Gerar usuário
    [Documentation]    Dicionário com nome, email e senha de um usuário novo.
    ...                O campo administrador NÃO vem aqui: a API do ServeRest espera
    ...                o texto "true" ou "false", então quem cria o usuário define.
    ${nome}=     FakerLibrary.Name
    ${login}=    Generate Random String    10    [LOWER]
    ${senha}=    FakerLibrary.Password    length=10    special_chars=${False}
    ${usuario}=    Create Dictionary
    ...    nome=${nome}
    ...    email=${login}@academy.dev
    ...    password=${senha}
    RETURN    ${usuario}

Gerar produto
    [Documentation]    Dicionário com os dados de um produto novo. O nome é único
    ...                a cada chamada, para não colidir com produtos já cadastrados.
    ${sufixo}=    Generate Random String    8    [LOWER]
    ${preco}=     FakerLibrary.Random Int    min=10    max=500
    ${produto}=    Create Dictionary
    ...    nome=Produto Academy ${sufixo}
    ...    preco=${preco}
    ...    descricao=Produto gerado para testes automatizados
    ...    quantidade=${10}
    RETURN    ${produto}
