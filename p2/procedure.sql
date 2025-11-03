-- =====================================================
-- 1. Criação do banco e tabelas
-- =====================================================
DROP DATABASE IF EXISTS BancoTeste;
CREATE DATABASE BancoTeste;
USE BancoTeste;

DROP TABLE IF EXISTS Contas;
CREATE TABLE Contas (
    id_conta INT AUTO_INCREMENT PRIMARY KEY,
    nome_conta VARCHAR(100) NOT NULL
);

DROP TABLE IF EXISTS Transacoes;
CREATE TABLE Transacoes (
    id_transacao INT AUTO_INCREMENT PRIMARY KEY,
    id_conta INT NOT NULL,
    tipo ENUM('CREDITO','DEBITO') NOT NULL,
    valor DECIMAL(15,2) NOT NULL,
    data_transacao DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_conta) REFERENCES Contas(id_conta),
    INDEX idx_conta_data (id_conta, data_transacao)
);

-- =====================================================
-- 2. Inserção de dados de teste
-- =====================================================
INSERT INTO Contas (nome_conta) VALUES
('João Silva'),
('Maria Oliveira');

INSERT INTO Transacoes (id_conta, tipo, valor, data_transacao) VALUES
(1, 'CREDITO', 500.00, '2025-10-01 10:00:00'),
(1, 'DEBITO', 200.00, '2025-10-05 15:00:00'),
(1, 'CREDITO', 300.00, '2025-10-10 09:30:00'),
(1, 'DEBITO', 100.00, '2025-10-15 14:45:00'),
(1, 'CREDITO', 700.00, '2025-10-20 08:00:00'),
(2, 'CREDITO', 1000.00, '2025-10-02 12:00:00'),
(2, 'DEBITO', 500.00, '2025-10-07 16:30:00'),
(2, 'CREDITO', 200.00, '2025-10-12 11:00:00');

-- =====================================================
-- 3. Criação da procedure SP_ExtratoConta
-- =====================================================
DELIMITER //

DROP PROCEDURE IF EXISTS SP_ExtratoConta;

CREATE PROCEDURE SP_ExtratoConta(
    IN p_id_conta INT,      -- ID da conta que será consultada
    IN p_data_inicio DATE   -- Data inicial para filtrar transações
)
BEGIN
    DECLARE saldo_atual DECIMAL(15,2);

    -- =================================================
    -- 3.1 Calcula o saldo da conta
    -- =================================================
    -- Créditos somam, débitos subtraem
    SELECT SUM(CASE 
                 WHEN tipo='CREDITO' THEN valor 
                 ELSE -valor 
               END)
    INTO saldo_atual
    FROM Transacoes
    WHERE id_conta = p_id_conta;

    -- =================================================
    -- 3.2 Retorna o saldo com alias para visualização clara
    -- =================================================
    SELECT 
        p_id_conta AS 'ID_Conta',
        saldo_atual AS 'Saldo_Atual';

    -- =================================================
    -- 3.3 Retorna as 10 últimas transações filtradas por período
    -- =================================================
    SELECT 
        id_transacao AS 'ID_Transacao',
        tipo AS 'Tipo_Transacao',
        valor AS 'Valor_Transacao',
        data_transacao AS 'Data_Transacao'
    FROM Transacoes
    WHERE id_conta = p_id_conta
      AND data_transacao >= p_data_inicio
    ORDER BY data_transacao DESC
    LIMIT 10;
END //

DELIMITER ;

-- =====================================================
-- 4. Chamadas de teste
-- =====================================================
-- Últimos 30 dias da conta 1
CALL SP_ExtratoConta(1, DATE_SUB(CURDATE(), INTERVAL 30 DAY));

-- A partir de 2025-10-01 da conta 2
CALL SP_ExtratoConta(2, '2025-10-01');
