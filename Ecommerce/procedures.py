from ecommerce_connection import conectar

def executar_reajuste(usuario, senha):
    conexao = conectar(usuario, senha)
    if not conexao:
        return
    cursor = conexao.cursor()
    try:
        perc = float(input("Percentual do reajuste: "))
        tipo = input("Categoria do vendedor: ").strip()
        cursor.callproc("reajuste", [perc, tipo])
        for r in cursor.stored_results():
            print(r.fetchall())
    except Exception as e:
        print("Erro ao executar o reajuste:", e)
    finally:
        cursor.close()
        conexao.close()

def executar_sorteio(usuario, senha):
    conexao = conectar(usuario, senha)
    if not conexao:
        return
    cursor = conexao.cursor()
    try:
        cursor.callproc("sorteio")
        for r in cursor.stored_results():
            for linha in r.fetchall():
                print("Cliente sorteado:", linha)
    except Exception as e:
        print("Erro na execução do sorteio:", e)
    finally:
        cursor.close()
        conexao.close()