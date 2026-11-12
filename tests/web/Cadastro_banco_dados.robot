*** Settings ***
Documentation    Cadastro de um administrador com dados gerados (Faker) e registro
...              do usuário criado no banco de massa (SQLite). Outros testes, como o
...              de login, podem reaproveitar esse usuário lendo do banco.

Resource         ../../resources/configs/qa.resource
Resource         ../../resources/configs/db.resource
Resource         ../../resources/data/dados.resource
Resource         ../../resources/steps/cadastro_steps.resource

Suite Setup      Preparar base de dados
Suite Teardown   Disconnect From Database
Test Setup       Open Browser    ${URL}    ${BROWSER}
Test Teardown    Close Browser

*** Test Cases ***
Cadastrar administrador e registrar no banco de massa
    [Tags]    cadastro    admin    banco
    ${usuario}=    Gerar usuário administrador
    Log    Email gerado: ${usuario}[email]

    Dado que acessei o sistema ServeRest
    Quando preencho o formulário com meus dados    ${usuario}[nome]    ${usuario}[email]    ${usuario}[password]
    E marco o campo "administrador" se for o caso    ${usuario}[administrador]
    Quando submeto os dados
    Então devo ver a mensagem de sucesso na tela    Cadastro realizado com sucesso

    # Só grava no banco depois que o site confirmou o cadastro.
    Registrar usuário no banco    ${usuario}    admin

    # Confere que o usuário gravado é o que acabamos de criar.
    ${gravado}=    Obter usuário administrador
    Should Be Equal    ${gravado}[email]       ${usuario}[email]
    Should Be Equal    ${gravado}[password]    ${usuario}[password]
