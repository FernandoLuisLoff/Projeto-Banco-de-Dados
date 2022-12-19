
-------- VIEWS --------  

    -------- CREATE VIEW V_PRODUTOS --------
    -- 1o. view que exiba todas todos os produtos comercializados e seu estoque atual.
        CREATE OR REPLACE VIEW V_PRODUTOS
        AS SELECT A.produto, B.qtd_atual
        FROM PRODUTOS A
        INNER JOIN ESTOQUE B ON (A.COD_PRODUTO = B.PRODUTO)
        WHERE B.COD_ESTOQUE IN
        (SELECT MAX(A.COD_ESTOQUE)
        FROM ESTOQUE A
        INNER JOIN PRODUTOS B ON (B.COD_PRODUTO = A.PRODUTO)
        GROUP BY B.PRODUTO);

        SELECT * FROM V_PRODUTOS;

    -------- CREATE VIEW V_VENDAS --------
    -- 2o. view que exiba todas as vendas realizadas com seus quantidade, produto e qual cliente comprou, ordenadas por data, 
    -- cliente e produto.
        CREATE OR REPLACE VIEW V_VENDAS 
        AS SELECT C.NOME, D.PRODUTO, B.QTD_VENDIDA
        FROM VENDAS A
        LEFT JOIN PRODUTO_VENDIDO B ON (B.COD_VENDAS = A.COD_VENDAS)
        LEFT JOIN PESSOAS C ON (C.COD_PESSOA = A.PESSOA)
        LEFT JOIN PRODUTOS D ON (D.COD_PRODUTO = B.PRODUTO)
        ORDER BY A.DATA_VENDA, C.NOME, D.PRODUTO;

        SELECT * FROM V_VENDAS;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------- PROCEDURES --------

    -------- PROCEDURES CRUD --------
    -- 4 procedures de CRUD (insert, delete, update e select) da tabela clientes.  

        -------- FUNCTION DE INSERT --------
        CREATE OR REPLACE FUNCTION INS_PESSOA
        (
            VNOME VARCHAR(30),
            VRG VARCHAR(9),
            VCPF_CNPJ VARCHAR(14),
            VSALARIO NUMERIC,
            VRUA VARCHAR(30),
            VNUMERO VARCHAR(5),
            VBAIRRO VARCHAR(30),
            VCEP VARCHAR(8),
            VCODTIPOPESSOA INTEGER,
            VCODCIDADE INTEGER
        ) RETURNS INTEGER AS $$
        DECLARE 
            VCODPESSOA INTEGER;
        BEGIN
            INSERT INTO PESSOAS( NOME, RG, CPF_CNPJ, SALARIO, RUA, NUMERO, BAIRRO, CEP, TIPOS_PESSOA, CIDADE)
            VALUES ( VNOME, VRG, VCPF_CNPJ, VSALARIO, VRUA, VNUMERO, VBAIRRO, VCEP, VCODTIPOPESSOA, VCODCIDADE)
            RETURNING COD_PESSOA INTO VCODPESSOA;
            RETURN VCODPESSOA;
        END;
        $$ LANGUAGE plpgsql;

        SELECT INS_PESSOA('Fernando','123456789','12345678910',10250,'Rua','123','Bairro','00000000',4,2);

        -------- FUNCTION DE DELETE --------
        CREATE OR REPLACE FUNCTION DEL_PESSOA
        (
            VCODPESSOA INTEGER
        ) RETURNS INTEGER AS $$
        DECLARE
            VSTATUS INTEGER;
        BEGIN
            DELETE FROM PESSOAS 
            WHERE COD_PESSOA = VCODPESSOA;
            IF (FOUND = TRUE) THEN
                VSTATUS:= 1;
            ELSE
                VSTATUS:= -1;
            END IF;
            RETURN VSTATUS;
        END;
        $$ LANGUAGE plpgsql;

        SELECT DEL_PESSOA(6);

        -------- FUNCTION DE UPDATE --------
        CREATE OR REPLACE FUNCTION UPD_PESSOA
        (
            VCODPESSOA INTEGER,
            VNOME VARCHAR(30),
            VRG VARCHAR(9),
            VCPF_CNPJ VARCHAR(14),
            VSALARIO NUMERIC,
            VRUA VARCHAR(30),
            VNUMERO VARCHAR(5),
            VBAIRRO VARCHAR(30),
            VCEP VARCHAR(8),
            VCODTIPOPESSOA INTEGER,
            VCODCIDADE INTEGER
        ) RETURNS INTEGER AS $$
        DECLARE
            VSTATUS INTEGER;
        BEGIN
            UPDATE PESSOAS 
            SET NOME = VNOME,
                RG = VRG,
                CPF_CNPJ = VCPF_CNPJ,
                SALARIO = VSALARIO,
                RUA = VRUA,
                NUMERO = VNUMERO,
                BAIRRO = VBAIRRO,
                CEP = VCEP,
                TIPOS_PESSOA = VCODTIPOPESSOA,
                CIDADE = VCODCIDADE
            WHERE COD_PESSOA = VCODPESSOA;
            IF (FOUND = TRUE) THEN
                VSTATUS:= 1;
            ELSE
                VSTATUS:= -1;
            END IF;
            RETURN VSTATUS;
        END;
        $$ LANGUAGE plpgsql;

        SELECT UPD_PESSOA(7,'Luis','9878494','4564898',54686,'Rua','123','Bairro','00000000',4,2);

        -------- FUNCTION DE SELECT --------
        CREATE OR REPLACE FUNCTION SEL_PESSOA 
        (
            VCODPESSOA INTEGER DEFAULT NULL,
            VNOME VARCHAR(30) DEFAULT NULL,
            VRG VARCHAR(9) DEFAULT NULL,
            VCPF_CNPJ VARCHAR(14) DEFAULT NULL,
            VSALARIO MONEY DEFAULT NULL,
            VRUA VARCHAR(30) DEFAULT NULL,
            VNUMERO VARCHAR(5) DEFAULT NULL,
            VBAIRRO VARCHAR(30) DEFAULT NULL,
            VCEP VARCHAR(8) DEFAULT NULL,
            VCODTIPOPESSOA INTEGER DEFAULT NULL,
            VCODCIDADE INTEGER DEFAULT NULL
        ) RETURNS TABLE (
            RCODPESSOA INTEGER,
            RNOME VARCHAR(30),
            RRG VARCHAR(9),
            RCPF_CNPJ VARCHAR(14),
            RSALARIO MONEY,
            RRUA VARCHAR(30),
            RNUMERO VARCHAR(5),
            RBAIRRO VARCHAR(30),
            RCEP VARCHAR(8),
            RCODTIPOPESSOA INTEGER,
            RCODCIDADE INTEGER) AS $$
        BEGIN
            RETURN QUERY SELECT COD_PESSOA,
                NOME,
                RG,
                CPF_CNPJ,
                SALARIO,
                RUA,
                NUMERO,
                BAIRRO,
                CEP,
                TIPOS_PESSOA,
                CIDADE 
            FROM PESSOAS
            WHERE ((VCODPESSOA IS NULL) OR (COD_PESSOA = VCODPESSOA))
            AND ((VNOME IS NULL) OR (NOME LIKE VNOME||'%'))
            AND ((VRG IS NULL) OR (RG LIKE VRG||'%'))
            AND ((VCPF_CNPJ IS NULL) OR (CPF_CNPJ LIKE VCPF_CNPJ||'%'))
            AND ((VSALARIO IS NULL) OR (SALARIO = VSALARIO))
            AND ((VRUA IS NULL) OR (RUA LIKE VRUA||'%'))
            AND ((VNUMERO IS NULL) OR (NUMERO LIKE VNUMERO||'%'))
            AND ((VBAIRRO IS NULL) OR (BAIRRO LIKE VBAIRRO||'%'))
            AND ((VCEP IS NULL) OR (CEP LIKE VCEP||'%'))					   
            AND ((VCODTIPOPESSOA IS NULL) OR (TIPOS_PESSOA = VCODTIPOPESSOA))
            AND ((VCODCIDADE IS NULL) OR (CIDADE = VCODCIDADE));
			RETURN;
		END;
        $$ LANGUAGE plpgsql
        CALLED ON NULL INPUT;

        SELECT SEL_PESSOA();
        SELECT SEL_PESSOA(7,'Luis','9878494','4564898','54686','Rua','123','Bairro','00000000',4,2);

    -- 1 procedure que receba como parâmetro o nome de um cliente, e imprima todas as vendas que este cliente esta vinculado, 
    -- e totalize o total que este cliente pagou (somar todas as vendas)
        -------- FUNCTION COMPRAS_CLIENTE --------
        CREATE OR REPLACE FUNCTION COMPRAS_CLIENTE
        (
            VNOME VARCHAR(30)
        ) RETURNS VOID AS $$
        DECLARE
            VVENDAS RECORD;
            VVALOR_TOTAL MONEY;
        BEGIN

            VVALOR_TOTAL := 0;

            FOR VVENDAS IN
            SELECT
                D.NOME, 
                C.PRODUTO,
                B.QTD_VENDIDA,
				A.DATA_VENDA,
				A.OBSERVACAO,
				A.DATA_VENDA,
				B.VALOR_UNITARIO
            FROM VENDAS A
            LEFT JOIN PRODUTO_VENDIDO B ON(B.COD_VENDAS=A.COD_VENDAS)
            LEFT JOIN PRODUTOS C ON(C.COD_PRODUTO=B.PRODUTO) 
            LEFT JOIN PESSOAS D ON(D.COD_PESSOA=A.PESSOA)
			WHERE D.NOME LIKE VNOME
				
            LOOP
                RAISE NOTICE 'NOME: %', VVENDAS.NOME;
                RAISE NOTICE 'ITEM: %', VVENDAS.PRODUTO;
                RAISE NOTICE 'QUANTIDADE: %', VVENDAS.QTD_VENDIDA;
                RAISE NOTICE 'VALOR: %', VVENDAS.VALOR_UNITARIO;
                RAISE NOTICE 'VALOR TOTAL: %', VVENDAS.VALOR_UNITARIO*VVENDAS.QTD_VENDIDA;
                RAISE NOTICE '';

                VVALOR_TOTAL := VVALOR_TOTAL + VVENDAS.VALOR_UNITARIO * VVENDAS.QTD_VENDIDA;
            END LOOP;

            RAISE NOTICE 'VALOR TOTAL DAS VENDAS: %', VVALOR_TOTAL;
        END;
        $$ LANGUAGE plpgsql;

        SELECT COMPRAS_CLIENTE('FERNANDO');

    -- 1 procedure que receba como parâmetro um produto e exiba todas as movimentações deste produto (seja venda ou compra) 
    -- com as quantidades e data.
        -------- FUNCTION MOVIMENTACOES_PRODUTO --------
        CREATE OR REPLACE FUNCTION MOVIMENTACOES_PRODUTO
        (
            VPRODUTO VARCHAR(30)
        ) RETURNS VOID AS $$
        DECLARE
        
            VMOVIMENTOS RECORD;

        BEGIN
            FOR VMOVIMENTOS IN
            SELECT
                A.PRODUTO,
                B.QTD_OPERACAO,
				B.DATA_ESTOQUE,
				C.DESCRICAO
					
            FROM PRODUTOS A
			LEFT JOIN ESTOQUE B ON (B.PRODUTO=A.COD_PRODUTO)
			LEFT JOIN TIPO_MOVIMENTACAO C ON (C.COD_TIPO_MOVIMENTACAO=B.TIPO_MOVIMENTACAO)
			WHERE A.PRODUTO LIKE VPRODUTO
			
            LOOP
                RAISE NOTICE 'PRODUTO: %', VMOVIMENTOS.PRODUTO;
                RAISE NOTICE 'MOVIMENTACAO: %', VMOVIMENTOS.DESCRICAO;
				RAISE NOTICE 'QUANTIDADE: %', VMOVIMENTOS.QTD_OPERACAO;
                RAISE NOTICE 'DATA: %', VMOVIMENTOS.DATA_ESTOQUE;
				RAISE NOTICE '';
            END LOOP;
        END;
        $$ LANGUAGE plpgsql;

        SELECT MOVIMENTACOES_PRODUTO('UM PACOTE DE BOLACHA');


