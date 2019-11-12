/*
 * UNICAMP - Faculdade de Tecnologia
 * Limeira - SP
 *
 * Disciplina ST767 - Banco de Dados II
 * Projeto: Loja de salgados
 *
 *		Grupo Siquel�
 *
 *		Kevin Barrios
 *		Leonardo Alberto
 *		Matheus Bruder
 *		Matheus Rosisca
 *		Vinicius Ito
 *
 */

-- *********************************************************************************
-- SCRIPT: Manipulacao Database - PROCEDURES
-- *********************************************************************************

	/* Cadastro de Fornecedor */
	create procedure cadastro_fornecedor
	@codpessoa numeric(12,0),
	@nome varchar(40),
	@rua varchar(50),
	@numero int,
	@cep int,
	@cnpj int,
	@razaosocial varchar(40)
	as
	begin transaction
		insert into Pessoa(codpessoa, nome, rua, numero, cep, tipo)
		values(@codpessoa, @nome, @rua, @numero, @cep, 0)
		if @@ROWCOUNT > 0
			begin
				insert into Fornecedor(codpessoa, cnpj, razao_social)
				values(@codpessoa, @cnpj, @razaosocial)
				if @@ROWCOUNT > 0
					begin	
						commit transaction
						return 1
					end
				else
					begin
						rollback transaction
						return 0
					end
			end
		else
			begin
				rollback transaction
				return 0
			end

	

	/* Cadastro de Cliente */
	create procedure cadastro_cliente
	@codpessoa numeric(12,0),
	@nome varchar(40),
	@rua varchar(50),
	@numero int,
	@cep int,
	@CPF int,
	@dtnascimento date,
	@telefone int,
	@email varchar(50)
	as
	begin transaction
		if not exists (select * from Pessoa where codpessoa = @codpessoa)
		begin
			insert into Pessoa(codpessoa, nome, rua, numero, cep, tipo)
			values(@codpessoa, @nome, @rua, @numero, @cep, 1)
			if @@ROWCOUNT > 0
				begin
					insert into Pessoa_Fisica
					values(@codpessoa, @CPF, @dtnascimento, @telefone, @email)
					if @@ROWCOUNT = 0
						begin 
							rollback transaction
							return 0
						end
				end
		end
		insert into Cliente 
		values(@codpessoa, 0, 'N', 'N')
		if @@ROWCOUNT > 0
			begin 
				commit transaction
				return 1
			end
		else
			begin
				rollback transaction
				return 0
			end





	/* Cadastro de Colaborador */
	create procedure cadastro_colaborador
	@codpessoa numeric(12,0),
	@nome varchar(40),
	@rua varchar(50),
	@numero int,
	@cep int,
	@CPF int,
	@dtnascimento date,
	@telefone int,
	@email varchar(50),
	@login varchar(30),
	@senha varchar(50),
	@salario money
	as
	begin transaction
		if not exists (select * from Pessoa where codpessoa = @codpessoa)
		begin
			insert into Pessoa(codpessoa, nome, rua, numero, cep, tipo)
			values(@codpessoa, @nome, @rua, @numero, @cep, 1)
			if @@ROWCOUNT > 0
				begin
					insert into Pessoa_Fisica
					values(@codpessoa, @CPF, @dtnascimento, @telefone, @email)
					if @@ROWCOUNT = 0
						begin 
							rollback transaction
							return 0
						end
				end
		end
		insert into Colaborador 
		values(@codpessoa, @login, @senha, @salario, 0, 0)
		if @@ROWCOUNT > 0
			begin 
				commit transaction
				return 1
			end
		else
			begin
				rollback transaction
				return 0
			end




	/* Cadastro de Produto Fabricado */
	create procedure cadastro_prod_fabricado
	@codproduto numeric(12,0),
	@nome varchar(50),
	@preco money,
	@qntestoque int,
	@dtfabricacao date
	as
	begin transaction
		insert into Produto(codproduto, nome, preco, qntestoque, dtfabricacao, dtvencimento, tipo)
		values(@codproduto, @nome, @preco, @qntestoque, @dtfabricacao, DATEADD(day, 7, @dtfabricacao), 0)
		if @@ROWCOUNT > 0
			begin
				insert into Produto_Fabricado(codproduto)
				values(@codproduto)
				if @@ROWCOUNT > 0
				begin
					commit transaction
					return 1
				end
			end
		else
			begin
				rollback transaction
				return 0
			end

	


	/* Cadastro de Produto Industrial */
	create procedure cadastro_prod_industrial
	@codproduto numeric(12,0),
	@nome varchar(50),
	@preco money,
	@qntestoque int,
	@dtfabricacao date,
	@dtvencimento date
	as
	begin transaction
		insert into Produto(codproduto, nome, preco, qntestoque, dtfabricacao, dtvencimento, tipo)
		values(@codproduto, @nome, @preco, @qntestoque, @dtfabricacao, @dtvencimento, 1)
		if @@ROWCOUNT > 0
			begin
				insert into Produto_Fabricado(codproduto)
				values(@codproduto)
				if @@ROWCOUNT > 0
				begin
					commit transaction
					return 1
				end
			end
		else
			begin
				rollback transaction
				return 0
			end

	

	/* Cadastro de Venda */
	create procedure venda
	@numnota numeric(12,0),
	@codprod numeric(12,0),
	@quantidade int,
	@codcliente numeric(12,0),
	@codcolaborador numeric(12,0)
	as
	begin transaction
		if not exists (select * from NF_VENDA where numnota = @numnota)
		begin
			insert into NF_VENDA(numnota, valortotal, data, cod_col, cod_cli)
			values(@numnota, 0, GETDATE(), @codcolaborador, @codcliente)
		end
		insert into itemnotafiscal(numnota, codprod, quantidade)
		values(@numnota, @codprod, @quantidade)
		if @@ROWCOUNT > 0
			begin
				update NF_VENDA
				set valortotal = valortotal + (@quantidade * (select preco from Produto where codproduto = @codprod))
				where numnota = @numnota
				if @@ROWCOUNT > 0
					begin
						update Produto
						set qntestoque = qntestoque - @quantidade
						where codproduto = @codprod
						if @@ROWCOUNT > 0
							begin
								commit transaction
								return 1
							end
					end
				else
					begin
						rollback transaction
						return 0
					end
			end
		else
			begin
				rollback transaction
				return 0
			end

	


	/* Alterar status do cliente */
	create procedure alt_status_cliente
	@nome_cli varchar(40),
	@fidelidade char(1),
	@premium char(1)
	as
	begin transaction
		declare @cod numeric(12,0)
		set @cod = (select codpessoa from Pessoa where nome = @nome_cli)
		if not exists (select codpessoa from Pessoa where nome = @nome_cli)
		begin
			rollback transaction
			print 'N�o h� cliente com esse nome'
		end
		update Cliente
		set cliente_fidelidade = @fidelidade, cliente_premium = @premium
		where codpessoa = @cod
		if @@ROWCOUNT > 0
			begin
				commit transaction
				return 1
			end
		else
			begin
				rollback transaction
				return 0
			end

		

