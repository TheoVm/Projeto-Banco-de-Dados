import mysql.connector
from mysql.connector import Error
import os

def get_sql_path(filename):
    current_dir = os.path.dirname(os.path.abspath(__file__))
    sql_dir = os.path.join(os.path.dirname(current_dir), 'sql ecommerce')
    filepath = os.path.join(sql_dir, filename)
    return filepath
def execute_sql_file(connection, filepath):
    cursor = connection.cursor()
    current_delimiter = ';'
    sql_command = ''

    try:
        with open(filepath, 'r', encoding='utf-8') as file:

            print("Executando script SQL completo...")

            for line in file:
                line = line.strip()
                if not line or line.startswith('--'):
                    continue
                if line.upper().startswith('DELIMITER'):
                    parts = line.split()
                    if len(parts) > 1:
                        current_delimiter = parts[1]
                    continue
                sql_command += line + '\n'
                if line.endswith(current_delimiter):

                    command_to_execute = sql_command.rstrip()
                    command_to_execute = command_to_execute.rstrip(
                        current_delimiter).strip()

                    if command_to_execute:
                        try:
                            cursor.execute(command_to_execute)
                            if cursor.description is not None:
                                cursor.fetchall()

                        except Error as err:
                            print(f" Erro ao executar comando: {command_to_execute[:80]}...")
                            raise err
                    sql_command = ""

        connection.commit()
        print(f" Arquivo SQL '{filepath}' executado com sucesso!")
        return True

    except Error as err:
        print(f"Erro final ao executar script SQL: '{err}'")
        return False
    except FileNotFoundError:
        print(f"Arquivo não encontrado: '{filepath}'")
        print("Verifique se o arquivo 'Ecommerce.sql' está na pasta correta (../sql ecommerce/)")
        return False
    finally:
        cursor.close()

def create_database_from_file(host, user, password, filename='Ecommerce.sql'):
    connection = None
    try:
        filepath = get_sql_path(filename)
        print(f"Usando arquivo: {filepath}")
        connection = mysql.connector.connect(
            host=host,
            user=user,
            password=password
        )

        if connection.is_connected():
            print("Conectado ao MySQL Server")
            success = execute_sql_file(connection, filepath)
            return success

    except Error as err:
        print(f"Erro de conexão: '{err}'")
        return False
    finally:
        if connection and connection.is_connected():
            connection.close()
            print("Conexão encerrada.")


def drop_database(host, user, password, db_name):
    print(f"\nTentando deletar o banco de dados '{db_name}'...")

    conexao = None
    try:
        conexao = mysql.connector.connect(
            host=host,
            user=user,  # Deve ser 'root'
            password=password  # Deve ser a senha do root
        )

        if conexao.is_connected():
            cursor = conexao.cursor()

            print("Deletando usuários do ECOMMERCE...")
            cursor.execute("DROP USER IF EXISTS 'ceo_ecommerce'@'%'")
            cursor.execute("DROP USER IF EXISTS 'gerente_ecommerce'@'%'")
            cursor.execute("DROP USER IF EXISTS 'funcionario_ecommerce'@'%'")

            cursor.execute(f"DROP DATABASE IF EXISTS {db_name}")
            conexao.commit()

            print(f"Banco de dados '{db_name}' deletado com sucesso.")

            cursor.close()
            return True
        else:
            print("Erro ao conectar ao servidor MySQL.")
            return False

    except Error as erro:
        print(f"Erro ao deletar o banco de dados: {erro}")
        return False

    finally:
        if conexao and conexao.is_connected():
            conexao.close()