-------- TRIGGERS --------

    -- 1 trigger na tabela produto_vendido que ao fazer um insert, update ou delete faça a atualização do estoque do 
    -- respectivo produto.
        -------- TRIGGER TG_ATUALIZACAO_PRODUTO --------
        CREATE OR REPLACE FUNCTION LOG_ATUALIZA_ESTOQUE() RETURNS TRIGGER AS $LOG_ATUALIZA_ESTOQUE$
        -- VARIAVEL QUE SERÁ UTILIZADA NA TRIGGER
        DECLARE
            VCOD_ESTOQUE RECORD;
            VESTOQUE RECORD;
            VVALOR_ATUAL NUMERIC;
            VVALOR_OPERACAO NUMERIC;
        BEGIN
            IF (NEW.COD_VENDAS IS NOT NULL AND OLD.COD_VENDAS IS NOT NULL) THEN --TG_OP = 'UPDATE'
                
                FOR VCOD_ESTOQUE IN
                SELECT
                    MAX(COD_ESTOQUE) AS CODIGO
                FROM ESTOQUE
                WHERE PRODUTO = NEW.PRODUTO
				LOOP
				END LOOP;

                FOR VESTOQUE IN
                SELECT
                    COD_ESTOQUE,
                    QTD_ANTERIOR,
                    QTD_ATUAL,
                    QTD_OPERACAO,
                    DATA_ESTOQUE,
                    PRODUTO,
                    TIPO_ESTOQUE,
                    TIPO_MOVIMENTACAO,
                    LOTE,
                    VENDA
                FROM ESTOQUE
                WHERE COD_ESTOQUE = VCOD_ESTOQUE.CODIGO
				LOOP

                IF (NEW.QTD_VENDIDA>OLD.QTD_VENDIDA) THEN
                    VVALOR_OPERACAO = NEW.QTD_VENDIDA-OLD.QTD_VENDIDA;
                    VVALOR_ATUAL = VESTOQUE.QTD_ATUAL + VVALOR_OPERACAO;
                ELSIF (NEW.QTD_VENDIDA<OLD.QTD_VENDIDA) THEN
                    VVALOR_OPERACAO = OLD.QTD_VENDIDA-NEW.QTD_VENDIDA;
                    VVALOR_ATUAL = VESTOQUE.QTD_ATUAL - VVALOR_OPERACAO;
                ELSE
                    VVALOR_OPERACAO = 0;
                    VVALOR_ATUAL = VESTOQUE.QTD_ATUAL;
                END IF;

				END LOOP;

                INSERT INTO ESTOQUE(QTD_ANTERIOR,QTD_ATUAL,QTD_OPERACAO,DATA_ESTOQUE,PRODUTO,TIPO_ESTOQUE,TIPO_MOVIMENTACAO,LOTE,VENDA)
                VALUES (VESTOQUE.QTD_ATUAL,VVALOR_ATUAL,VVALOR_OPERACAO,CURRENT_TIMESTAMP,VESTOQUE.PRODUTO,VESTOQUE.TIPO_ESTOQUE,VESTOQUE.TIPO_MOVIMENTACAO,VESTOQUE.LOTE,VESTOQUE.VENDA);
                
            END IF;
            IF (NEW.COD_VENDAS IS NOT NULL AND OLD.COD_VENDAS ISNULL) THEN --TG_OP = 'INSERT'

                FOR VCOD_ESTOQUE IN
                SELECT
                    MAX(COD_ESTOQUE) AS CODIGO
                FROM ESTOQUE
                WHERE PRODUTO = NEW.PRODUTO
				LOOP
				END LOOP;

                FOR VESTOQUE IN
                SELECT
                    COD_ESTOQUE,
                    QTD_ANTERIOR,
                    QTD_ATUAL,
                    QTD_OPERACAO,
                    DATA_ESTOQUE,
                    PRODUTO,
                    TIPO_ESTOQUE,
                    TIPO_MOVIMENTACAO,
                    LOTE,
                    VENDA
                FROM ESTOQUE
                WHERE COD_ESTOQUE = VCOD_ESTOQUE.CODIGO
				LOOP
                VVALOR_ATUAL = VESTOQUE.QTD_ATUAL + NEW.QTD_VENDIDA;
				END LOOP;

                INSERT INTO ESTOQUE(QTD_ANTERIOR,QTD_ATUAL,QTD_OPERACAO,DATA_ESTOQUE,PRODUTO,TIPO_ESTOQUE,TIPO_MOVIMENTACAO,LOTE,VENDA)
                VALUES (VESTOQUE.QTD_ATUAL,VVALOR_ATUAL,NEW.QTD_VENDIDA,CURRENT_TIMESTAMP,VESTOQUE.PRODUTO,VESTOQUE.TIPO_ESTOQUE,VESTOQUE.TIPO_MOVIMENTACAO,VESTOQUE.LOTE,VESTOQUE.VENDA);
            END IF;
            IF (NEW.COD_VENDAS ISNULL AND OLD.COD_VENDAS IS NOT NULL) THEN --TG_OP = 'DELETE'

                FOR VCOD_ESTOQUE IN
                SELECT
                    MAX(COD_ESTOQUE) AS CODIGO
                FROM ESTOQUE
                WHERE PRODUTO = OLD.PRODUTO
				LOOP
				END LOOP;

                FOR VESTOQUE IN
                SELECT
                    COD_ESTOQUE,
                    QTD_ANTERIOR,
                    QTD_ATUAL,
                    QTD_OPERACAO,
                    DATA_ESTOQUE,
                    PRODUTO,
                    TIPO_ESTOQUE,
                    TIPO_MOVIMENTACAO,
                    LOTE,
                    VENDA
                FROM ESTOQUE
                WHERE COD_ESTOQUE = VCOD_ESTOQUE.CODIGO
				LOOP
                VVALOR_ATUAL = VESTOQUE.QTD_ATUAL - OLD.QTD_VENDIDA;
				END LOOP;

                INSERT INTO ESTOQUE(QTD_ANTERIOR,QTD_ATUAL,QTD_OPERACAO,DATA_ESTOQUE,PRODUTO,TIPO_ESTOQUE,TIPO_MOVIMENTACAO,LOTE,VENDA)
                VALUES (VESTOQUE.QTD_ATUAL,VVALOR_ATUAL,OLD.QTD_VENDIDA,CURRENT_TIMESTAMP,VESTOQUE.PRODUTO,VESTOQUE.TIPO_ESTOQUE,VESTOQUE.TIPO_MOVIMENTACAO,VESTOQUE.LOTE,VESTOQUE.VENDA);
                
            END IF;
			RETURN NEW;
        END;
        $LOG_ATUALIZA_ESTOQUE$ LANGUAGE plpgsql;

        CREATE OR REPLACE TRIGGER TG_ATUALIZACAO_PRODUTO AFTER INSERT OR UPDATE OR DELETE ON PRODUTO_VENDIDO
        FOR EACH ROW EXECUTE PROCEDURE LOG_ATUALIZA_ESTOQUE();

        ------- Teste Insert -------
            INSERT INTO produto_vendido(cod_vendas,produto,qtd_vendida,valor_unitario)
            VALUES(1,5,5,15);
        
        ------- Teste Delete -------
            DELETE FROM produto_vendido
            WHERE cod_vendas = 1
            AND PRODUTO = 5;

        ------- Teste Update -------
            UPDATE produto_vendido
            SET QTD_VENDIDA = 6
            WHERE cod_vendas = 1
            AND PRODUTO = 5;

        ----------------------------
            SELECT * FROM produto_vendido;

            SELECT * FROM ESTOQUE
            WHERE PRODUTO = 5
            ORDER BY COD_ESTOQUE;
    
    -- 1 trigger na tabela lotes que ao fazer um insert, update ou delete faça a atualização do estoque do respectivo produto.
        -------- TRIGGER TG_ATUALIZACAO_LOTES --------
        CREATE OR REPLACE FUNCTION LOG_ATUALIZA_ESTOQUE_LOTE() RETURNS TRIGGER AS $LOG_ATUALIZA_ESTOQUE_LOTE$
        -- VARIAVEL QUE SERÁ UTILIZADA NA TRIGGER
        DECLARE
            VCOD_ESTOQUE RECORD;
            VESTOQUE RECORD;
            VVALOR_ATUAL NUMERIC;
            VVALOR_OPERACAO NUMERIC;
        BEGIN
            IF (NEW.COD_LOTE IS NOT NULL AND OLD.COD_LOTE IS NOT NULL) THEN --TG_OP = 'UPDATE'

                FOR VCOD_ESTOQUE IN
                SELECT
                    MAX(COD_ESTOQUE) AS CODIGO
                FROM ESTOQUE
                WHERE PRODUTO = NEW.PRODUTO
				LOOP
				END LOOP;

                FOR VESTOQUE IN
                SELECT
                    COD_ESTOQUE,
                    QTD_ANTERIOR,
                    QTD_ATUAL,
                    QTD_OPERACAO,
                    DATA_ESTOQUE,
                    PRODUTO,
                    TIPO_ESTOQUE,
                    TIPO_MOVIMENTACAO,
                    LOTE,
                    VENDA
                FROM ESTOQUE
                WHERE COD_ESTOQUE = VCOD_ESTOQUE.CODIGO
				LOOP

                IF (NEW.QTD_ITENS>OLD.QTD_ITENS) THEN
                    VVALOR_OPERACAO = NEW.QTD_ITENS-OLD.QTD_ITENS;
                    VVALOR_ATUAL = VESTOQUE.QTD_ATUAL + VVALOR_OPERACAO;
                ELSIF (NEW.QTD_ITENS<OLD.QTD_ITENS) THEN
                    VVALOR_OPERACAO = OLD.QTD_ITENS-NEW.QTD_ITENS;
                    VVALOR_ATUAL = VESTOQUE.QTD_ATUAL - VVALOR_OPERACAO;
                ELSE
                    VVALOR_OPERACAO = 0;
                    VVALOR_ATUAL = VESTOQUE.QTD_ATUAL;
                END IF;

				END LOOP;

                INSERT INTO ESTOQUE(QTD_ANTERIOR,QTD_ATUAL,QTD_OPERACAO,DATA_ESTOQUE,PRODUTO,TIPO_ESTOQUE,TIPO_MOVIMENTACAO,LOTE,VENDA)
                VALUES (VESTOQUE.QTD_ATUAL,VVALOR_ATUAL,VVALOR_OPERACAO,CURRENT_TIMESTAMP,VESTOQUE.PRODUTO,VESTOQUE.TIPO_ESTOQUE,VESTOQUE.TIPO_MOVIMENTACAO,VESTOQUE.LOTE,VESTOQUE.VENDA);
            
            END IF;
            IF (NEW.COD_LOTE IS NOT NULL AND OLD.COD_LOTE ISNULL) THEN --TG_OP = 'INSERT'

                FOR VCOD_ESTOQUE IN
                SELECT
                    MAX(COD_ESTOQUE) AS CODIGO
                FROM ESTOQUE
                WHERE PRODUTO = NEW.PRODUTO
				LOOP
				END LOOP;

                FOR VESTOQUE IN
                SELECT
                    COD_ESTOQUE,
                    QTD_ANTERIOR,
                    QTD_ATUAL,
                    QTD_OPERACAO,
                    DATA_ESTOQUE,
                    PRODUTO,
                    TIPO_ESTOQUE,
                    TIPO_MOVIMENTACAO,
                    LOTE,
                    VENDA
                FROM ESTOQUE
                WHERE COD_ESTOQUE = VCOD_ESTOQUE.CODIGO
                LOOP
                    VVALOR_ATUAL = VESTOQUE.QTD_ATUAL + NEW.QTD_ITENS;
				END LOOP;

                INSERT INTO ESTOQUE(QTD_ANTERIOR,QTD_ATUAL,QTD_OPERACAO,DATA_ESTOQUE,PRODUTO,TIPO_ESTOQUE,TIPO_MOVIMENTACAO,LOTE,VENDA)
                VALUES (VESTOQUE.QTD_ATUAL,VVALOR_ATUAL,NEW.QTD_ITENS,CURRENT_TIMESTAMP,VESTOQUE.PRODUTO,VESTOQUE.TIPO_ESTOQUE,VESTOQUE.TIPO_MOVIMENTACAO,VESTOQUE.LOTE,VESTOQUE.VENDA);
            END IF;
            IF (NEW.COD_LOTE ISNULL AND OLD.COD_LOTE IS NOT NULL) THEN --TG_OP = 'DELETE'

                FOR VCOD_ESTOQUE IN
                SELECT
                    MAX(COD_ESTOQUE) AS CODIGO
                FROM ESTOQUE
                WHERE PRODUTO = OLD.PRODUTO
				LOOP
				END LOOP;

                FOR VESTOQUE IN
                SELECT
                    COD_ESTOQUE,
                    QTD_ANTERIOR,
                    QTD_ATUAL,
                    QTD_OPERACAO,
                    DATA_ESTOQUE,
                    PRODUTO,
                    TIPO_ESTOQUE,
                    TIPO_MOVIMENTACAO,
                    LOTE,
                    VENDA
                FROM ESTOQUE
                WHERE COD_ESTOQUE = VCOD_ESTOQUE.CODIGO
				LOOP
                VVALOR_ATUAL = VESTOQUE.QTD_ATUAL - OLD.QTD_ITENS;
				END LOOP;

                INSERT INTO ESTOQUE(QTD_ANTERIOR,QTD_ATUAL,QTD_OPERACAO,DATA_ESTOQUE,PRODUTO,TIPO_ESTOQUE,TIPO_MOVIMENTACAO,LOTE,VENDA)
                VALUES (VESTOQUE.QTD_ATUAL,VVALOR_ATUAL,OLD.QTD_ITENS,CURRENT_TIMESTAMP,VESTOQUE.PRODUTO,VESTOQUE.TIPO_ESTOQUE,VESTOQUE.TIPO_MOVIMENTACAO,VESTOQUE.LOTE,VESTOQUE.VENDA);
            
            END IF;
			RETURN NEW;
        END;
        $LOG_ATUALIZA_ESTOQUE_LOTE$ LANGUAGE plpgsql;

        CREATE OR REPLACE TRIGGER TG_ATUALIZACAO_LOTES AFTER INSERT OR UPDATE OR DELETE ON LOTES
        FOR EACH ROW EXECUTE PROCEDURE LOG_ATUALIZA_ESTOQUE_LOTE();

        ------- Teste Insert -------
            INSERT INTO LOTES(DATA_ENTRADA,VECIMENTO,QTD_ITENS,PRODUTO,FORNECEDOR)
            VALUES('13/10/2022','13/10/2023',10,1,1);
        
        ------- Teste Delete -------
            DELETE FROM LOTES
            WHERE COD_LOTE = 8;

        ------- Teste Update -------
            UPDATE lotes
            SET qtd_itens = 10
            WHERE cod_lote = 5;

        ----------------------------
            SELECT * FROM LOTES
            ORDER BY COD_LOTE DESC;

            SELECT * FROM ESTOQUE
            ORDER BY COD_ESTOQUE DESC;
    
    -- 1 trigger de log da tabela venda, deve ser logada toda a operação de realizada na tabela, armazenado o registro anterior, 
    -- posterior, data e hora, usuário, e qual operação realizada. Criar uma tabela para armazenar este log.
        -------- TRIGGER TG_LOG_VENDAS --------

        CREATE TABLE LOG_VENDAS
        (
            REGISTRO_OLD TEXT NOT NULL,
            REGISTRO_NEW TEXT NOT NULL,
            DATA_HORA TIMESTAMP,
            OPERACAO CHAR(1) NOT NULL,
            USUARIO VARCHAR (30) NOT NULL
        );

        -- CRIAÇÃO DA TRIGGER
        CREATE OR REPLACE FUNCTION LOG_VENDAS() RETURNS TRIGGER AS $LOG_VENDAS$
        -- VARIAVEL QUE SERÁ UTILIZADA NA TRIGGER
            DECLARE VREGISTROOLD TEXT;
            VREGISTRONEW TEXT;
        BEGIN
            -- VERIFICA SE FOI FEITA ALGUMA ALTERAÇÃO (UPDATE)
            IF (NEW.COD_VENDAS IS NOT NULL AND OLD.COD_VENDAS IS NOT NULL) THEN --TG_OP = 'UPDATE'

                VREGISTROOLD = OLD.COD_VENDAS ||','|| OLD.OBSERVACAO || ',' || OLD.DATA_VENDA || ',' || OLD.VALOR_TOTAL || ',' || OLD.PESSOA;
                VREGISTRONEW = NEW.COD_VENDAS ||','|| NEW.OBSERVACAO || ',' || NEW.DATA_VENDA || ',' || NEW.VALOR_TOTAL || ',' || NEW.PESSOA;

                INSERT INTO LOG_VENDAS(DATA_HORA,USUARIO,OPERACAO,REGISTRO_OLD, REGISTRO_NEW)
                VALUES (CURRENT_TIMESTAMP, CURRENT_USER, 'U',VREGISTROOLD,VREGISTRONEW);

                RAISE NOTICE 'LOG DE UPDATE GRAVADO.';
                RETURN NEW;
            END IF;
            -- VERIFICA SE FOI FEITA ALGUMA INSERÇÃO
            IF (NEW.COD_VENDAS IS NOT NULL AND OLD.COD_VENDAS ISNULL) THEN --TG_OP = 'INSERT'

                VREGISTROOLD = '-';
                VREGISTRONEW = NEW.COD_VENDAS ||','|| NEW.OBSERVACAO || ',' || NEW.DATA_VENDA || ',' || NEW.VALOR_TOTAL || ',' || NEW.PESSOA;

                INSERT INTO LOG_VENDAS(DATA_HORA,USUARIO,OPERACAO,REGISTRO_OLD, REGISTRO_NEW)
                VALUES (CURRENT_TIMESTAMP, CURRENT_USER, 'I', VREGISTROOLD, VREGISTRONEW); 	
                RAISE NOTICE 'LOG DE INSERT GRAVADO.';
                RETURN NEW;
            END IF;
            --VERIFICA SE FOI FEITA ALGUMA DELEÇÃO
            IF (NEW.COD_VENDAS ISNULL AND OLD.COD_VENDAS IS NOT NULL) THEN --TG_OP = 'DELETE'
                VREGISTROOLD = OLD.COD_VENDAS ||','|| OLD.OBSERVACAO || ',' || OLD.DATA_VENDA || ',' || OLD.VALOR_TOTAL || ',' || OLD.PESSOA;
                VREGISTRONEW = '-';
                INSERT INTO LOG_VENDAS(DATA_HORA,USUARIO,OPERACAO,REGISTRO_OLD, REGISTRO_NEW)
                VALUES (CURRENT_TIMESTAMP, CURRENT_USER,'D', VREGISTROOLD, VREGISTRONEW); 	
                RAISE NOTICE 'LOG DE DELETE GRAVADO';
                RETURN OLD;
            END IF;
        END;
        $LOG_VENDAS$ LANGUAGE plpgsql;

        CREATE TRIGGER TG_LOG_VENDAS BEFORE INSERT OR UPDATE OR DELETE ON VENDAS
        FOR EACH ROW EXECUTE PROCEDURE LOG_VENDAS();

        ------- Teste Update -------
        UPDATE vendas
        SET valor_total = 15
        WHERE cod_vendas = 1

        ------- Teste Insert -------
        INSERT INTO vendas(observacao,data_venda,valor_total,pessoa)
        VALUES('Teste',CURRENT_TIMESTAMP,123,2); 
        
        ------- Teste Delete -------
        DELETE FROM VENDAS
        WHERE COD_VENDAS = 5

        ----------------------------
        SELECT * FROM vendas
        SELECT * FROM LOG_VENDAS
    
    -- 1 trigger de log da tabela despesas, deve ser logada toda a operação de realizada na tabela, armazenado o registro anterior, 
    -- posterior, data e hora, usuário, e qual operação realizada. Criar uma tabela para armazenar este log.
        -------- TRIGGER TG_LOG_DESPESAS --------

        CREATE TABLE LOG_DESPESAS
        (
            REGISTRO_OLD TEXT NOT NULL,
            REGISTRO_NEW TEXT NOT NULL,
            DATA_HORA TIMESTAMP,
            OPERACAO CHAR(1) NOT NULL,
            USUARIO VARCHAR (30) NOT NULL
        );

        -- CRIAÇÃO DA TRIGGER
        CREATE OR REPLACE FUNCTION LOG_DESPESAS() RETURNS TRIGGER AS $LOG_DESPESAS$
        -- VARIAVEL QUE SERÁ UTILIZADA NA TRIGGER
            DECLARE VREGISTROOLD TEXT;
            VREGISTRONEW TEXT;
        BEGIN
            -- VERIFICA SE FOI FEITA ALGUMA ALTERAÇÃO (UPDATE)
            IF (NEW.COD_DESPESA IS NOT NULL AND OLD.COD_DESPESA IS NOT NULL) THEN --TG_OP = 'UPDATE'

                VREGISTROOLD = OLD.COD_DESPESA ||','|| OLD.VALOR || ',' || OLD.OBSERVACAO || ',' || OLD.DATA_DESPESA || ',' || OLD.VENCIMENTO || ',' || OLD.PESSOA;
                VREGISTRONEW = NEW.COD_DESPESA ||','|| NEW.VALOR || ',' || NEW.OBSERVACAO || ',' || NEW.DATA_DESPESA || ',' || NEW.VENCIMENTO || ',' || NEW.PESSOA;

                INSERT INTO LOG_DESPESAS(DATA_HORA,USUARIO,OPERACAO,REGISTRO_OLD, REGISTRO_NEW)
                VALUES (CURRENT_TIMESTAMP, CURRENT_USER, 'U',VREGISTROOLD,VREGISTRONEW);

                RAISE NOTICE 'LOG DE UPDATE GRAVADO.';
                RETURN NEW;
            END IF;
            -- VERIFICA SE FOI FEITA ALGUMA INSERÇÃO
            IF (NEW.COD_DESPESA IS NOT NULL AND OLD.COD_DESPESA ISNULL) THEN --TG_OP = 'INSERT'

                VREGISTROOLD = '-';
                VREGISTRONEW = NEW.COD_DESPESA ||','|| NEW.VALOR || ',' || NEW.OBSERVACAO || ',' || NEW.DATA_DESPESA || ',' || NEW.VENCIMENTO || ',' || NEW.PESSOA;

                INSERT INTO LOG_DESPESAS(DATA_HORA,USUARIO,OPERACAO,REGISTRO_OLD, REGISTRO_NEW)
                VALUES (CURRENT_TIMESTAMP, CURRENT_USER, 'I', VREGISTROOLD, VREGISTRONEW); 
                
                RAISE NOTICE 'LOG DE INSERT GRAVADO.';
                RETURN NEW;
            END IF;
            --VERIFICA SE FOI FEITA ALGUMA DELEÇÃO
            IF (NEW.COD_DESPESA ISNULL AND OLD.COD_DESPESA IS NOT NULL) THEN --TG_OP = 'DELETE'
                
                VREGISTROOLD = OLD.COD_DESPESA ||','|| OLD.VALOR || ',' || OLD.OBSERVACAO || ',' || OLD.DATA_DESPESA || ',' || OLD.VENCIMENTO || ',' || OLD.PESSOA;
                VREGISTRONEW = '-';
                
                INSERT INTO LOG_DESPESAS(DATA_HORA,USUARIO,OPERACAO,REGISTRO_OLD, REGISTRO_NEW)
                VALUES (CURRENT_TIMESTAMP, CURRENT_USER,'D', VREGISTROOLD, VREGISTRONEW); 	
                
                RAISE NOTICE 'LOG DE DELETE GRAVADO';
                RETURN OLD;
            END IF;
        END;
        $LOG_DESPESAS$ LANGUAGE plpgsql;

        CREATE TRIGGER TG_LOG_DESPESAS BEFORE INSERT OR UPDATE OR DELETE ON DESPESAS
        FOR EACH ROW EXECUTE PROCEDURE LOG_DESPESAS();

        ------- Teste Update -------
        UPDATE despesas
        SET valor = 26
        WHERE cod_despesa = 2

        ------- Teste Insert -------
        INSERT INTO DESPESAS(valor,observacao,data_despesa,vencimento,pessoa)
        VALUES(15,'TESTE',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,1);
        
        ------- Teste Delete -------
        DELETE FROM despesas
        WHERE cod_despesa = 3

        ----------------------------
        SELECT * FROM despesas
        SELECT * FROM LOG_DESPESAS

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------- INSERTS --------

    -------- INSERTS TABELA ESTADOS --------
        INSERT INTO ESTADOS(NOME,SIGLA) VALUES('PARANA','PR');
        INSERT INTO ESTADOS(NOME,SIGLA) VALUES('SANTA CATARINA','SC');
        INSERT INTO ESTADOS(NOME,SIGLA) VALUES('RIO GRANDE DO SUL','RS');
        INSERT INTO ESTADOS(NOME,SIGLA) VALUES('SAO PAULO','SP');

    -------- INSERTS TABELA CIDADES --------
        INSERT INTO CIDADE(NOME,ESTADO) VALUES('BOM SUCESSO DO SUL', 1);
        INSERT INTO CIDADE(NOME,ESTADO) VALUES('PATO BRANCO', 1);
        INSERT INTO CIDADE(NOME,ESTADO) VALUES('PORTO ALEGRE', 3);

    -------- INSERTS TABELA TIPOS_PESSOA --------
        INSERT INTO TIPOS_PESSOA(TIPO_PESSOA) VALUES('FORNECEDOR');
        INSERT INTO TIPOS_PESSOA(TIPO_PESSOA) VALUES('CLIENTES');
        INSERT INTO TIPOS_PESSOA(TIPO_PESSOA) VALUES('OUTROS');
        INSERT INTO TIPOS_PESSOA(TIPO_PESSOA) VALUES('EMPREGADOS');

    -------- INSERTS TABELA PESSOAS --------
        INSERT INTO PESSOAS(NOME,RG,CPF_CNPJ,SALARIO,RUA,NUMERO,BAIRRO,CEP,TIPOS_PESSOA,CIDADE) VALUES('LOFF SISTEMAS',NULL,'123456789',NULL,'RUA','123','BAIRRO','85555555',1,3);
        INSERT INTO PESSOAS(NOME,RG,CPF_CNPJ,SALARIO,RUA,NUMERO,BAIRRO,CEP,TIPOS_PESSOA,CIDADE) VALUES('FERNANDO','123457','123456789',NULL,'RUA','123','BAIRRO','85555555',2,1);

    -------- INSERTS TABELA PRODUTOS --------
        INSERT INTO PRODUTOS(PRODUTO,PRECO) VALUES('CACHO DE BANANA',10.99);
        INSERT INTO PRODUTOS(PRODUTO,PRECO) VALUES('UM KG DE PICANHA',50.99);
        INSERT INTO PRODUTOS(PRODUTO,PRECO) VALUES('UM LITRO DE PEPSI',8.50);
        INSERT INTO PRODUTOS(PRODUTO,PRECO) VALUES('UM PACOTE DE BOLACHA',6);
        INSERT INTO PRODUTOS(PRODUTO,PRECO) VALUES('UMA DUZIA DE OVOS',8.70);

    -------- INSERTS TABELA TIPO_ESTOQUE --------
        INSERT INTO TIPO_ESTOQUE(DESCRICAO) VALUES('DEPOSITO');
        INSERT INTO TIPO_ESTOQUE(DESCRICAO) VALUES('PRATELEIRA');

    -------- INSERTS TABELA TIPO_MOVIMENTACAO --------
        INSERT INTO TIPO_MOVIMENTACAO(DESCRICAO) VALUES('COLOCADO NO ESTOQUE');
        INSERT INTO TIPO_MOVIMENTACAO(DESCRICAO) VALUES('COLOCADO NA PRATELEIRA');
        INSERT INTO TIPO_MOVIMENTACAO(DESCRICAO) VALUES('VENDIDO');


    -------- INSERTS TABELA LOTES --------
        INSERT INTO LOTES(PRODUTO,QTD_ITENS,FORNECEDOR,DATA_ENTRADA,VECIMENTO) VALUES(1,10,1,'13/10/2022','13/11/2022');
        INSERT INTO LOTES(PRODUTO,QTD_ITENS,FORNECEDOR,DATA_ENTRADA,VECIMENTO) VALUES(2,13.5,1,'13/10/2022','13/11/2022');
        INSERT INTO LOTES(PRODUTO,QTD_ITENS,FORNECEDOR,DATA_ENTRADA,VECIMENTO) VALUES(3,6,1,'13/10/2022','13/05/2023');
        INSERT INTO LOTES(PRODUTO,QTD_ITENS,FORNECEDOR,DATA_ENTRADA,VECIMENTO) VALUES(4,8,1,'13/10/2022','13/05/2023');
        INSERT INTO LOTES(PRODUTO,QTD_ITENS,FORNECEDOR,DATA_ENTRADA,VECIMENTO) VALUES(5,9,1,'13/10/2022','13/11/2022');

    -------- INSERTS TABELA ESTOQUE --------
        INSERT INTO ESTOQUE(PRODUTO,LOTE,QTD_ANTERIOR,QTD_ATUAL,QTD_OPERACAO,DATA_ESTOQUE,TIPO_ESTOQUE,TIPO_MOVIMENTACAO) VALUES(1,1,0,10,10,'13/10/2022',1,1);
        INSERT INTO ESTOQUE(PRODUTO,LOTE,QTD_ANTERIOR,QTD_ATUAL,QTD_OPERACAO,DATA_ESTOQUE,TIPO_ESTOQUE,TIPO_MOVIMENTACAO) VALUES(2,2,0,13.5,13.5,'13/10/2022',1,1);
        INSERT INTO ESTOQUE(PRODUTO,LOTE,QTD_ANTERIOR,QTD_ATUAL,QTD_OPERACAO,DATA_ESTOQUE,TIPO_ESTOQUE,TIPO_MOVIMENTACAO) VALUES(3,3,0,6,6,'13/10/2022',1,1);
        INSERT INTO ESTOQUE(PRODUTO,LOTE,QTD_ANTERIOR,QTD_ATUAL,QTD_OPERACAO,DATA_ESTOQUE,TIPO_ESTOQUE,TIPO_MOVIMENTACAO) VALUES(4,4,0,8,8,'13/10/2022',1,1);
        INSERT INTO ESTOQUE(PRODUTO,LOTE,QTD_ANTERIOR,QTD_ATUAL,QTD_OPERACAO,DATA_ESTOQUE,TIPO_ESTOQUE,TIPO_MOVIMENTACAO) VALUES(5,5,0,9,9,'13/10/2022',1,1);

        -------- PRODUTOS NA PRATELEIRA --------
            UPDATE ESTOQUE SET QTD_ANTERIOR=8, QTD_ATUAL=4, QTD_OPERACAO=4 WHERE COD_ESTOQUE=4;
            INSERT INTO ESTOQUE(PRODUTO,LOTE,QTD_ANTERIOR,QTD_ATUAL,QTD_OPERACAO,DATA_ESTOQUE,TIPO_ESTOQUE,TIPO_MOVIMENTACAO) VALUES(4,4,0,4,4,'13/10/2022',2,2);
            UPDATE ESTOQUE SET QTD_ANTERIOR=13.5, QTD_ATUAL=8.5, QTD_OPERACAO=5 WHERE COD_ESTOQUE=2;
            INSERT INTO ESTOQUE(PRODUTO,LOTE,QTD_ANTERIOR,QTD_ATUAL,QTD_OPERACAO,DATA_ESTOQUE,TIPO_ESTOQUE,TIPO_MOVIMENTACAO) VALUES(2,2,0,5,5,'13/10/2022',2,2);

    -------- INSERTS TABELA DESPESAS --------
        INSERT INTO DESPESAS(PESSOA,VALOR,MULTA,DATA_DESPESA,VENCIMENTO,DATA_PAGAMENTO,OBSERVACAO) VALUES(1,90,NULL,'13/10/2022','31/10/2022',NULL,'COMPRA DE BANANA');
        INSERT INTO DESPESAS(PESSOA,VALOR,MULTA,DATA_DESPESA,VENCIMENTO,DATA_PAGAMENTO,OBSERVACAO) VALUES(1,72,NULL,'13/10/2022','31/10/2022',NULL,'COMPRA DE OVO');

    -------- INSERTS TABELA VENDAS --------
        INSERT INTO VENDAS(PESSOA,VALOR_TOTAL,DATA_VENDA,OBSERVACAO) VALUES(2,12,'20/10/2022','VENDA DE BOLACHA');
        INSERT INTO VENDAS(PESSOA,VALOR_TOTAL,DATA_VENDA,OBSERVACAO) VALUES(2,100,'21/10/2022','VENDA DE PICANHA');

    -------- INSERTS TABELA PRODUTO_VENDIDO --------
        INSERT INTO PRODUTO_VENDIDO(COD_VENDAS,PRODUTO,QTD_VENDIDA,VALOR_UNITARIO) VALUES(1,4,2,6);
        INSERT INTO PRODUTO_VENDIDO(COD_VENDAS,PRODUTO,QTD_VENDIDA,VALOR_UNITARIO) VALUES(2,2,2,50);

    -------- INSERTS VENDAS NA TABELA ESTOQUE --------
        UPDATE ESTOQUE SET QTD_ANTERIOR=4, QTD_ATUAL=2, QTD_OPERACAO=2 WHERE COD_ESTOQUE=6;
        INSERT INTO ESTOQUE(PRODUTO,LOTE,QTD_ANTERIOR,QTD_ATUAL,QTD_OPERACAO,DATA_ESTOQUE,TIPO_ESTOQUE,TIPO_MOVIMENTACAO,VENDA) VALUES(4,4,0,2,2,'13/10/2022',2,3,1);
        UPDATE ESTOQUE SET QTD_ANTERIOR=5, QTD_ATUAL=3, QTD_OPERACAO=2 WHERE COD_ESTOQUE=7;
        INSERT INTO ESTOQUE(PRODUTO,LOTE,QTD_ANTERIOR,QTD_ATUAL,QTD_OPERACAO,DATA_ESTOQUE,TIPO_ESTOQUE,TIPO_MOVIMENTACAO,VENDA) VALUES(2,2,0,2,2,'13/10/2022',2,3,2);