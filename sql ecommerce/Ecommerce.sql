DROP DATABASE IF EXISTS ECOMMERCE;
CREATE DATABASE ECOMMERCE;
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

DROP USER IF EXISTS 'ceo_ecommerce'@'%';
DROP USER IF EXISTS 'gerente_ecommerce'@'%';
DROP USER IF EXISTS 'funcionario_ecommerce'@'%';

CREATE USER 'ceo_ecommerce'@'%' IDENTIFIED BY 'Ceo123456';
GRANT ALL PRIVILEGES ON ecommerce.* TO 'ceo_ecommerce'@'%' WITH GRANT OPTION;

CREATE USER 'gerente_ecommerce'@'%' IDENTIFIED BY 'Gerente123';
GRANT SELECT, UPDATE, DELETE ON ecommerce.* TO 'gerente_ecommerce'@'%';

CREATE USER 'funcionario_ecommerce'@'%' IDENTIFIED BY 'SenhaFunc123';
GRANT SELECT, INSERT ON venda TO 'funcionario_ecommerce'@'%';
GRANT SELECT, INSERT ON item_venda TO 'funcionario_ecommerce'@'%';

FLUSH PRIVILEGES;

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

INSERT INTO cliente (nome, idade, sexo, nascimento) VALUES
('Ana Beatriz', 25, 'F', '1999-04-15'),
('Carlos Henrique', 32, 'M', '1992-01-08'),
('Mariana Silva', 28, 'F', '1997-06-22'),
('Rafael Souza', 35, 'M', '1990-11-12'),
('Juliana Costa', 30, 'F', '1995-03-02'),
('Lucas Andrade', 24, 'M', '2001-07-18'),
('Fernanda Gomes', 27, 'F', '1998-12-05'),
('Bruno Oliveira', 31, 'M', '1994-09-23'),
('Camila Rocha', 26, 'F', '1999-08-14'),
('Gustavo Lima', 29, 'M', '1996-10-09'),
('Patrícia Ferreira', 33, 'F', '1991-02-17'),
('Felipe Mendes', 22, 'M', '2003-01-21'),
('Aline Duarte', 34, 'F', '1990-05-25'),
('Thiago Barbosa', 28, 'M', '1997-09-03'),
('Isabela Martins', 23, 'F', '2002-03-11'),
('Eduardo Pereira', 36, 'M', '1989-08-27'),
('Larissa Fernandes', 21, 'F', '2004-06-30'),
('Matheus Ribeiro', 27, 'M', '1998-12-22'),
('Bruna Lopes', 24, 'F', '2001-02-09'),
('Vinícius Almeida', 25, 'M', '1999-11-16'),
('Carolina Pinto', 31, 'F', '1994-01-05'),
('Leonardo Azevedo', 33, 'M', '1992-10-13'),
('Renata Figueiredo', 26, 'F', '1999-03-07'),
('André Carvalho', 35, 'M', '1990-09-28'),
('Natália Duarte', 29, 'F', '1996-12-19'),
('Rodrigo Santos', 32, 'M', '1993-06-10'),
('Beatriz Almeida', 27, 'F', '1998-08-03'),
('Diego Castro', 30, 'M', '1995-04-12'),
('Tatiane Ramos', 28, 'F', '1997-05-09'),
('Marcelo Nogueira', 38, 'M', '1987-07-30'),
('Gabriela Correia', 22, 'F', '2003-01-15'),
('Fábio Moreira', 26, 'M', '1999-10-05'),
('Amanda Batista', 23, 'F', '2002-09-01'),
('João Pedro', 24, 'M', '2001-05-17'),
('Letícia Prado', 25, 'F', '2000-02-08'),
('Caio Rocha', 27, 'M', '1998-11-22'),
('Jéssica Teixeira', 29, 'F', '1996-03-04'),
('Daniel Moura', 31, 'M', '1994-07-26'),
('Luana Cardoso', 33, 'F', '1991-08-29'),
('Henrique Braga', 20, 'M', '2005-06-02'),
('Raquel Nascimento', 28, 'F', '1997-12-16'),
('Murilo Tavares', 34, 'M', '1990-01-09'),
('Elaine Lopes', 35, 'F', '1989-10-21'),
('Alexandre Dias', 30, 'M', '1995-05-11'),
('Priscila Vieira', 26, 'F', '1999-09-15'),
('Anderson Ribeiro', 32, 'M', '1992-03-24'),
('Carla Menezes', 31, 'F', '1994-07-01'),
('Ricardo Soares', 36, 'M', '1988-12-28'),
('Mônica Lima', 29, 'F', '1996-02-20'),
('Fernando Araújo', 24, 'M', '2001-04-03'),
('Tatiane Silva', 27, 'F', '1998-09-30'),
('Samuel Guedes', 28, 'M', '1997-06-06'),
('Viviane Barros', 34, 'F', '1991-03-19'),
('Hugo Ramos', 25, 'M', '1999-01-27'),
('Cristiane Leal', 23, 'F', '2002-07-12'),
('Douglas Matos', 33, 'M', '1991-05-02'),
('Vanessa Souza', 30, 'F', '1995-10-25'),
('Rogério Fonseca', 29, 'M', '1996-08-17'),
('Débora Neves', 28, 'F', '1997-11-09'),
('César Cunha', 37, 'M', '1988-02-22'),
('Renata Lopes', 21, 'F', '2004-04-10'),
('William Duarte', 26, 'M', '1999-09-14'),
('Camila Teles', 27, 'F', '1998-10-23'),
('Igor Costa', 32, 'M', '1993-06-04'),
('Paula Torres', 35, 'F', '1990-12-08'),
('Eduardo Reis', 31, 'M', '1994-09-15'),
('Karina Farias', 24, 'F', '2001-11-30'),
('Tiago Pires', 22, 'M', '2003-02-18'),
('Sabrina Barata', 25, 'F', '1999-08-20'),
('Hélio Queiroz', 38, 'M', '1987-05-05'),
('Rafaela Diniz', 29, 'F', '1996-03-27'),
('Diogo Almeida', 28, 'M', '1997-09-14'),
('Bianca Melo', 30, 'F', '1995-01-02'),
('Alex Santos', 27, 'M', '1998-11-19'),
('Caroline Souza', 26, 'F', '1999-06-24'),
('Vitor Campos', 33, 'M', '1992-10-31'),
('Patrícia Assis', 25, 'F', '1999-05-22'),
('Bruno Reis', 31, 'M', '1994-08-07'),
('Gabriela Rocha', 23, 'F', '2002-02-12'),
('Ricardo Mota', 34, 'M', '1990-09-27'),
('Isis Moraes', 28, 'F', '1997-07-19'),
('Fabrício Monteiro', 29, 'M', '1996-10-29'),
('Nicole Brito', 27, 'F', '1998-05-06'),
('Jonathan Melo', 24, 'M', '2001-08-25'),
('Clarissa Castro', 30, 'F', '1995-11-03'),
('Guilherme Lopes', 26, 'M', '1999-01-28'),
('Tatiane Morais', 32, 'F', '1993-03-09'),
('Rafael Teixeira', 28, 'M', '1997-09-08'),
('Lívia Ramos', 22, 'F', '2003-04-30'),
('Henrique Torres', 35, 'M', '1989-12-14'),
('Ariane Cunha', 31, 'F', '1994-09-09'),
('Caio Figueira', 23, 'M', '2002-07-04'),
('Marcela Duarte', 27, 'F', '1998-06-18'),
('Paulo Viana', 33, 'M', '1992-01-13'),
('Lorena Pacheco', 29, 'F', '1996-10-27'),
('Rogério Lemos', 36, 'M', '1989-03-11'),
('Beatriz Nunes', 24, 'F', '2001-09-07'),
('Rodrigo Almeida', 25, 'M', '1999-05-19'),
('Letícia Barros', 26, 'F', '1998-12-11'),
('Fábio Vieira', 28, 'M', '1997-02-04'),
('Camila Borges', 30, 'F', '1995-06-08'),
('Murilo Gonçalves', 34, 'M', '1990-09-22'),
('Patrícia Lima', 33, 'F', '1991-01-30'),
('Matheus Alves', 22, 'M', '2003-05-26'),
('Juliana Nogueira', 21, 'F', '2004-02-13'),
('Leandro Barata', 37, 'M', '1988-07-10'),
('Rafaela Costa', 29, 'F', '1996-11-05'),
('João Victor', 25, 'M', '1999-03-28'),
('Nathalia Moura', 27, 'F', '1998-04-22');


