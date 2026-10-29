*** Settings ***
Documentation    Cenários de Login (HU03) escritos em Gherkin.
...              Camada Cenários: apenas a história do teste.

Resource         ../../resources/configs/qa.resource
Resource         ../../resources/steps/login_steps.resource

Test Setup       Open Browser    ${URL}login    ${BROWSER}
Test Teardown    Close Browser

*** Test Cases ***
CN-008 Login com credenciais corretas
    [Documentation]    Login realizado com sucesso.
    [Tags]    sucesso
    Dado que estou na tela de login
    Quando eu informo o email "${EMAIL}"
    E eu informo a senha "${PASSWORD}"
    E eu clico no botão entrar
    Então devo ver a mensagem "Serverest Store"

CN-009 Login recusado com credenciais incorretas
    [Documentation]    Login recusado com "Email e/ou senha inválidos".
    [Tags]    negativo
    Dado que estou na tela de login
    Quando eu informo o email "${EMAIL}"
    E eu informo a senha "senha_invalida"
    E eu clico no botão entrar
    Então devo ver a mensagem "Email e/ou senha inválidos"

CN-010 Login exige email e senha
    [Documentation]    O sistema indica que a senha é obrigatória.
    [Tags]    obrigatorios
    Dado que estou na tela de login
    Quando eu informo o email "${EMAIL}"
    E eu clico no botão entrar
    Então devo ver a mensagem "Password é obrigatório"
