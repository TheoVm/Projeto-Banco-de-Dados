from ecommerce_connection import conectar

def cadastrar_produto():
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

    conexao = conectar()
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

def listar_produtos():
    conexao = conectar()
    if not conexao:
        return
    cursor = conexao.cursor()
    cursor.execute("SELECT id, nome, descricao, estoque, valor FROM produto LIMIT 10;")
    produtos = cursor.fetchall()
    print("\n=== PRODUTOS CADASTRADOS ===")
    for p in produtos:
        print(f"{p[0]} - {p[1]} | {p[2]} | Estoque: {p[3]} | Preço: R$ {p[4]:.2f}")
    cursor.close()
    conexao.close()