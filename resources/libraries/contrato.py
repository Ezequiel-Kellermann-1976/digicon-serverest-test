"""Validação de contrato das respostas da API com JSON Schema."""
import json

from jsonschema import Draft202012Validator
from robot.api.deco import keyword

# Quantas violações aparecem na mensagem de falha (o resto vira "e mais N").
LIMITE_DE_ERROS = 20


def _carregar_schema(caminho):
    with open(caminho, encoding="utf-8") as arquivo:
        return json.load(arquivo)


def _coletar_erros(instancia, schema, origem):
    """Devolve uma lista de textos, um por violação, indicando o campo."""
    validador = Draft202012Validator(schema)
    erros = []
    for erro in sorted(validador.iter_errors(instancia), key=lambda e: list(map(str, e.absolute_path))):
        campo = ".".join(str(parte) for parte in erro.absolute_path) or "(raiz)"
        erros.append(f"{origem} -> {campo}: {erro.message}")
    return erros


@keyword("Validar Lista Produtos")
def validar_lista_produtos(resposta, schema_lista, schema_produto):
    """Valida a resposta de ``GET /produtos`` contra o contrato.

    Primeiro confere o envelope (``quantidade`` e ``produtos``) com ``schema_lista``.
    Depois confere cada produto da lista com ``schema_produto``.
    Falha listando todas as violações encontradas (até ``LIMITE_DE_ERROS``).
    """
    erros = _coletar_erros(resposta, _carregar_schema(schema_lista), "lista")

    # Só olha os itens se o envelope estiver correto.
    if not erros:
        schema = _carregar_schema(schema_produto)
        for posicao, produto in enumerate(resposta["produtos"]):
            erros += _coletar_erros(produto, schema, f"produtos[{posicao}]")

    if erros:
        mostrados = erros[:LIMITE_DE_ERROS]
        resto = len(erros) - len(mostrados)
        mensagem = f"{len(erros)} violação(ões) de contrato:\n" + "\n".join(mostrados)
        if resto > 0:
            mensagem += f"\n... e mais {resto}"
        raise AssertionError(mensagem)
