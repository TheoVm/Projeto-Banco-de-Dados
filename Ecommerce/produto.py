from ecommerce_connection import conectar
from mysql.connector import Error


def cadastrar_produto(usuario, senha):
    print("\n=== CADASTRAR PRODUTO ===")
    nome = input("Nome do produto: ").strip()
    descricao = input("Descrição: ").strip()
    try:
        estoque = int(input("Quantidade em estoque: "))
        valor = float(input("Preço: "))
        id_vendedor = int(input("ID do vendedor: "))
    except ValueError:
        print(" Digite valores numéricos válidos para estoque, preço e ID do vendedor.")
        return
    obs = input("Observações (opcional): ").strip()

    conexao = conectar(usuario, senha)
    if not conexao:
        return

    cursor = conexao.cursor()
    try:
        sql = """INSERT INTO produto 
                 (nome, descricao, estoque, valor, observacoes, id_vendedor) 
                 VALUES (%s, %s, %s, %s, %s, %s)"""
        dados = (nome, descricao, estoque, valor, obs, id_vendedor)
        cursor.execute(sql, dados)
        conexao.commit()
        print(f" Produto {nome} cadastrado com sucesso!")
    except Error as e:
        conexao.rollback()
        if e.errno == 1142:
            print("\n PERMISSÃO NEGADA!")
            print(" Você não tem permissão para cadastrar produtos.")
            print(" Apenas gerentes e CEOs podem cadastrar produtos.")
        elif e.errno == 1452:
            print("\n ERRO DE CHAVE ESTRANGEIRA!")
            print(" O ID do vendedor informado não existe.")
            print(" Verifique se o vendedor está cadastrado no sistema.")
        else:
            print(f" Erro ao cadastrar o produto: {e}")
    except Exception as e:
        conexao.rollback()
        print(f" Erro inesperado: {e}")
    finally:
        cursor.close()
        conexao.close()


def listar_produtos(usuario, senha):
    conexao = conectar(usuario, senha)
    if not conexao:
        return

    cursor = conexao.cursor(dictionary=True)

    try:
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
            print("  enhum produto cadastrado.")
        else:
            print(f"\n{'─' * 100}")
            for p in produtos:
                obs = f" | Obs: {p['observacoes']}" if p['observacoes'] else ""
                print(f"ID: {p['id']} - {p['nome']} | {p['descricao']} | "
                      f"Estoque: {p['estoque']} | Preço: R$ {p['valor']:.2f} | "
                      f"Vendedor: {p['vendedor_nome']}{obs}")
            print(f"{'─' * 100}\n")

    except Error as e:
        if e.errno == 1142:
            print("\ PERMISSÃO NEGADA!")
            print("  Você não tem permissão para listar produtos.")
            print(" Apenas gerente ou CEO.")
        else:
            print(f" Erro ao listar produtos: {e}")
    except Exception as e:
        print(f" Erro inesperado: {e}")
    finally:
        cursor.close()
        conexao.close()