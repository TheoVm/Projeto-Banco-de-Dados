import cliente
import produto
import venda
import procedures
import views
import Login

def menu():
    cargo = Login.login()
    if cargo == 1:
        usuario = "ceo_ecommerce"
        senha = "Ceo123456"
        print("\nLogado como CEO.")
    if cargo == 2:
        usuario = "gerente_ecommerce"
        senha = "Gerente123"
        print("\nLogado como Gerente.")
    if cargo == 3:
        usuario = "funcionario_ecommerce"
        senha = "SenhaFunc123"
        print("\nLogado como Funcionário.")

    while True:
        print("\n======= MENU PRINCIPAL =======")
        print("1 - Cadastrar cliente")
        print("2 - Listar clientes")
        print("3 - Cadastrar produto")
        print("4 - Listar produtos")
        print("5 - Registrar venda")
        print("6 - Executar reajuste (procedure)")
        print("7 - Executar sorteio (procedure)")
        print("8 - Ver vendas por vendedor (view)")
        print("9 - Ver clientes especiais (view)")
        print("0 - Sair")
        opc = input("Escolha: ")

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
            procedures.executar_reajuste(usuario, senha)
        elif opc == "7":
            procedures.executar_sorteio(usuario, senha)
        elif opc == "8":
            views.ver_vendas_vendedor(usuario, senha)
        elif opc == "9":
            views.ver_clientes_especiais(usuario, senha)
        elif opc == "0":
            print("Menu fechado.")
            break
        else:
            print("Opção inválida, insira uma opção dentre as apresentadas.")

if __name__ == "__main__":
    menu()