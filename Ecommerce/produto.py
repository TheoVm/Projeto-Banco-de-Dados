from ecommerce_connection import conectar

def cadastrar_produto(usuario, senha):
    print("\n=== CADASTRAR PRODUTO ===")
    nome = input("Nome do produto: ").strip()
    descricao = input("Descrição: ").strip()
    try:
        estoque = int(input("Quantidade em estoque: "))
        valor = float(input("Preço: "))
    except:
        print("Digite valores numéricos válidos para estoque e preço.")
        return
    obs = input("Observações (opcional): ").strip()

    conexao = conectar(usuario, senha)
    if not conexao:
        return

    cursor = conexao.cursor()
    try:
        sql = "INSERT INTO produto (nome, descricao, estoque, valor, observacoes) VALUES (%s, %s, %s, %s, %s)"
        dados = (nome, descricao, estoque, valor, obs)
        cursor.execute(sql, dados)
        conexao.commit()
        print(f"Produto {nome} cadastrado!")
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

    cursor.execute("SELECT id, nome, descricao, estoque, valor FROM produto LIMIT 10;")
    produtos = cursor.fetchall()
    print("\n=== PRODUTOS CADASTRADOS ===")

    if not produtos:
        print("Nenhum produto cadastrado.")
    else:
        for p in produtos:
            print(f"ID: {p['id']} - {p['nome']} | {p['descricao']} | Estoque: {p['estoque']} | Preço: R$ {p['valor']:.2f}")

    cursor.close()
    conexao.close()