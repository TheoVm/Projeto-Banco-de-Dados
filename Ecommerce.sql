CREATE DATABASE ECOMMERCE;

USE ECOMMERCE;

CREATE TABLE cliente (
	id INT PRIMARY KEY auto_increment,
    nome varchar(100) not null,
    idade smallint not null,
    sexo char(1) not null check(sexo in ('F', 'M')),
    nascimento date not null
);

CREATE TABLE cliente_especial (
	id_cliente INT PRIMARY KEY,
    cashback decimal(10, 2),
    foreign key (id_cliente) references cliente(id)
);

CREATE TABLE vendedor (
	id INT PRIMARY KEY auto_increment,
    nome varchar(100) not null,
    causa_social varchar(50) unique not null,
    tipo varchar(50) not null,
    salario decimal(10, 2),
    media decimal(3, 2)
);

CREATE TABLE funcionario_especial (
	id_vendedor int primary key,
    bonus int not null,
    foreign key (id_vendedor) references vendedor(id)
);

CREATE TABLE usuario (
	id int primary key auto_increment,
    login varchar(50) not null,
    senha varchar(50) not null,
    cargo varchar(20) not null check(cargo IN('vendedor', 'gerente', 'CEO'))
);

CREATE TABLE produto (
	id INT PRIMARY KEY auto_increment,
    nome varchar(100) not null,
    descricao varchar(100) not null,
    estoque int,
    valor int not null,
    observacoes varchar(100)
);

CREATE TABLE transportadora (
	id INT PRIMARY KEY auto_increment,
    nome varchar(100) not null,
    cidade varchar(100) not null
);

CREATE TABLE venda (
	id_produto INT PRIMARY KEY,
    id_transportadora int,
    id_vendedor int,
    id_cliente INT,
    id_vendedor INT,
    destino varchar(50) not null,
    data date not null,
    hora time not null,
    foreign key (id_produto) references produto(id),
    foreign key (id_transportadora) references transportadora(id),
    foreign key (id_vendedor) references vendedor(id),
    foreign key (id_cliente) references cliente(id),
    foreign key (id_vendedor) references vendedor(id)
);




CREATE USER 'ceo_ecommerce'@'%' IDENTIFIED BY 'Ceo123456';
GRANT ALL PRIVILEGES ON ecommerce.* TO 'ceo_ecommerce'@'%' WITH GRANT OPTION;

CREATE USER 'gerente_ecommerce'@'%' IDENTIFIED BY 'Gerente123';
GRANT SELECT, UPDATE, DELETE ON ecommerce.* TO 'gerente_ecommerce'@'%';

CREATE USER 'funcionario_ecommerce'@'%' IDENTIFIED BY 'SenhaFunc123';
GRANT SELECT, INSERT ON ecommerce.venda TO 'funcionario_ecommerce'@'%';



DELIMITER $$
CREATE FUNCTION calcular_idade(
	aux_id int
) returns int
deterministic
Begin 
	Declare aux_idade int;
    Declare aux_nascimento date;
    
    Select nascimento into aux_nascimento from cliente Where id = aux_id;
    
    Set aux_idade = timestampdiff(YEAR, aux_nascimento, CURDATE());
    
    return aux_idade;
END$$


DELIMITER $$
CREATE FUNCTION soma_fretes(
p_destino VARCHAR(100)
)returns DECIMAL(10,2)
deterministic
BEGIN
    declare total DECIMAL(10,2);

    select SUM(p.valor)
    into total
    from venda v
    JOIN transportadora t ON v.id_transportadora = t.id
    JOIN produto p ON v.id_produto = p.id
    where t.cidade = p_destino;

    return IFNULL(total, 0);
END $$

DELIMITER $$
CREATE FUNCTION arrecadado(
	aux_data DATE, 
    aux_id_vendedor INT
)
returns DECIMAL(10,2)
deterministic
BEGIN
    DECLARE total DECIMAL(10,2);

    select SUM(p.valor)
    into total
    from venda v
    JOIN produto p ON v.id_produto = p.id
    where v.id_vendedor = aux_id_vendedor
      AND v.data = aux_data;

    return IFNULL(total, 0);
END $$

DELIMITER $$

CREATE TRIGGER trg_vendedor_funcionario_especial
AFTER INSERT ON venda
FOR EACH ROW
BEGIN
    DECLARE total_vendido DECIMAL(10,2);
    DECLARE bonus DECIMAL(10,2);
    DECLARE total_bonus DECIMAL(10,2);

    SELECT SUM(p.valor)
    INTO total_vendido
    FROM venda v
    JOIN produto p ON v.id_produto = p.id
    WHERE v.id_vendedor = NEW.id_vendedor;

    IF total_vendido > 1000 THEN
        SET bonus = total_vendido * 0.05;

        INSERT INTO funcionario_especial (id_vendedor, bonus)
        VALUES (NEW.id_vendedor, bonus)
        ON DUPLICATE KEY UPDATE bonus = bonus;

        SELECT SUM(bonus)
        INTO total_bonus
        FROM funcionario_especial;
    END IF;