INSERT INTO vendedor (nome, causa_social, tipo, salario, media)
VALUES 
('Cláudio', 'RockStore Ltda', 'Álbuns de Rock', 2800.00, 4.7),
('Maria', 'JazzVinil Ltda', 'Discos de Vinil e CDs', 2600.00, 4.8),
('Pedro', 'MetalWear Ltda', 'Roupas de Bandas', 3000.00, 4.6),
('Ana', 'HipHop Ltda', 'CDs e Merch Pop', 2500.00, 4.5),
('Lucas ', 'BrasilMusic Ltda', 'Álbuns e Camisetas nacionais', 2400.00, 4.4);


INSERT INTO produto (nome, descricao, estoque, valor, observacoes, id_vendedor)
VALUES
-- Vendedor 1 - Rock
('Vinil Queen - Greatest Hits', 'Coletânea clássica do Queen', 30, 120.00, 'Edição limitada', 1),
('CD Pink Floyd - The Wall', 'Álbum duplo icônico', 40, 90.00, 'Remasterizado', 1),
('Vinil The Smiths - The Smiths', 'Primeiro álbum da banda', 25, 110.00, 'Lacrado', 1),
('CD Black Sabbath - Black Sabbath', 'Primeiro álbum da banda', 50, 70.00, '', 1),

