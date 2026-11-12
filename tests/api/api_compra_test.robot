*** Settings ***
Documentation    Compra de um produto pela API, com o log organizado em grupos
...              (GROUP) e o corpo do carrinho montado com VAR (Exercício 4).

Resource         ../../resources/configs/api.resource

Suite Setup      Abrir sessão na API
Suite Teardown   Delete All Sessions

*** Test Cases ***
Compra de um produto pela API
    [Tags]    api    e2e    compra
    GROUP    Preparar massa
        ${headers}=    Criar administrador e obter token
        ${produto}=    Gerar produto
        ${resp}=    POST On Session
        ...    serverest
        ...    /produtos
        ...    json=${produto}
        ...    headers=${headers}
        ...    expected_status=201
        VAR    ${id}    ${resp.json()}[_id]
        Aguardar produto disponível    ${id}
    END

    GROUP    Executar compra
        VAR    &{item}    idProduto=${id}    quantidade=${1}
        VAR    @{itens}    ${item}
        VAR    &{carrinho}    produtos=${itens}
        POST On Session
        ...    serverest
        ...    /carrinhos
        ...    json=${carrinho}
        ...    headers=${headers}
        ...    expected_status=201
    END

    GROUP    Concluir e limpar
        DELETE On Session
        ...    serverest
        ...    /carrinhos/concluir-compra
        ...    headers=${headers}
        ...    expected_status=200
        Excluir produto se possível    ${id}    ${headers}
    END
