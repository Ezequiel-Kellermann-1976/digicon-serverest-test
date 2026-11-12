*** Settings ***
Documentation    teste usando datapool CSV

Library          SeleniumLibrary
Library          DataDriver    file=../../resources/data/login_invalido.csv    encoding=utf_8    dialect=excel

Resource         ../../resources/configs/qa.resource
Resource         ../../resources/steps/login_steps.resource

Test Template    Login deve ser recusado

Test Setup       Open Browser    ${URL}     ${BROWSER}
Test Teardown    Close Browser

*** Test Cases ***
Realizar login incorreto com dados do datapool
    email    senha    mensagem

*** Keywords ***
Login deve ser recusado
    [Arguments]     ${EMAIL}    ${PASSWORD}    ${MENSAGEM}

    Dado que estou na tela de login
    Quando eu informo o email "${EMAIL}"
    E eu informo a senha "${PASSWORD}"
    E eu clico no botão entrar
    Então devo ver a mensagem "${MENSAGEM}"