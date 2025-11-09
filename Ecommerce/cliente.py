from ecommerce_connection import conectar
from datetime import datetime

def cadastrar_cliente():
    print("\n=== CADASTRAR CLIENTE ===")
    nome = input("Nome: ").strip()
    sexo = input("Sexo (M/F/O): ").strip().upper()
    nascimento = input("Data de nascimento (DD-MM-AAAA): ").strip()

    if sexo not in ['M', 'F', 'O']:
        print("Valor inválido. Digite apenas M, F ou O.")
        return

    try:
        nasc = datetime.strptime(nascimento, "%d-%m-%Y").date()
        idade = datetime.now().year - nasc.year
    except:
        print("Data inválida. Use o formato certo (DD-MM-AAAA).")
        return

    conexao = conectar()
    if not conexao:
        return

    cursor = conexao.cursor()
    try:
        sql = "INSERT INTO cliente (nome, idade, sexo, nascimento) VALUES (%s, %s, %s, %s)"
        dados = (nome, idade, sexo, nasc)
        cursor.execute(sql, dados)
        conexao.commit()
        print(f"Cliente {nome} cadastrado com êxito.")
    except Exception as e:
        conexao.rollback()
        print("Erro ao cadastrar o cliente:", e)
    finally:
        cursor.close()
        conexao.close()

def listar_clientes():
    conexao = conectar()
    if not conexao:
        return

    cursor = conexao.cursor(dictionary=True)

    sql = """
        SELECT 
            id, 
            nome, 
            idade, 
            sexo, 
            DATE_FORMAT(nascimento, '%d-%m-%Y') as nasc_formatado
        FROM cliente 
        LIMIT 15;
    """
    cursor.execute(sql)

    resultados = cursor.fetchall()

    print("\n=== LISTA DE CLIENTES ===")

    if not resultados:
        print("Nenhum cliente cadastrado.")
    else:
        for cliente in resultados:
            print(f"ID: {cliente['id']} | Nome: {cliente['nome']} | {cliente['sexo']} | {cliente['idade']} anos | Nasc: {cliente['nasc_formatado']}")

    cursor.close()
    conexao.close()