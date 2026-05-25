DROP DATABASE IF EXISTS PF;
CREATE DATABASE PF;
USE PF;

CREATE TABLE Administrador (
    ID_admin INT NOT NULL PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL,
    Telefone INT NOT NULL,
    Senha VARCHAR(20) NOT NULL
);

CREATE TABLE Autenticacao (
    ID_autenticacao INT NOT NULL PRIMARY KEY,
    ID_admin INT NOT NULL,
    Acao VARCHAR(20) NOT NULL,
    FOREIGN KEY (ID_admin) REFERENCES Administrador(ID_admin) ON DELETE RESTRICT
);

CREATE TABLE Coafitriao (
    ID_coafitriao INT NOT NULL PRIMARY KEY,
    Email VARCHAR(150),
    Telefone INT 
);

CREATE TABLE Imovel (
    ID_imovel INT NOT NULL PRIMARY KEY,
    ID_coafitriao INT NOT NULL,
    Titulo  VARCHAR(100) NOT NULL,
    Descricao TEXT NOT NULL,
    Tipo VARCHAR(20) NOT NULL,
    Localizacao VARCHAR(255) NOT NULL,
    Preco_I DECIMAL(10,2) NOT NULL,
    Estado VARCHAR(20) NOT NULL,
    Num_hospedes INT NOT NULL,
    Cancelamento VARCHAR(20) NOT NULL,
    Regras TEXT NOT NULL,
    FOREIGN KEY (ID_coafitriao) REFERENCES Coafitriao(ID_coafitriao) ON DELETE CASCADE,
    CHECK (Cancelamento IN ('Flexivel','Rigida','Nao Reembolsavel')),
    CHECK (Estado IN ('Aberto','Fechado'))
);

CREATE TABLE Agente (
    ID_agente INT NOT NULL PRIMARY KEY,
    ID_imovel INT,
    Nome VARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL,
    Telefone INT NOT NULL,
    Nacionalidade VARCHAR(100) NOT NULL,
    Avaliacao INT NOT NULL,
    Senha VARCHAR(20) NOT NULL,
    ID_autenticacao INT NOT NULL,
    FOREIGN KEY (ID_imovel) REFERENCES Imovel(ID_imovel) ON DELETE CASCADE,
    FOREIGN KEY (ID_autenticacao) REFERENCES Autenticacao(ID_autenticacao) ON DELETE RESTRICT
);

CREATE TABLE Cliente (
    ID_cliente INT NOT NULL PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL,
    Telefone INT NOT NULL,
    Nacionalidade VARCHAR(100) NOT NULL,
    Avaliacao INT,
    Senha VARCHAR(20) NOT NULL,
    ID_autenticacao INT NOT NULL,
    FOREIGN KEY (ID_autenticacao) REFERENCES Autenticacao(ID_autenticacao) ON DELETE RESTRICT
);

CREATE TABLE Reservas (
    ID_reserva INT NOT NULL PRIMARY KEY,
    ID_imovel INT NOT NULL,
    ID_cliente INT NOT NULL,
    Precos_R DECIMAL(10,2) NOT NULL,
    Data_checkin DATE NOT NULL,
    Data_checkout DATE NOT NULL,
    ID_autenticacao INT NOT NULL,
    FOREIGN KEY (ID_imovel) REFERENCES Imovel(ID_imovel) ON DELETE CASCADE,
    FOREIGN KEY (ID_cliente) REFERENCES Cliente(ID_cliente) ON DELETE CASCADE,
    FOREIGN KEY (ID_autenticacao) REFERENCES Autenticacao(ID_autenticacao) ON DELETE RESTRICT
);

CREATE TABLE Imovel_Fotos (
    ID_foto INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    ID_imovel INT NOT NULL,
    Foto VARCHAR(255) NOT NULL,
    FOREIGN KEY (ID_imovel) REFERENCES Imovel(ID_imovel) ON DELETE CASCADE
);


CREATE TABLE Imovel_Comodidades (
    ID_comodidade INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    ID_imovel INT NOT NULL,
    Comodidade VARCHAR(100) NOT NULL,
    FOREIGN KEY (ID_imovel) REFERENCES Imovel(ID_imovel) ON DELETE CASCADE
);

-- No meu Mysql foi utilizado no vscode e não permite a ulitlização de DELIMITER //

CREATE PROCEDURE Obter_Imoveis_agente (
    p_Nome VARCHAR(100)
)
BEGIN
    SELECT Ag.Nome AS Agente, I.Titulo AS Imovel
    FROM Agente Ag
    JOIN Imovel I ON Ag.ID_imovel = I.ID_imovel
    WHERE Ag.Nome = p_Nome;
END;

CREATE PROCEDURE Obter_Reservas_Cliente (
    p_Nome VARCHAR(100)
)
BEGIN
    SELECT R.ID_reserva, I.Titulo AS Imovel, R.Precos_R AS Preco, R.Data_checkin AS Check_in, R.Data_checkout AS Check_out
    FROM Reservas R
    JOIN Cliente C ON C.ID_cliente = R.ID_cliente
    JOIN Imovel I ON R.ID_imovel = I.ID_imovel
    WHERE C.Nome = p_Nome;
END;

