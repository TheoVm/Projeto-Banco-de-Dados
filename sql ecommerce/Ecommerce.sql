USE ECOMMERCE;

CREATE TABLE cliente (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    idade SMALLINT NOT NULL,
    sexo CHAR(1) NOT NULL CHECK(sexo IN ('F', 'M', 'O')),
    nascimento DATE NOT NULL
);

CREATE TABLE cliente_especial (
    id_cliente INT PRIMARY KEY,
    cashback DECIMAL(10, 2),
    FOREIGN KEY (id_cliente) REFERENCES cliente(id)
);

CREATE TABLE vendedor (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    causa_social VARCHAR(50) UNIQUE NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    salario DECIMAL(10, 2),
    media DECIMAL(3, 2)
);

CREATE TABLE funcionario_especial (
    id_vendedor INT PRIMARY KEY,
    bonus DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (id_vendedor) REFERENCES vendedor(id)
);

CREATE TABLE usuario (
    id INT PRIMARY KEY AUTO_INCREMENT,
    login VARCHAR(50) NOT NULL,
    senha VARCHAR(50) NOT NULL,
    cargo VARCHAR(20) NOT NULL CHECK(cargo IN('vendedor', 'gerente', 'CEO'))
);

CREATE TABLE produto (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    descricao VARCHAR(100) NOT NULL,
    estoque INT,
    valor DECIMAL(10,2) NOT NULL,
    observacoes VARCHAR(100),
    id_vendedor INT NOT NULL,
    FOREIGN KEY (id_vendedor) REFERENCES vendedor(id)
);

CREATE TABLE transportadora (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    cidade VARCHAR(100) NOT NULL
);

CREATE TABLE venda (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_transportadora INT,
    id_cliente INT,
    id_vendedor INT,
    destino VARCHAR(50) NOT NULL,
    data DATE NOT NULL,
    hora TIME NOT NULL,
    frete DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_transportadora) REFERENCES transportadora(id),
    FOREIGN KEY (id_cliente) REFERENCES cliente(id),
    FOREIGN KEY (id_vendedor) REFERENCES vendedor(id)
);

CREATE TABLE item_venda (
    id_venda INT,
    id_produto INT,
    quantidade INT NOT NULL,
    PRIMARY KEY (id_venda, id_produto),
    FOREIGN KEY (id_venda) REFERENCES venda(id),
    FOREIGN KEY (id_produto) REFERENCES produto(id)
);

CREATE TABLE log_mensagens (
    id INT PRIMARY KEY AUTO_INCREMENT,
    mensagem TEXT NOT NULL,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE USER 'ceo_ecommerce'@'%' IDENTIFIED BY 'Ceo123456';
GRANT ALL PRIVILEGES ON ecommerce.* TO 'ceo_ecommerce'@'%' WITH GRANT OPTION;

CREATE USER 'gerente_ecommerce'@'%' IDENTIFIED BY 'Gerente123';
GRANT SELECT, UPDATE, DELETE ON ecommerce.* TO 'gerente_ecommerce'@'%';

CREATE USER 'funcionario_ecommerce'@'%' IDENTIFIED BY 'SenhaFunc123';
GRANT SELECT, INSERT ON ecommerce.venda TO 'funcionario_ecommerce'@'%';
GRANT SELECT, INSERT ON ecommerce.item_venda TO 'funcionario_ecommerce'@'%';

DELIMITER $$
CREATE FUNCTION calcular_idade(
    aux_id INT
) RETURNS INT
DETERMINISTIC
BEGIN 
    DECLARE aux_idade INT;
    DECLARE aux_nascimento DATE;
    
    SELECT nascimento INTO aux_nascimento 
    FROM cliente 
    WHERE id = aux_id;
    
    SET aux_idade = TIMESTAMPDIFF(YEAR, aux_nascimento, CURDATE());
    
    RETURN aux_idade;
END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION soma_fretes(
    p_destino VARCHAR(100)
) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);

    SELECT SUM(v.frete)
    INTO total
    FROM venda v
    JOIN transportadora t ON v.id_transportadora = t.id
    WHERE t.cidade = p_destino;

    RETURN IFNULL(total, 0);
END$$
DELIMITER ;

