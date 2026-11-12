# digicon-serverest-test

Automação de testes web do [ServeRest](https://front.serverest.dev/) com **Robot Framework** e **SeleniumLibrary**, escrita em **BDD (Gherkin)** e organizada em camadas com **Page Objects**.

## Cenários automatizados

| Arquivo | O que cobre |
|---|---|
| `tests/web/cadastro.robot` | Cadastro de usuário (administrador e não administrador), em formato de tabela |
| `tests/web/login.robot` | Login com sucesso, com credenciais incorretas e sem senha |
| `tests/web/login_sem_sucesso.robot` | Quatro cenários de login sem sucesso, em formato de tabela (um deles usa Faker) |
| `tests/web/lista_de_compras.robot` | Fluxo completo em 3 testes: cadastrar administrador, fazer login e adicionar produto na lista de compras |
| `tests/web/login_datapool_test.robot` | Login sem sucesso com **datapool**: cenários lidos de `resources/data/login_invalido.csv` (DataDriver) |
| `tests/web/cadastro_usuario_adm.robot` | Cadastro de administrador com dados gerados pelo Faker (`resources/data/dados.resource`) |
| `tests/web/Cadastro_banco_dados.robot` | Cadastro de usuário gravado e consultado em banco **SQLite** (`data/massa.db`) |
| `tests/api/api_produto_test.robot` | API de produtos: cadastro (201) e erros 401, 403 e 400 |
| `tests/api/api_contrato_test.robot` | Teste de **contrato**: valida o formato da resposta de `GET /produtos` com JSON Schema |
| `tests/api/api_controle_test.robot` | Fluxo controlado (Exercício 4): preço positivo com `FOR` + `CONTINUE`, cadastro em lote com `FOR IN RANGE` |
| `tests/api/api_compra_test.robot` | Compra de um produto pela API com `GROUP` (log em etapas) e `VAR` (corpo do carrinho) |

## Estrutura do projeto

```
.
├── resources/                  # Implementação
│   ├── configs/                # Configurações globais (qa, api e db)
│   ├── data/                   # Massa de dados: builders Faker e CSV do datapool
│   ├── libraries/              # Bibliotecas Python próprias (contrato.py)
│   ├── schemas/                # JSON Schemas dos testes de contrato
│   ├── page_objects/           # Mapeamento dos elementos (locators) de cada página
│   ├── pages/                  # Ações executadas em cada página
│   └── steps/                  # Passos Gherkin (Dado / Quando / E / Então)
├── tests/                      # Cenários de teste escritos em Gherkin
│   ├── web/                    # Testes no navegador
│   └── api/                    # Testes de API e de contrato
├── screenshots/                # Prints do último fluxo de lista de compras (gerada ao rodar)
├── results/                    # Relatórios do Robot (gerada ao rodar)
└── requirements.txt
```

Cada camada só conhece a de baixo:

1. **Cenário** (`tests/`): conta a história em Gherkin.
2. **Step** (`resources/steps`): liga cada frase a uma ação.
3. **Ação** (`resources/pages`): executa a operação na tela.
4. **Objeto** (`resources/page_objects`): diz onde está cada elemento.

Se um elemento mudar na tela, o ajuste é feito em um único lugar, no page object.

## Pré-requisitos

- Python 3.10 ou superior
- Google Chrome instalado (o Selenium baixa o driver sozinho)

## Instalação

```powershell
# 1. Clonar o repositório
git clone https://github.com/Ezequiel-Kellermann-1976/digicon-serverest-test.git
cd digicon-serverest-test

# 2. Criar e ativar o ambiente virtual
python -m venv .venv
.\.venv\Scripts\Activate.ps1

# 3. Instalar as dependências
pip install -r requirements.txt
```

## Como executar

Use sempre o Python do ambiente virtual, para garantir que a SeleniumLibrary seja encontrada.

```powershell
# Todos os testes web
python -m robot -d results/ tests/web/

# Um arquivo específico
python -m robot -d results/ tests/web/lista_de_compras.robot
```

```powershell
# Testes de API e de contrato
python -m robot -d results/ tests/api/

# Só os de contrato
python -m robot -d results/ --include contrato tests/api/
```

Os relatórios (`log.html`, `report.html` e `output.xml`) são salvos em `results/`.

## Tags

Os testes usam tags para permitir execuções parciais:

| Tag | Onde | Significado |
|---|---|---|
| `e2e` | `lista_de_compras.robot` | Fluxo completo de ponta a ponta |
| `admin` | `lista_de_compras.robot` | Usuário administrador |
| `cadastro` | `lista_de_compras.robot` | Etapa de cadastro |
| `login` | `lista_de_compras.robot` | Etapa de login |
| `lista-de-compras` | `lista_de_compras.robot` | Etapa de adicionar produto |
| `sucesso` | `login.robot` | Login com sucesso |
| `negativo` | `login.robot` | Login recusado |
| `obrigatorios` | `login.robot` | Validação de campos obrigatórios |
| `api` | `tests/api/` | Testes de API |
| `contrato` | `api_contrato_test.robot` | Validação do formato da resposta |
| `produto` | `tests/api/` | Endpoint de produtos |
| `controle` | `api_controle_test.robot` | Estruturas de controle (IF, FOR) |
| `compra` / `e2e` | `api_compra_test.robot` | Compra de ponta a ponta pela API |

```powershell
# Rodar só o fluxo completo
python -m robot -d results/ --include e2e tests/web/

# Rodar só os cenários negativos de login
python -m robot -d results/ --include negativo tests/web/
```

> **Atenção:** os 3 testes de `lista_de_compras.robot` dependem um do outro (o usuário criado no primeiro é usado nos seguintes). Rode o arquivo inteiro. Filtrar só por `login` ou `lista-de-compras` faz o teste falhar, pois o usuário e a sessão não existem.

## Dados de teste e esperas

- No fluxo de lista de compras, nome, email e senha são gerados pela **FakerLibrary** a cada execução. Assim o teste pode rodar várias vezes sem erro de "email já utilizado".
- Os testes usam **esperas explícitas** (`Wait Until ...`) e não usam `Sleep`.

## Repetibilidade

O ServeRest é um ambiente público que apaga os dados periodicamente e recusa emails repetidos. Por isso nenhum teste depende de um usuário que já exista:

- `lista_de_compras.robot` e `login.robot` cadastram um usuário novo (Faker) antes dos testes.
- `cadastro.robot` usa a palavra `FAKER` na coluna EMAIL da tabela, que vira um email novo a cada execução.

Assim a suíte pode rodar várias vezes seguidas com o mesmo resultado.

## Testes de API e de contrato

- `api.resource` abre a sessão em `https://serverest.dev` e cria usuário/administrador e token via API (**RequestsLibrary**).
- Os testes de contrato usam `resources/libraries/contrato.py` (**jsonschema**) com os schemas de `resources/schemas/`. Eles conferem campos, tipos e limites da resposta, e não só o status.
- O `produto.json` usa `additionalProperties: false`. Se o ServeRest passar a devolver um campo novo, o teste falha e o schema deve ser ajustado.

## Estruturas de controle na API (Exercício 4)

Keywords em `api.resource`, reutilizadas pelos testes:

- `Cadastrar produtos em lote`: `FOR ... IN RANGE` (o laço fica na keyword, não no caso).
- `Aguardar produto disponível`: `WHILE` sempre com `limit=10`.
- `Excluir produto se possível`: `TRY / EXCEPT *400* / FINALLY` (produto em carrinho não pode ser excluído).

No `api_compra_test.robot` o `GROUP` separa o log em "Preparar massa", "Executar compra" e "Concluir e limpar". Exigem Robot Framework 7.2 ou superior (`VAR` desde 7.0, `GROUP` desde 7.2).

## Banco de dados

`resources/configs/db.resource` (**DatabaseLibrary**) cria o arquivo SQLite `data/massa.db`, grava o usuário gerado e o consulta no teste. O arquivo é ignorado pelo Git.

## Arquivos ignorados pelo Git

`results/`, `.venv/`, `screenshots/` e `data/massa.db`.

## Próximos passos

- Marcar os testes de API com as tags dos casos de teste do Azure.
- Comparar o tempo de execução entre o teste via API e via interface.
- Cobrir outros endpoints (usuários, login, carrinhos) com testes de contrato.
