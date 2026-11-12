*** Settings ***
Documentation    Testes de controle da API: seleção (IF), repetição (FOR) e
...              limpeza com TRY/EXCEPT/FINALLY (Exercício 4).

Resource         ../../resources/configs/api.resource

Suite Setup      Abrir sessão na API
Suite Teardown   Delete All Sessions

*** Test Cases ***
Todos os produtos em estoque têm preço positivo
    [Tags]    api    controle    produtos
    ${resp}=    GET On Session
    ...    serverest
    ...    /produtos
    ...    expected_status=200

    VAR    ${produtos}    ${resp.json()}[produtos]
    VAR    ${verificados}    ${0}

    FOR    ${produto}    IN    @{produtos}
        IF    ${produto}[quantidade] == 0    CONTINUE
        Should Be True
        ...    ${produto}[preco] > 0
        ...    Produto ${produto}[nome] com preço inválido
        ${verificados}=    Evaluate    ${verificados} + 1
    END

    Should Be True
    ...    ${verificados} > 0
    ...    Nenhum produto com estoque disponível foi encontrado

Cadastrar vários produtos com sucesso
    [Tags]    api    controle    produtos
    ${headers}=    Criar administrador e obter token

    VAR    ${total}    ${5}

    ${ids}=    Cadastrar produtos em lote    ${headers}    ${total}
    ${cadastrados}=    Get Length    ${ids}

    Should Be Equal As Integers
    ...    ${cadastrados}
    ...    ${total}
    ...    Foram cadastrados ${cadastrados} produtos, mas o esperado era ${total}

    FOR    ${id}    IN    @{ids}
        Aguardar produto disponível    ${id}
        Excluir produto se possível    ${id}    ${headers}
    END
