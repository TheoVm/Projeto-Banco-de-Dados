import mysql.connector

def conectar(usuario, senha):
    try:
        conexao = mysql.connector.connect(
            host="localhost",
            user= usuario,
            password= senha,
            database="ECOMMERCE"
        )
        if conexao.is_connected():
            print("Conectado com sucesso.")
            return conexao
    except mysql.connector.Error as erro:
        print("Erro ao estabelecer conexÃ£o ao MySQL:", erro)
        return None