DELIMITER $$
CREATE FUNCTION arrecadado(
    aux_data DATE, 
    aux_id_vendedor INT
) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);

    SELECT SUM(p.valor * iv.quantidade)
    INTO total
    FROM venda v
    JOIN item_venda iv ON v.id = iv.id_venda
    JOIN produto p ON iv.id_produto = p.id
    WHERE v.id_vendedor = aux_id_vendedor
      AND v.data = aux_data;

    RETURN IFNULL(total, 0);
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_vendedor_funcionario_especial
AFTER INSERT ON item_venda
FOR EACH ROW
BEGIN
    DECLARE total_vendido DECIMAL(10,2);
    DECLARE bonus_valor DECIMAL(10,2);
    DECLARE total_bonus DECIMAL(10,2);
    DECLARE id_vend INT;
    DECLARE mensagem_log TEXT;

    SELECT id_vendedor INTO id_vend
    FROM venda
    WHERE id = NEW.id_venda;

    SELECT SUM(p.valor * iv.quantidade)
    INTO total_vendido
    FROM venda v
    JOIN item_venda iv ON v.id = iv.id_venda
    JOIN produto p ON iv.id_produto = p.id
    WHERE v.id_vendedor = id_vend;

    IF total_vendido > 1000 THEN
        SET bonus_valor = total_vendido * 0.05;

        INSERT INTO funcionario_especial (id_vendedor, bonus)
        VALUES (id_vend, bonus_valor)
        ON DUPLICATE KEY UPDATE bonus = VALUES(bonus);

        SELECT SUM(bonus) INTO total_bonus
        FROM funcionario_especial;

        SET mensagem_log = CONCAT('Total de bônus salarial necessário: R$ ', IFNULL(total_bonus, 0));
        INSERT INTO log_mensagens (mensagem) VALUES (mensagem_log);
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_cliente_especial
AFTER INSERT ON item_venda
FOR EACH ROW
BEGIN
    DECLARE total_gasto DECIMAL(10,2);
    DECLARE cashback_valor DECIMAL(10,2);
    DECLARE total_cashback DECIMAL(10,2);
    DECLARE id_cli INT;
    DECLARE mensagem_log TEXT;

    SELECT id_cliente INTO id_cli
    FROM venda
    WHERE id = NEW.id_venda;

    SELECT SUM(p.valor * iv.quantidade)
    INTO total_gasto
    FROM venda v
    JOIN item_venda iv ON v.id = iv.id_venda
    JOIN produto p ON iv.id_produto = p.id
    WHERE v.id_cliente = id_cli;

    IF total_gasto > 500 THEN
        SET cashback_valor = total_gasto * 0.02;

        INSERT INTO cliente_especial (id_cliente, cashback)
        VALUES (id_cli, cashback_valor)
        ON DUPLICATE KEY UPDATE cashback = VALUES(cashback);

        SELECT SUM(cashback) INTO total_cashback
        FROM cliente_especial;

        SET mensagem_log = CONCAT('Valor necessário para lidar com todo cashback: R$ ', IFNULL(total_cashback, 0));
        INSERT INTO log_mensagens (mensagem) VALUES (mensagem_log);
    END IF;
END$$
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
END$$
DELIMITER ;

CREATE OR REPLACE VIEW view_vendas_vendedor AS
SELECT 
    vendedor.id AS id_vendedor,
    vendedor.nome AS nome_vendedor,
    SUM(produto.valor * item_venda.quantidade) AS total_vendas,
    COUNT(DISTINCT venda.id) AS total_transacoes
FROM venda
JOIN vendedor ON venda.id_vendedor = vendedor.id
JOIN item_venda ON venda.id = item_venda.id_venda
JOIN produto ON item_venda.id_produto = produto.id
GROUP BY vendedor.id, vendedor.nome;

CREATE OR REPLACE VIEW view_clientes_especiais AS
SELECT 
    cliente.id AS id_cliente,
    cliente.nome,
    cliente_especial.cashback,
    COUNT(DISTINCT venda.id) AS total_compras
FROM cliente
JOIN cliente_especial ON cliente.id = cliente_especial.id_cliente
LEFT JOIN venda ON cliente.id = venda.id_cliente
GROUP BY cliente.id, cliente.nome, cliente_especial.cashback;

CREATE OR REPLACE VIEW view_produtos_vendidos AS
SELECT 
    produto.id AS id_produto,
    produto.nome AS nome_produto,
    vendedor.nome AS nome_vendedor,
    SUM(item_venda.quantidade) AS quantidade_vendida,
    SUM(item_venda.quantidade * produto.valor) AS valor_total
FROM produto
JOIN item_venda ON produto.id = item_venda.id_produto
JOIN vendedor ON produto.id_vendedor = vendedor.id
GROUP BY produto.id, produto.nome, vendedor.nome;

