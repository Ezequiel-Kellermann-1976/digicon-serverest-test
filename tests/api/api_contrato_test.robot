*** Settings ***
Documentation    Testes de contrato - Consulta de produtos (ServeRest).
...              Conferem o FORMATO da resposta (campos, tipos e limites) usando
...              JSON Schema, e não apenas o status ou a mensagem.

Library          ../../resources/libraries/contrato.py
Resource         ../../resources/configs/api.resource

Suite Setup      Abrir sessão na API
Suite Teardown   Delete All Sessions

*** Variables ***
${SCHEMA_LISTA}      ${CURDIR}/../../resources/schemas/consulta_produtos.json
${SCHEMA_PRODUTO}    ${CURDIR}/../../resources/schemas/produto.json

*** Test Cases ***
Consulta de produtos respeita o contrato
    [Tags]    api    contrato    produto
    ${resp}=    GET On Session
    ...    serverest
    ...    /produtos
    ...    expected_status=200

    Validar Lista Produtos
    ...    ${resp.json()}
    ...    ${SCHEMA_LISTA}
    ...    ${SCHEMA_PRODUTO}

Consulta de produtos com filtro respeita o contrato
    [Tags]    api    contrato    produto
    ${filtros}=    Create Dictionary
    ...    quantidade=0

    ${resp}=    GET On Session
    ...    serverest
    ...    /produtos
    ...    params=${filtros}
    ...    expected_status=200

    Validar Lista Produtos
    ...    ${resp.json()}
    ...    ${SCHEMA_LISTA}
    ...    ${SCHEMA_PRODUTO}
