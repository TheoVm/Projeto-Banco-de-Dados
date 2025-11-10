from ecommerce_connection import conectar


def cadastrar_produto(usuario, senha):
    print("\n=== CADASTRAR PRODUTO ===")
    nome = input("Nome do produto: ").strip()
    descricao = input("Descrição: ").strip()
    try:
        estoque = int(input("Quantidade em estoque: "))
        valor = float(input("Preço: "))
        id_vendedor = int(input("ID do vendedor: "))  # CORREÇÃO: Adicionado campo obrigatório
    except ValueError:
        print("Digite valores numéricos válidos para estoque, preço e ID do vendedor.")
        return
    obs = input("Observações (opcional): ").strip()

    conexao = conectar(usuario, senha)
    if not conexao:
        return

    cursor = conexao.cursor()
    try:
        # CORREÇÃO: Adicionado id_vendedor na query
        sql = """INSERT INTO produto 
                 (nome, descricao, estoque, valor, observacoes, id_vendedor) 
                 VALUES (%s, %s, %s, %s, %s, %s)"""
        dados = (nome, descricao, estoque, valor, obs, id_vendedor)
        cursor.execute(sql, dados)
        conexao.commit()
        print(f"Produto {nome} cadastrado com sucesso!")
    except Exception as e:
        conexao.rollback()
        print("Erro ao cadastrar o produto:", e)
    finally:
        cursor.close()
        conexao.close()


def listar_produtos(usuario, senha):
    conexao = conectar(usuario, senha)
    if not conexao:
        return

    cursor = conexao.cursor(dictionary=True)

    # MELHORIA: Incluir nome do vendedor e observações
    sql = """
        SELECT 
            p.id, 
            p.nome, 
            p.descricao, 
            p.estoque, 
            p.valor,
            p.observacoes,
            v.nome as vendedor_nome
        FROM produto p
        JOIN vendedor v ON p.id_vendedor = v.id
        LIMIT 20
    """
    cursor.execute(sql)
    produtos = cursor.fetchall()

    print("\n=== PRODUTOS CADASTRADOS ===")

    if not produtos:
        print("Nenhum produto cadastrado.")
    else:
        for p in produtos:
            obs = f" | Obs: {p['observacoes']}" if p['observacoes'] else ""
            print(f"ID: {p['id']} - {p['nome']} | {p['descricao']} | "
                  f"Estoque: {p['estoque']} | Preço: R$ {p['valor']:.2f} | "
                  f"Vendedor: {p['vendedor_nome']}{obs}")

    cursor.close()
    conexao.close()