DELIMITER $$
CREATE PROCEDURE reajuste(
    IN p_percentual DECIMAL(5,2), 
    IN p_categoria VARCHAR(50)
)
BEGIN
    UPDATE vendedor
    SET salario = salario + (salario * (p_percentual / 100))
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

    SELECT id INTO v_id_cliente
    FROM cliente
    ORDER BY RAND()
    LIMIT 1;

    SELECT cashback INTO v_cashback
    FROM cliente_especial
    WHERE id_cliente = v_id_cliente;

    IF v_cashback IS NULL THEN
        SET v_premio = 100.00;
    ELSE
        SET v_premio = 200.00;
    END IF;

    SELECT c.nome AS Cliente_Sorteado, v_premio AS Valor_Premio
    FROM cliente c
    WHERE c.id = v_id_cliente;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE venda(IN p_id_venda INT)
BEGIN
    UPDATE produto AS p
    JOIN item_venda AS iv ON p.id = iv.id_produto
    SET p.estoque = p.estoque - iv.quantidade
    WHERE iv.id_venda = p_id_venda;
    
    SELECT CONCAT('Venda ', p_id_venda, ' registrada e estoque atualizado.') AS mensagem;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE estatisticas()
BEGIN
    DECLARE v_produto_mais INT;
    DECLARE v_produto_menos INT;
    
    SELECT id_produto INTO v_produto_mais
    FROM item_venda
    GROUP BY id_produto
    ORDER BY SUM(quantidade) DESC
    LIMIT 1;
    
    SELECT id_produto INTO v_produto_menos
    FROM item_venda
    GROUP BY id_produto
    ORDER BY SUM(quantidade) ASC
    LIMIT 1;
    
    SELECT  
        'Produto mais vendido' AS tipo,
        p.nome AS produto,
        SUM(iv.quantidade) AS total_vendido,
        vdr.nome AS vendedor,
        SUM(iv.quantidade * p.valor) AS valor_ganho,
        (SELECT DATE_FORMAT(v2.data, '%Y-%m') 
         FROM venda v2 
         JOIN item_venda iv2 ON v2.id = iv2.id_venda 
         WHERE iv2.id_produto = v_produto_mais 
         GROUP BY DATE_FORMAT(v2.data, '%Y-%m') 
         ORDER BY COUNT(*) DESC 
         LIMIT 1) AS mes_maior_vendas,
        (SELECT DATE_FORMAT(v2.data, '%Y-%m') 
         FROM venda v2 
         JOIN item_venda iv2 ON v2.id = iv2.id_venda 
         WHERE iv2.id_produto = v_produto_mais 
         GROUP BY DATE_FORMAT(v2.data, '%Y-%m') 
         ORDER BY COUNT(*) ASC 
         LIMIT 1) AS mes_menor_vendas
    FROM item_venda AS iv
    JOIN produto AS p ON iv.id_produto = p.id
    JOIN vendedor AS vdr ON p.id_vendedor = vdr.id
    WHERE p.id = v_produto_mais
    GROUP BY p.id;
    
    SELECT  
        'Produto menos vendido' AS tipo,
        p.nome AS produto,
        SUM(iv.quantidade) AS total_vendido,
        vdr.nome AS vendedor,
        SUM(iv.quantidade * p.valor) AS valor_ganho,
        (SELECT DATE_FORMAT(v2.data, '%Y-%m') 
         FROM venda v2 
         JOIN item_venda iv2 ON v2.id = iv2.id_venda 
         WHERE iv2.id_produto = v_produto_menos 
         GROUP BY DATE_FORMAT(v2.data, '%Y-%m') 
         ORDER BY COUNT(*) DESC 
         LIMIT 1) AS mes_maior_vendas,
        (SELECT DATE_FORMAT(v2.data, '%Y-%m') 
         FROM venda v2 
         JOIN item_venda iv2 ON v2.id = iv2.id_venda 
         WHERE iv2.id_produto = v_produto_menos 
         GROUP BY DATE_FORMAT(v2.data, '%Y-%m') 
         ORDER BY COUNT(*) ASC 
         LIMIT 1) AS mes_menor_vendas
    FROM item_venda AS iv
    JOIN produto AS p ON iv.id_produto = p.id
    JOIN vendedor AS vdr ON p.id_vendedor = vdr.id
    WHERE p.id = v_produto_menos
    GROUP BY p.id;
END$$
DELIMITER ;