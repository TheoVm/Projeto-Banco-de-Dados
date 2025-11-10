import cliente
import produto
import venda
import procedures
import views
import Login
import createdelete


def inicializar_banco():
    print("\n" + "=" * 40)
    print("   INICIALIZANDO SISTEMA E-COMMERCE")
    print("=" * 40)
    print("\nVerificando banco de dados...")

    HOST = 'localhost'
    USER = 'root'
    PASSWORD = input("Digite a senha do root do MySQL: ")
    success = createdelete.create_database_from_file(HOST, USER, PASSWORD)

    if success:
        print("\nSistema pronto para uso!")
        return True
    else:
        print("\nErro ao inicializar o banco de dados.")
        return False


def menu():
    cargo = Login.login()

    if cargo is None:
        return

    if cargo == 1:
        usuario = "ceo_ecommerce"
        senha = "Ceo123456"
        print("\nLogado como CEO.")
    elif cargo == 2:
        usuario = "gerente_ecommerce"
        senha = "Gerente123"
        print("\nLogado como Gerente.")
    elif cargo == 3:
        usuario = "funcionario_ecommerce"
        senha = "SenhaFunc123"
        print("\nLogado como Funcionário.")
    else:
        print("Cargo inválido.")
        return

    while True:
        print("\n" + "=" * 40)
        print("       MENU PRINCIPAL - E-COMMERCE")
        print("=" * 40)
        print("\n--- CLIENTES ---")
        print("1 - Cadastrar cliente")
        print("2 - Listar clientes")

        print("\n--- PRODUTOS ---")
        print("3 - Cadastrar produto")
        print("4 - Listar produtos")

        print("\n--- VENDAS ---")
        print("5 - Registrar venda")
        print("6 - Listar vendas")

        print("\n--- PROCEDURES ---")
        print("7 - Executar reajuste salarial")
        print("8 - Executar sorteio de prêmio")
        print("9 - Ver estatísticas de vendas")

        print("\n--- VIEWS ---")
        print("10 - Ver vendas por vendedor")
        print("11 - Ver clientes especiais")
        print("12 - Ver produtos vendidos")

        print("\n--- BANCO DE DADOS ---")
        print("13 - Deletar banco de dados")

        print("\n--- SISTEMA ---")
        print("0 - Sair")
        print("=" * 40)

        opc = input("\nEscolha uma opção: ").strip()

        if opc == "1":
            cliente.cadastrar_cliente(usuario, senha)
        elif opc == "2":
            cliente.listar_clientes(usuario, senha)
        elif opc == "3":
            produto.cadastrar_produto(usuario, senha)
        elif opc == "4":
            produto.listar_produtos(usuario, senha)
        elif opc == "5":
            venda.registrar_venda(usuario, senha)
        elif opc == "6":
            venda.listar_vendas(usuario, senha)
        elif opc == "7":
            procedures.executar_reajuste(usuario, senha)
        elif opc == "8":
            procedures.executar_sorteio(usuario, senha)
        elif opc == "9":
            procedures.executar_estatisticas(usuario, senha)
        elif opc == "10":
            views.ver_vendas_vendedor(usuario, senha)
        elif opc == "11":
            views.ver_clientes_especiais(usuario, senha)
        elif opc == "12":
            views.ver_produtos_vendidos(usuario, senha)
        elif opc == "13":
            print("\nATENÇÃO: Isso irá DELETAR todo o banco de dados!")
            confirmacao = input("Digite 'DELETAR' para continuar: ")
            if confirmacao == "DELETAR":
                senha_root = input("Digite a senha do root do MySQL: ")
                createdelete.drop_database('localhost', 'root', senha_root, 'ECOMMERCE')
                print("\nBanco de dados deletado. Encerrando sistema...")
                break
            else:
                print("Operação cancelada.")
        elif opc == "0":
            print("\nSistema encerrado.")
            break
        else:
            print("\nOpção inválida! Escolha uma opção do menu.")


if __name__ == "__main__":
    if inicializar_banco():
        menu()
    else:
        print("\nNão foi possível iniciar o sistema.")