END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_cliente_especial
AFTER INSERT ON venda
FOR EACH ROW
BEGIN
    DECLARE total_gasto DECIMAL(10,2);
    DECLARE cashback DECIMAL(10,2);
    DECLARE total_cashback DECIMAL(10,2);

    SELECT SUM(p.valor)
    INTO total_gasto
    FROM venda v
    JOIN produto p ON v.id_produto = p.id
    WHERE v.id_cliente = NEW.id_cliente;

    IF total_gasto > 500 THEN
        SET cashback = total_gasto * 0.02;

        INSERT INTO cliente_especial (id_cliente, cashback)
        VALUES (NEW.id_cliente, cashback)
        ON DUPLICATE KEY UPDATE cashback = VALUES(cashback);

        SELECT SUM(cashback)
        INTO total_cashback
        FROM cliente_especial;
    END IF;
END $$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER trg_remove_cliente_especial
AFTER UPDATE ON cliente_especial
FOR EACH ROW
BEGIN
    IF NEW.cashback <= 0 THEN
        DELETE FROM cliente_especial
        WHERE id_cliente = NEW.id_cliente;
    END IF;
END $$

DELIMITER ;

CREATE OR REPLACE VIEW view_vendas_vendedor AS
SELECT 
    vendedor.id AS id_vendedor,
    vendedor.nome AS nome_vendedor,
    SUM(produto.valor) AS total_vendas
FROM venda
JOIN vendedor ON venda.id_vendedor = vendedor.id
JOIN produto ON venda.id_produto = produto.id
GROUP BY vendedor.id, vendedor.nome;

CREATE OR REPLACE VIEW view_vendas_vendedor AS
SELECT 
    vendedor.id AS id_vendedor,
    vendedor.nome AS nome_vendedor,
    SUM(produto.valor) AS total_vendas
FROM venda
JOIN vendedor ON venda.id_vendedor = vendedor.id
JOIN produto ON venda.id_produto = produto.id
GROUP BY vendedor.id, vendedor.nome;

CREATE OR REPLACE VIEW view_clientes_especiais AS
SELECT 
    cliente.id AS id_cliente,
    cliente.nome,
    cliente_especial.cashback
FROM cliente
JOIN cliente_especial ON cliente.id = cliente_especial.id_cliente;


DELIMITER $$

CREATE PROCEDURE reajuste(IN p_percentual DECIMAL(5,2), IN p_categoria VARCHAR(50))
BEGIN
    UPDATE Vendedor
    SET nota_media = nota_media + (nota_media * (p_percentual / 100))
    WHERE tipo = p_categoria;

    SELECT CONCAT('Reajuste de ', p_percentual, '% aplicado à categoria ', p_categoria) AS mensagem;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE sorteio()
BEGIN
    DECLARE v_id_cliente INT;
    DECLARE v_cashback DECIMAL(10,2);
    DECLARE v_premio DECIMAL(10,2);


    SELECT id_cliente INTO v_id_cliente
    FROM Cliente
    ORDER BY RAND()
    LIMIT 1;

    -- Se for Cliente Especial
    SELECT cashback INTO v_cashback
    FROM Cliente_Especial
    WHERE id_cliente = v_id_cliente;

    IF v_cashback IS NULL THEN
        SET v_premio = 100.00;
    ELSE
        SET v_premio = 200.00;
    END IF;

    -- Resultado
    SELECT c.nome AS Cliente_Sorteado, v_premio AS Valor_Premio
    FROM Cliente c
    WHERE c.id_cliente = v_id_cliente;
END$$

DELIMITER ;
__
DELIMITER $$

CREATE PROCEDURE venda(IN p_id_venda INT)
BEGIN
    UPDATE Produto p
    JOIN Venda_Produto vp ON p.id_produto = vp.id_produto
    SET p.qtd_estoque = p.qtd_estoque - vp.quantidade
    WHERE vp.id_venda = p_id_venda;

    SELECT CONCAT('Venda ', p_id_venda, ' registrada e estoque atualizado.') AS mensagem;
END$$

DELIMITER ;
__
DELIMITER $$

CREATE PROCEDURE estatisticas()
BEGIN
    DECLARE v_produto_mais INT;
    DECLARE v_produto_menos INT;

    -- Produto mais vendido
    SELECT vp.id_produto
    INTO v_produto_mais
    FROM Venda_Produto vp
    GROUP BY vp.id_produto
    ORDER BY SUM(vp.quantidade) DESC
    LIMIT 1;

    -- Produto menos vendido
    SELECT vp.id_produto
    INTO v_produto_menos
    FROM Venda_Produto vp
    GROUP BY vp.id_produto
    ORDER BY SUM(vp.quantidade) ASC
    LIMIT 1;

    -- Estatísticas completas
    SELECT 
        'Produto mais vendido' AS tipo,
        p.nome AS produto,
        SUM(vp.quantidade) AS total_vendido,
        vdr.nome AS vendedor
    FROM Venda_Produto vp
    JOIN Produto p ON vp.id_produto = p.id_produto
    JOIN Vendedor vdr ON p.id_vendedor = vdr.id_vendedor
    WHERE p.id_produto = v_produto_mais
    GROUP BY p.id_produto;

    SELECT 
        'Produto menos vendido' AS tipo,
        p.nome AS produto,
        SUM(vp.quantidade) AS total_vendido,
        vdr.nome AS vendedor
    FROM Venda_Produto vp
    JOIN Produto p ON vp.id_produto = p.id_produto
    JOIN Vendedor vdr ON p.id_vendedor = vdr.id_vendedor
    WHERE p.id_produto = v_produto_menos
    GROUP BY p.id_produto;
END$$

DELIMITER ;