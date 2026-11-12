*** Settings ***
Documentation    Sessão, usuários e token para os testes de API do ServeRest.
...              A massa nasce pela API (sem passar pela tela) e nenhuma senha
...              fica fixa no código: tudo vem dos construtores de dados.

Library          RequestsLibrary
Library          Collections
Resource         ../data/dados.resource

*** Variables ***
${API}    https://serverest.dev

*** Keywords ***
Abrir sessão na API
    Create Session    serverest    ${API}    verify=${True}

Criar usuário com credenciais
    [Documentation]    Cadastra um usuário pela API, faz login e devolve o usuário
    ...                e os cabeçalhos com o token. O token já vem com o prefixo Bearer.
    [Arguments]    ${administrador}=true

    ${usuario}=    Gerar usuário
    Set To Dictionary    ${usuario}    administrador=${administrador}

    POST On Session
    ...    serverest
    ...    /usuarios
    ...    json=${usuario}
    ...    expected_status=201

    ${login}=    Create Dictionary
    ...    email=${usuario}[email]
    ...    password=${usuario}[password]

    ${resp_login}=    POST On Session
    ...    serverest
    ...    /login
    ...    json=${login}
    ...    expected_status=200

    ${headers}=    Create Dictionary
    ...    Authorization=${resp_login.json()}[authorization]

    RETURN    ${usuario}    ${headers}

Criar administrador e obter token
    ${usuario}    ${headers}=    Criar usuário com credenciais    administrador=true
    RETURN    ${headers}

Criar usuário comum e obter token
    ${usuario}    ${headers}=    Criar usuário com credenciais    administrador=false
    RETURN    ${headers}

Cadastrar produtos em lote
    [Documentation]    Cadastra a quantidade informada de produtos novos e devolve
    ...                a lista com os ids criados. O laço fica aqui, não no caso de teste.
    [Arguments]    ${headers}    ${total}

    VAR    @{ids}

    FOR    ${i}    IN RANGE    ${total}
        ${produto}=    Gerar produto
        ${resp}=    POST On Session
        ...    serverest
        ...    /produtos
        ...    json=${produto}
        ...    headers=${headers}
        ...    expected_status=201
        Append To List    ${ids}    ${resp.json()}[_id]
    END

    RETURN    ${ids}

Aguardar produto disponível
    [Documentation]    Consulta o produto até a API devolver 200. O WHILE tem limite
    ...                de 10 tentativas, então nunca fica em laço infinito.
    [Arguments]    ${id}

    WHILE    True    limit=10
    ...    on_limit_message=Produto ${id} não ficou disponível
        ${resp}=    GET On Session
        ...    serverest
        ...    /produtos/${id}
        ...    expected_status=any
        IF    ${resp.status_code} == 200    BREAK
        Sleep    1s
    END

Excluir produto se possível
    [Documentation]    Limpeza: exclui o produto. Se ele estiver em um carrinho a API
    ...                responde 400; o EXCEPT captura só esse erro e o FINALLY sempre roda.
    [Arguments]    ${id}    ${headers}

    TRY
        DELETE On Session
        ...    serverest
        ...    /produtos/${id}
        ...    headers=${headers}
    EXCEPT    *400*    type=GLOB
        Log    Produto em carrinho, exclusão adiada    WARN
    FINALLY
        Log    Limpeza do produto ${id} avaliada
    END
