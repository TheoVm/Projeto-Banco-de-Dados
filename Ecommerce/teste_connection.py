from ecommerce_connection import conectar

def main():
    usuario = "ceo_ecommerce"
    senha = "Ceo123456"
    conexao = conectar(usuario, senha)
    if conexao:
        cursor = conexao.cursor()
        cursor.execute("SHOW TABLES;")
        tabelas = cursor.fetchall()
        print("\nTabelas no banco de dados:")
        for t in tabelas:
            print("-", t[0])
        cursor.close()
        conexao.close()

if __name__ == "__main__":
    main()