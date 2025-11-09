import cliente
import produto
import venda
import procedures
import views

def menu():
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
            cliente.cadastrar_cliente()
        elif opc == "2":
            cliente.listar_clientes()
        elif opc == "3":
            produto.cadastrar_produto()
        elif opc == "4":
            produto.listar_produtos()
        elif opc == "5":
            venda.registrar_venda()
        elif opc == "6":
            procedures.executar_reajuste()
        elif opc == "7":
            procedures.executar_sorteio()
        elif opc == "8":
            views.ver_vendas_vendedor()
        elif opc == "9":
            views.ver_clientes_especiais()
        elif opc == "0":
            print("Menu fechado.")
            break
        else:
            print("Opção inválida, insira uma opção dentre as apresentadas.")

if __name__ == "__main__":
    menu()