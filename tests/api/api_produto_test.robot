*** Settings ***
Documentation    Testes de API - Cadastro de produto (ServeRest).
...              As quatro regras da tabela de decisão: sem token (401),
...              usuário comum (403), nome já cadastrado (400) e
...              administrador com dados válidos (201).

Resource         ../../resources/configs/api.resource

Suite Setup      Abrir sessão na API
Suite Teardown   Delete All Sessions

*** Test Cases ***
Administrador cadastra produto
    [Tags]    api    produto    cadastro    sucesso
    ${headers}=    Criar administrador e obter token
    ${produto}=    Gerar produto

    ${resp}=    POST On Session
    ...    serverest
    ...    /produtos
    ...    json=${produto}
    ...    headers=${headers}
    ...    expected_status=201

    Should Be Equal    ${resp.json()}[message]    Cadastro realizado com sucesso
    Should Not Be Empty    ${resp.json()}[_id]

Cadastro de produto sem token é recusado
    [Tags]    api    produto    cadastro    seguranca
    ${produto}=    Gerar produto

    ${resp}=    POST On Session
    ...    serverest
    ...    /produtos
    ...    json=${produto}
    ...    expected_status=401

    Should Be Equal
    ...    ${resp.json()}[message]
    ...    Token de acesso ausente, inválido, expirado ou usuário do token não existe mais

Usuário comum não pode cadastrar produto
    [Tags]    api    produto    cadastro    seguranca
    ${headers}=    Criar usuário comum e obter token
    ${produto}=    Gerar produto

    ${resp}=    POST On Session
    ...    serverest
    ...    /produtos
    ...    json=${produto}
    ...    headers=${headers}
    ...    expected_status=403

    Should Be Equal    ${resp.json()}[message]    Rota exclusiva para administradores

Produto com nome já cadastrado é recusado
    [Tags]    api    produto    cadastro    negativo
    ${headers}=    Criar administrador e obter token
    ${produto}=    Gerar produto

    POST On Session
    ...    serverest
    ...    /produtos
    ...    json=${produto}
    ...    headers=${headers}
    ...    expected_status=201

    ${resp}=    POST On Session
    ...    serverest
    ...    /produtos
    ...    json=${produto}
    ...    headers=${headers}
    ...    expected_status=400

    Should Be Equal    ${resp.json()}[message]    Já existe produto com esse nome
