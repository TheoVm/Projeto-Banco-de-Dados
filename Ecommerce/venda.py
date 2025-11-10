from ecommerce_connection import conectar
from datetime import datetime

def registrar_venda(usuario, senha):
    print("\n=== REGISTRAR VENDA ===")
    try:
        id_produto = int(input("ID do produto: "))
        id_transportadora = int(input("ID da transportadora: "))
        id_vendedor = int(input("ID do vendedor: "))
        id_cliente = int(input("ID do cliente: "))
    except:
        print("Os IDs devem ser números.")
        return

    destino = input("Destino da entrega: ").strip()

    agora = datetime.now()
    data = agora.date()
    hora = agora.time()

    conexao = conectar(usuario, senha)
    if not conexao:
        return

    cursor = conexao.cursor()
    try:
        sql = """INSERT INTO venda 
            (id_produto, id_transportadora, id_vendedor, id_cliente, destino, data, hora)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """
        cursor.execute(sql, (id_produto, id_transportadora, id_vendedor, id_cliente, destino, data, hora))
        conexao.commit()
        print("Venda registrada")
    except Exception as e:
        conexao.rollback()
        print("Erro ao registrar venda:", e)
    finally:
        cursor.close()
        conexao.close()