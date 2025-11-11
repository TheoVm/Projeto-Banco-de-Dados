from ecommerce_connection import conectar
from mysql.connector import Error
from datetime import datetime

def cadastrar_cliente(usuario, senha):
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

    conexao = conectar(usuario, senha)
    if not conexao:
        return

    cursor = conexao.cursor()
    try:
        sql = "INSERT INTO cliente (nome, idade, sexo, nascimento) VALUES (%s, %s, %s, %s)"
        dados = (nome, idade, sexo, nasc)
        cursor.execute(sql, dados)
        conexao.commit()
        print(f"Cliente {nome} cadastrado com êxito.")
    except Error as e:
        conexao.rollback()
        if e.errno == 1142:
            print("\n[PERMISSAO NEGADA]")
            print("Voce nao tem permissao para cadastrar clientes.")
            print("Apenas gerentes e CEOs podem cadastrar clientes.")
        else:
            print(f"Erro ao cadastrar o cliente: {e}")
    except Exception as e:
        conexao.rollback()
        print(f"Erro inesperado: {e}")
    finally:
        cursor.close()
        conexao.close()

def listar_clientes(usuario, senha):
    conexao = conectar(usuario, senha)
    if not conexao:
        return

    cursor = conexao.cursor(dictionary=True)

    try:
        sql = """
            SELECT 
                id, 
                nome, 
                idade, 
                sexo, 
                DATE_FORMAT(nascimento, '%d-%m-%Y') as nasc_formatado
            FROM cliente 
            LIMIT 100;
        """
        cursor.execute(sql)

        resultados = cursor.fetchall()

        print("\n=== LISTA DE CLIENTES ===")

        if not resultados:
            print("Nenhum cliente cadastrado.")
        else:
            for cliente in resultados:
                print(f"ID: {cliente['id']} | Nome: {cliente['nome']} | {cliente['sexo']} | {cliente['idade']} anos | Nasc: {cliente['nasc_formatado']}")

    except Error as e:
        if e.errno == 1142:
            print("\n[PERMISSAO NEGADA]")
            print("Voce nao tem permissao para listar clientes.")
            print("Contate um gerente ou CEO.")
        else:
            print(f"Erro ao listar clientes: {e}")
    except Exception as e:
        print(f"Erro inesperado: {e}")
    finally:
        cursor.close()
        conexao.close()