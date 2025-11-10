import mysql.connector
from mysql.connector import Error
import os


# --- Funções Auxiliares (Não alteradas) ---

def get_sql_path(filename):
    """
    Retorna o caminho completo do arquivo SQL, assumindo a estrutura de pastas do seu projeto.
    """
    current_dir = os.path.dirname(os.path.abspath(__file__))
    # Volta um nível para a pasta 'Projeto-Banco-de-Dados', e entra em 'sql ecommerce'
    sql_dir = os.path.join(os.path.dirname(current_dir), 'sql ecommerce')
    filepath = os.path.join(sql_dir, filename)
    return filepath


def execute_sql_file(connection, filepath):
    """
    Executa um arquivo SQL completo de forma robusta, lidando com DELIMITERs e comandos
    de múltiplas linhas, resolvendo o erro de sintaxe 'DECLARE...'.
    """
    cursor = connection.cursor()

    # Delimitador padrão do MySQL
    current_delimiter = ';'

    # Variável que armazena o comando SQL em construção
    sql_command = ''

    try:
        with open(filepath, 'r', encoding='utf-8') as file:

            print("Executando script SQL completo...")

            for line in file:
                line = line.strip()
                if not line or line.startswith('--'):
                    continue  # Ignora linhas vazias ou comentários

                # 1. Checa por mudança de DELIMITER
                if line.upper().startswith('DELIMITER'):
                    parts = line.split()
                    if len(parts) > 1:
                        current_delimiter = parts[1]
                    continue

                # 2. Constrói o comando SQL
                sql_command += line + '\n'

                # 3. Verifica se a linha termina com o delimitador atual
                if line.endswith(current_delimiter):

                    command_to_execute = sql_command.rstrip()  # Remove espaços e quebras de linha no final
                    command_to_execute = command_to_execute.rstrip(
                        current_delimiter).strip()  # Remove o delimitador final

                    if command_to_execute:
                        try:
                            # Executa o comando individualmente, o que é seguro e corrige o problema.
                            cursor.execute(command_to_execute)

                            # Consome resultados de SELECTs dentro de Procedures/Functions
                            if cursor.description is not None:
                                cursor.fetchall()

                        except Error as err:
                            print(f"❌ Erro ao executar comando: {command_to_execute[:80]}...")
                            raise err  # Relança o erro para interromper

                    # 4. Reseta o comando para a próxima instrução
                    sql_command = ""

        connection.commit()
        print(f"✅ Arquivo SQL '{filepath}' executado com sucesso!")
        return True

    except Error as err:
        print(f"❌ Erro final ao executar script SQL: '{err}'")
        return False
    except FileNotFoundError:
        print(f"❌ Arquivo não encontrado: '{filepath}'")
        print("Verifique se o arquivo 'Ecommerce.sql' está na pasta correta (../sql ecommerce/)")
        return False
    finally:
        cursor.close()


# --- Funções Principais (Início da Conexão) ---

def create_database_from_file(host, user, password, filename='Ecommerce.sql'):
    """
    Cria o banco de dados com base no arquivo .sql.
    """
    connection = None
    try:
        filepath = get_sql_path(filename)
        print(f"📄 Usando arquivo: {filepath}")

        # Conexão inicial (sem banco de dados)
        connection = mysql.connector.connect(
            host=host,
            user=user,
            password=password
        )

        if connection.is_connected():
            print("🔗 Conectado ao MySQL Server")
            success = execute_sql_file(connection, filepath)
            return success

    except Error as err:
        print(f"❌ Erro de conexão: '{err}'")
        return False
    finally:
        if connection and connection.is_connected():
            connection.close()
            print("Conexão encerrada.")


def drop_database(host, user, password, db_name):
    """
    Deleta completamente o banco de dados especificado e os usuários.
    """
    print(f"\nTentando deletar o banco de dados '{db_name}'...")
    conexao = None
    try:
        # Conexão inicial (sem banco de dados) para deletar o banco
        conexao = mysql.connector.connect(
            host=host,
            user=user,
            password=password
        )
        if conexao.is_connected():
            cursor = conexao.cursor()

            # Deleta usuários
            print("Deletando usuários do ECOMMERCE...")
            cursor.execute("DROP USER IF EXISTS 'ceo_ecommerce'@'%'")
            cursor.execute("DROP USER IF EXISTS 'gerente_ecommerce'@'%'")
            cursor.execute("DROP USER IF EXISTS 'funcionario_ecommerce'@'%'")

            # Deletar o banco
            cursor.execute(f"DROP DATABASE IF EXISTS {db_name}")
            conexao.commit()

            print(f"✓ Banco de dados '{db_name}' deletado com sucesso.")

            cursor.close()
            return True
        else:
            print("✗ Erro ao conectar ao servidor MySQL.")
            return False

    except Error as erro:
        print(f"✗ Erro ao deletar o banco de dados: {erro}")
        return False
    finally:
        if conexao and conexao.is_connected():
            conexao.close()