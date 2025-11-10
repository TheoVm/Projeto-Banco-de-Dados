def login():
    while True:
        print("\n============Login======")
        print("1 -CEO")
        print ("2 - Gerente")
        print("3- Funcionario")
        print("0- Sair")
        opc=input("Escolha:  ")
        if opc=="1":
            return 1
        elif opc == "2":
            return 2
        elif opc == "3":
            return 3
        elif opc == "0":
            print("Menu fechado.")
            break
        else:
            print("Opção invalida, insira uma opção dentre as apresentadas.")