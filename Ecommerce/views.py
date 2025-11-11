from ecommerce_connection import conectar


def ver_vendas_vendedor(usuario, senha):
    conexao = conectar(usuario, senha)
    if not conexao:
        return

    cursor = conexao.cursor(dictionary=True)
    cursor.execute("SELECT * FROM view_vendas_vendedor ORDER BY total_vendas DESC")
    dados = cursor.fetchall()

    print("\n" + "=" * 70)
    print("           VENDAS POR VENDEDOR")
    print("=" * 70)

    if not dados:
        print("Nenhum dado encontrado.")
    else:
        for d in dados:
            print(f"\nVendedor: {d['nome_vendedor']} (ID: {d['id_vendedor']})")
            print(f"  Total em vendas: R$ {d['total_vendas']:.2f}")
            print(f"  Total de transações: {d['total_transacoes']}")
            print("-" * 70)

    cursor.close()
    conexao.close()


def ver_clientes_especiais(usuario, senha):
    conexao = conectar(usuario, senha)
    if not conexao:
        return

    cursor = conexao.cursor(dictionary=True)
    cursor.execute("SELECT * FROM view_clientes_especiais ORDER BY cashback DESC")
    dados = cursor.fetchall()

    print("\n" + "=" * 70)
    print("           CLIENTES ESPECIAIS")
    print("=" * 70)

    if not dados:
        print("Nenhum cliente especial encontrado.")
    else:
        for d in dados:
            print(f"\nCliente: {d['nome']} (ID: {d['id_cliente']})")
            print(f"  Cashback disponível: R$ {d['cashback']:.2f}")
            print(f"  Total de compras: {d['total_compras']}")
            print("-" * 70)

    cursor.close()
    conexao.close()


def ver_produtos_vendidos(usuario, senha):
    conexao = conectar(usuario, senha)
    if not conexao:
        return

    cursor = conexao.cursor(dictionary=True)
    cursor.execute("""
        SELECT * FROM view_produtos_vendidos 
        ORDER BY quantidade_vendida DESC
    """)
    dados = cursor.fetchall()

    print("\n" + "=" * 80)
    print("                    PRODUTOS VENDIDOS")
    print("=" * 80)

    if not dados:
        print("Nenhum produto foi vendido ainda.")
    else:
        for d in dados:
            print(f"\nProduto: {d['nome_produto']} (ID: {d['id_produto']})")
            print(f"  Vendedor: {d['nome_vendedor']}")
            print(f"  Quantidade vendida: {d['quantidade_vendida']}")
            print(f"  Valor total: R$ {d['valor_total']:.2f}")
            print("-" * 80)

    cursor.close()
    conexao.close()


def ver_funcionarios_especiais(usuario, senha):
    conexao = conectar(usuario, senha)
    if not conexao:
        return

    cursor = conexao.cursor(dictionary=True)
    cursor.execute("SELECT * FROM view_funcionarios_especiais ORDER BY bonus DESC")
    dados = cursor.fetchall()

    print("\n" + "=" * 80)
    print(" " * 25 + "FUNCIONÁRIOS ESPECIAIS")
    print("=" * 80)

    if not dados:
        print("Nenhum funcionário especial encontrado.")
    else:
        for d in dados:
            print(f"\nVendedor: {d['nome_vendedor']} (ID: {d['id_vendedor']})")
            print(f"  Causa Social: {d['causa_social']}")
            print(f"  Tipo: {d['tipo']}")
            print(f"  Salário Base: R$ {d['salario']:.2f}")
            print(f"  Bônus: R$ {d['bonus']:.2f}")
            print(f"  Salário Total: R$ {d['salario_total']:.2f}")
            print("-" * 80)

    cursor.close()
    conexao.close()