-- *********************************************************************************
-- SCRIPT: Manipulacao Database - EXEC's
-- *********************************************************************************

	-- EXECUCAO cadastro_fornecedor
	declare @ret int
	exec @ret = cadastro_fornecedor 1, 'Marcos Pontes', 'R. Jasmins', 152, 8746512, 233215468, 'Supermercado do Bairro'
	print @ret

	-- EXECUCAO cadastro_cliente
	declare @ret int
	exec @ret = cadastro_cliente 2, 'Matheus Bruder', 'R. Esmeralda', 152, 8746512, 233215468, '1999-03-24', 997004045, 'm@bol.com'
	print @ret

	-- EXECUCAO cadastro_colaborador
	declare @ret int
	exec @ret = cadastro_colaborador 3, 'Joao da Silva', 'R. Mar', 46, 945651, 161516, '2000-05-24', 997004045, 'm@bol.com', 'joao', '123', '2000'
	print @ret

	-- EXECUCAO cadastro_prod_fabricado
	declare @ret int
	exec @ret = cadastro_prod_fabricado 26, 'Coxinha de frango', '2.5', 500, '2019-11-12'
	print @ret

	-- EXECUCAO cadastro_prod_industrial
	declare @ret int
	exec @ret = cadastro_prod_industrial 27, 'Coca-cola', '3.5', 50, '2019-10-12', '2020-02-01'
	print @ret

	-- EXECUCAO venda
	declare @ret int
	exec @ret = venda 1, 1, 1, 120, 30
	print @ret

	-- EXECUCAO alt_status_cliente
	declare @ret int
	exec @ret = alt_status_cliente 'Duncan Vargas', 'S', 'S'
	print @ret


		select * from NF_VENDA
		select * from itemnotafiscal
		
		select * from Pessoa
		select * from Pessoa_Fisica
		select * from Cliente
		select * from Colaborador

		select * from Produto
		select * from Produto_Fabricado
		select * from Produto_Industrial