CREATE PROCEDURE Reservas_Imovel (
    p_Titulo VARCHAR(100)
)
BEGIN
    SELECT COUNT(R.ID_reserva) AS Total_Reservas, I.Titulo AS Imovel, C.Nome AS Cliente
    FROM Reservas R
    JOIN Cliente C ON C.ID_cliente = R.ID_cliente
    JOIN Imovel I ON I.ID_imovel = R.ID_imovel
    WHERE I.Titulo = p_Titulo
    GROUP BY I.Titulo, C.Nome;
END;

CREATE TRIGGER Imovel_Fechado
BEFORE INSERT ON Reservas
FOR EACH ROW
BEGIN
    DECLARE v_estado VARCHAR(20);
    SELECT Estado INTO v_estado FROM Imovel WHERE ID_imovel = NEW.ID_imovel;

    IF v_estado = 'Fechado' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A reserva nao se encontra disponivel nas datas selcionadas!';
    END IF;
END;

CREATE TRIGGER Valida_Avaliacao_Cliente
BEFORE INSERT ON Cliente
FOR EACH ROW
BEGIN
    IF NEW.Avaliacao < 0 OR NEW.Avaliacao > 10 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A avaliação do cliente deve estar entre 0 e 10.';
    END IF;
END;

CREATE VIEW Reservas_Detalhes AS
SELECT R.ID_reserva, R.Precos_R, R.Data_checkin, R.Data_checkout, I.Titulo AS Imovel, C.Nome AS Cliente
FROM Reservas R
JOIN Imovel I ON R.ID_imovel = I.ID_imovel
JOIN Cliente C ON R.ID_cliente = C.ID_cliente;

CREATE VIEW Avaliacoes_Agente AS
SELECT A.Nome, A.Email, A.Avaliacao
FROM Agente A
ORDER BY A.Avaliacao DESC;

-- Exemplo do codigo em funcionamento
-- Inserir administradores
INSERT INTO Administrador (ID_admin, Nome, Email, Telefone, Senha)
VALUES (1, 'João Silva', 'joao@site.com', 123456789, 'senha123');

-- Inserir autenticações
INSERT INTO Autenticacao (ID_autenticacao, ID_admin, Acao)
VALUES (1, 1, 'Login');

-- Inserir coafitrião
INSERT INTO Coafitriao (ID_coafitriao, Email, Telefone)
VALUES (1, 'coafitri@site.com', 987654321);

-- Inserir imóvel
INSERT INTO Imovel (ID_imovel, ID_coafitriao, Titulo, Descricao, Tipo, Localizacao, Preco_I, Estado, Num_hospedes, Cancelamento, Regras)
VALUES (1, 1, 'Casa na Praia', 'Casa ampla com vista para o mar', 'Casa', 'Praia do Sol', 150.00, 'Aberto', 5, 'Flexivel', 'Sem festas');

-- Inserir cliente com avaliação válida
INSERT INTO Cliente (ID_cliente, Nome, Email, Telefone, Nacionalidade, Avaliacao, Senha, ID_autenticacao)
VALUES (1, 'Maria Costa', 'maria@site.com', 555555555, 'Cabo Verde', 8, 'maria123', 1);

-- Inserir agente com avaliação válida
INSERT INTO Agente (ID_agente, ID_imovel, Nome, Email, Telefone, Nacionalidade, Avaliacao, Senha, ID_autenticacao)
VALUES (1, 1, 'Carlos Pinto', 'carlos@site.com', 444444444, 'Portugal', 9, 'carlos123', 1);

-- Inserir reserva válida
INSERT INTO Reservas (ID_reserva, ID_imovel, ID_cliente, Precos_R, Data_checkin, Data_checkout, ID_autenticacao)
VALUES (1, 1, 1, 300.00, '2025-07-01', '2025-07-05', 1);

-- Tentar inserir cliente com avaliação inválida (deve falhar)
INSERT INTO Cliente (ID_cliente, Nome, Email, Telefone, Nacionalidade, Avaliacao, Senha, ID_autenticacao)
VALUES (2, 'Joana Santos', 'joana@site.com', 333333333, 'Brasil', 15, 'joana123', 1);
-- → Deve gerar erro: A avaliação do cliente deve estar entre 0 e 10.

-- Fechar o imóvel e tentar reservar (deve falhar)
UPDATE Imovel SET Estado = 'Fechado' WHERE ID_imovel = 1;

INSERT INTO Reservas (ID_reserva, ID_imovel, ID_cliente, Precos_R, Data_checkin, Data_checkout, ID_autenticacao)
VALUES (2, 1, 1, 200.00, '2025-08-01', '2025-08-03', 1);
-- → Deve gerar erro: A reserva nao se encontra disponivel nas datas selcionadas!

-- Obter imóveis de um agente
CALL Obter_Imoveis_agente('Carlos Pinto');

-- Obter reservas de um cliente
CALL Obter_Reservas_Cliente('Maria Costa');

-- Obter número de reservas para um imóvel específico
CALL Reservas_Imovel('Casa na Praia');

-- Visualizar detalhes das reservas
SELECT * FROM Reservas_Detalhes;

-- Visualizar avaliações dos agentes
SELECT * FROM Avaliacoes_Agente;