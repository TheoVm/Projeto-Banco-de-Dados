from ecommerce_connection import conectar

def main():
    conexao = conectar()
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