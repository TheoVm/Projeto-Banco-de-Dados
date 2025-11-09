# Projeto E-Commerce

Este projeto implementa um sistema de e-commerce prático, desenvolvido como parte da disciplina de Banco de Dados.  
O objetivo é integrar **MySQL (SQL)** com **Python**, aplicando o uso de tabelas, constraints, triggers, functions, procedures e views, além de um programa interativo no terminal.

---

## Integrantes do grupo

- Felipe Assis Ferreira dos Santos
- Júlio César Bizarria Lins
- Luciano Henrique Pereira Cordeiro
- Pedro Mota Mendes
- Theo Vieira Marcelino

---

## Descrição do sistema

O sistema representa uma loja virtual (e-commerce) capaz de armazenar e gerenciar informações sobre:

- **Clientes** (com sexo `M`, `F` ou `O`)  
- **Clientes especiais** (com cashback)  
- **Vendedores** (com bônus a partir de vendas acima de R$ 1000)  
- **Produtos**  
- **Transportadoras**  
- **Vendas**

O banco de dados implementa **restrições, relacionamentos, triggers e procedures** conforme o enunciado do projeto.

---

## Tecnologias utilizadas

- **Python 3**
- **MySQL**
- **Biblioteca `mysql.connector`**

---

## Funcionalidades do sistema (Python)

O programa principal (`main.py`) apresenta um menu com as seguintes opções:

| Opção | Descrição |
|:------|:-----------|
| 1 | Cadastrar cliente |
| 2 | Listar clientes |
| 3 | Cadastrar produto |
| 4 | Listar produtos |
| 5 | Registrar venda |
| 6 | Executar procedure de reajuste salarial |
| 7 | Executar procedure de sorteio |
| 8 | Consultar view de vendas por vendedor |
| 9 | Consultar view de clientes especiais |
| 0 | Sair do sistema |

---

## Estrutura de arquivos

