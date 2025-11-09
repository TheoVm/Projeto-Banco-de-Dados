from ecommerce_connection import conectar

def ver_vendas_vendedor():
    conexao = conectar()
    if not conexao:
        return
    cursor = conexao.cursor()
    cursor.execute("SELECT * FROM view_vendas_vendedor")
    dados = cursor.fetchall()
    print("\n=== VENDAS POR VENDEDOR ===")
    for d in dados:
        print(d)
    cursor.close()
    conexao.close()

def ver_clientes_especiais():
    conexao = conectar()
    if not conexao:
        return
    cursor = conexao.cursor()
    cursor.execute("SELECT * FROM view_clientes_especiais")
    dados = cursor.fetchall()
    print("\n=== CLIENTES ESPECIAIS ===")
    for d in dados:
        print(d)
    cursor.close()
    conexao.close()
