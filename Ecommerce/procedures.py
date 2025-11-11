from ecommerce_connection import conectar
from mysql.connector import Error


def executar_reajuste(usuario, senha):
    print("\n=== REAJUSTE SALARIAL ===")
    conexao = conectar(usuario, senha)
    if not conexao:
        return

    cursor = conexao.cursor()
    try:
        perc = float(input("Percentual do reajuste: "))
        tipo = input("Categoria do vendedor: ").strip()

        cursor.callproc("reajuste", [perc, tipo])

        for resultado in cursor.stored_results():
            for linha in resultado.fetchall():
                print(linha[0])

        conexao.commit()
    except ValueError:
        print("Percentual deve ser um número.")
    except Error as e:
        if e.errno == 1370:
            print("\n PERMISSÃO NEGADA!")
            print("  Você não tem permissão para executar esta procedure.")
            print(" Apenas CEOs podem executar reajustes salariais.")
        else:
            print(f" Erro ao executar o reajuste: {e}")
    except Exception as e:
        print(f" Erro inesperado: {e}")
    finally:
        cursor.close()
        conexao.close()


def executar_sorteio(usuario, senha):
    print("\n=== SORTEIO DE PRÊMIO ===")
    conexao = conectar(usuario, senha)
    if not conexao:
        return

    cursor = conexao.cursor()
    try:
        cursor.callproc("sorteio")

        for resultado in cursor.stored_results():
            for linha in resultado.fetchall():
                print(f" Cliente sorteado: {linha[0]}")
                print(f" Valor do prêmio: R$ {linha[1]:.2f}")

        conexao.commit()
    except Error as e:
        if e.errno == 1370:
            print("\n PERMISSÃO NEGADA!")
            print(" Você não tem permissão para executar esta procedure.")
            print(" Apenas CEOs podem executar sorteios.")
        else:
            print(f" Erro na execução do sorteio: {e}")
    except Exception as e:
        print(f"Erro inesperado: {e}")
    finally:
        cursor.close()
        conexao.close()


def executar_estatisticas(usuario, senha):
    print("\n=== ESTATÍSTICAS DE VENDAS ===")
    conexao = conectar(usuario, senha)
    if not conexao:
        return

    cursor = conexao.cursor()
    try:
        cursor.callproc("estatisticas")

        print("\n" + "=" * 80)
        for resultado in cursor.stored_results():
            dados = resultado.fetchall()
            if dados:
                for linha in dados:
                    tipo = linha[0]
                    produto = linha[1]
                    qtd = linha[2]
                    vendedor = linha[3]
                    valor = linha[4]
                    mes_maior = linha[5] if linha[5] else "N/A"
                    mes_menor = linha[6] if linha[6] else "N/A"

                    print(f"\n{'─' * 80}")
                    print(f" {tipo.upper()}")
                    print(f"{'─' * 80}")
                    print(f"Produto: {produto}")
                    print(f"Vendedor: {vendedor}")
                    print(f"Quantidade vendida: {qtd}")
                    print(f"Valor arrecadado: R$ {valor:.2f}")
                    print(f"Mês com mais vendas: {mes_maior}")
                    print(f"Mês com menos vendas: {mes_menor}")

        print(f"\n{'=' * 80}\n")
        conexao.commit()
    except Error as e:
        if e.errno == 1370:
            print("\n PERMISSÃO NEGADA!")
            print("  Você não tem permissão para executar esta procedure.")
            print(" Apenas CEOs podem visualizar estatísticas.")
        else:
            print(f" Erro ao executar estatísticas: {e}")
    except Exception as e:
        print(f" Erro inesperado: {e}")
    finally:
        cursor.close()
        conexao.close()