-- Vendedor 2 - Jazz
('Vinil Miles Davis - Kind of Blue', 'Álbum clássico do jazz', 20, 150.00, 'Versão 2020', 2),
('CD John Coltrane - Blue Train', 'Álbum de 1957', 35, 80.00, '', 2),
('Vinil Ella Fitzgerald - The Best Of', 'Coletânea de clássicos', 15, 130.00, '', 2),
('CD Frank Sinatra - My Way', 'Coleção de sucessos', 45, 65.00, '', 2),

-- Vendedor 3 - Metal / Roupas
('Camiseta Iron Maiden', 'Estampa The Trooper', 60, 90.00, 'Tamanhos variados', 3),
('Camiseta Metallica', 'Logo clássico', 55, 85.00, 'Algodão premium', 3),
('Camiseta Slipknot', 'Turnê mundial', 40, 95.00, '', 3),
('Moletom Black Sabbath', 'Design retrô', 25, 160.00, '', 3),

-- Vendedor 4 - Hip hop
('CD Travis Scott -  Astroworld ', 'Versão Deluxe', 50, 85.00, '', 4),
('Vinil Nas - Illmatic', 'Edição importada', 35, 140.00, '', 4),
('Vinil Digable planets - blowout comb', 'Prensagem japonesa', 40, 100.00, '', 4),
('CD Big l - lifestyle of da poor n da dangerous', 'Primeiro álbum', 45, 75.00, 'Marcas de uso', 4),

-- Vendedor 5 - Brasileiro 
('Arthur Verocai - Arthur Verocai', 'Edição limitada', 25, 130.00, '', 5),
('Camiseta Clube da Esquina', 'Estampa capa do álbum', 50, 95.00, '', 5),
('CD Flavio José - Tareco e Mariola', '', 30, 85.00, '', 5),
('Vinil Djavan - Luz', '', 20, 150.00, '', 5);

INSERT INTO transportadora (nome, cidade) VALUES
('Transportes Rápidos Ltda', 'São Paulo'),
('Expresso Nacional', 'Rio de Janeiro'),
('LogiVeloz', 'Belo Horizonte'),
('TransCarga Brasil', 'Curitiba'),
('Entregas Express', 'Porto Alegre'),
('Rapidão Cometa', 'Brasília'),
('JadLog', 'Salvador'),
('Total Express', 'Recife'),
('Azul Cargo', 'Fortaleza'),
('Flash Courier', 'Manaus');