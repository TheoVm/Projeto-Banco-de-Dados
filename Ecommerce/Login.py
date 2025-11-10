def login():
    while True:
        print("\n" + "=" * 40)
        print("           LOGIN - E-COMMERCE")
        print("=" * 40)
        print("1 - CEO")
        print("2 - Gerente")
        print("3 - Funcionário")
        print("0 - Sair")
        print("=" * 40)

        opc = input("Escolha seu perfil: ").strip()

        if opc == "1":
            return 1
        elif opc == "2":
            return 2
        elif opc == "3":
            return 3
        elif opc == "0":
            print("\nSaindo do sistema...")
            return None  # Retorna None para indicar saída
        else:
            print("\n⚠️  Opção inválida! Insira uma opção válida.")