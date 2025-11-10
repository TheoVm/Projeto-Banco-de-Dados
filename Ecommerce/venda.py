from ecommerce_connection import conectar
from datetime import datetime


def registrar_venda(usuario, senha):
    print("\n=== REGISTRAR VENDA ===")
    try:
        id_cliente = int(input("ID do cliente: "))
        id_vendedor = int(input("ID do vendedor: "))
        id_transportadora = int(input("ID da transportadora: "))
    except ValueError:
        print("Os IDs devem ser números inteiros.")
        return

    destino = input("Destino da entrega: ").strip()

    try:
        frete = float(input("Valor do frete: "))  # CORREÇÃO: Campo obrigatório
    except ValueError:
        print("O valor do frete deve ser um número.")
        return

    agora = datetime.now()
    data = agora.date()
    hora = agora.time()

    conexao = conectar(usuario, senha)
    if not conexao:
        return

    cursor = conexao.cursor()
    try:
        # Primeiro, registra a venda
        sql_venda = """INSERT INTO venda 
            (id_transportadora, id_cliente, id_vendedor, destino, data, hora, frete)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """
        cursor.execute(sql_venda, (id_transportadora, id_cliente, id_vendedor, destino, data, hora, frete))

        id_venda = cursor.lastrowid

        # Agora registra os itens da venda
        print("\n=== ITENS DA VENDA ===")
        while True:
            try:
                id_produto = int(input("ID do produto (0 para finalizar): "))
                if id_produto == 0:
                    break
                quantidade = int(input("Quantidade: "))

                sql_item = """INSERT INTO item_venda (id_venda, id_produto, quantidade)
                             VALUES (%s, %s, %s)"""
                cursor.execute(sql_item, (id_venda, id_produto, quantidade))
            except ValueError:
                print("Digite valores numéricos válidos.")
                continue
            except Exception as e:
                print(f"Erro ao adicionar item: {e}")
                continue

        conexao.commit()
        print(f"\nVenda #{id_venda} registrada com sucesso!")

        # Chama o procedimento para atualizar estoque
        cursor.callproc('venda', [id_venda])
        conexao.commit()

    except Exception as e:
        conexao.rollback()
        print("Erro ao registrar venda:", e)
    finally:
        cursor.close()
        conexao.close()


def listar_vendas(usuario, senha):
    """Lista as últimas vendas registradas"""
    conexao = conectar(usuario, senha)
    if not conexao:
        return

    cursor = conexao.cursor(dictionary=True)

    sql = """
        SELECT 
            v.id,
            v.data,
            v.hora,
            c.nome as cliente,
            vd.nome as vendedor,
            t.nome as transportadora,
            v.destino,
            v.frete,
            COUNT(iv.id_produto) as qtd_itens
        FROM venda v
        JOIN cliente c ON v.id_cliente = c.id
        JOIN vendedor vd ON v.id_vendedor = vd.id
        JOIN transportadora t ON v.id_transportadora = t.id
        LEFT JOIN item_venda iv ON v.id = iv.id_venda
        GROUP BY v.id
        ORDER BY v.data DESC, v.hora DESC
        LIMIT 15
    """

    cursor.execute(sql)
    vendas = cursor.fetchall()

    print("\n=== ÚLTIMAS VENDAS ===")
    if not vendas:
        print("Nenhuma venda registrada.")
    else:
        for venda in vendas:
            print(f"Venda #{venda['id']} - {venda['data']} {venda['hora']}")
            print(f"  Cliente: {venda['cliente']} | Vendedor: {venda['vendedor']}")
            print(f"  Transportadora: {venda['transportadora']} | Destino: {venda['destino']}")
            print(f"  Frete: R$ {venda['frete']:.2f} | Itens: {venda['qtd_itens']}\n")

    cursor.close()
    conexao.close()