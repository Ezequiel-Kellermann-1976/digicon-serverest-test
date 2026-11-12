*** Settings ***
Documentation    Cadastro de um usuário administrador com dados gerados por um
...              construtor (FakerLibrary). O usuário é novo a cada execução,
...              então o teste pode rodar várias vezes sem colisão de email.

Resource         ../../resources/configs/qa.resource
Resource         ../../resources/data/dados.resource
Resource         ../../resources/steps/cadastro_steps.resource

Test Setup       Open Browser    ${URL}    ${BROWSER}
Test Teardown    Close Browser

*** Test Cases ***
Cadastrar usuário administrador com dados gerados automaticamente
    [Tags]    cadastro    admin    faker
    ${usuario}=    Gerar usuário administrador
    Log    Email gerado: ${usuario}[email]

    Dado que acessei o sistema ServeRest
    Quando preencho o formulário com meus dados    ${usuario}[nome]    ${usuario}[email]    ${usuario}[password]
    E marco o campo "administrador" se for o caso    ${usuario}[administrador]
    Quando submeto os dados
    Então devo ver a mensagem de sucesso na tela    Cadastro realizado com sucesso
