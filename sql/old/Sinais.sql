set dateformat dmy
	declare @dtInicial datetime ='01/10/2020'
	declare @tempo int = 5 
	declare @estrategia  varchar(10) = 'MHI_MENOR'


	declare @tb table (par varchar(10), hora time, win0mg int, win1mg int, win2mg int, loss int, skip int, dias int, ultLoss datetime)

	declare @pares table (id int identity(1,1), par varchar(10))

	insert into @pares (par)
	select distinct par from velaM5

	declare @ip int = 1

	while @ip <= (select count(*) from @pares)
	begin
		declare @par varchar(10) = (select par from @pares where id = @ip)

		declare @hora time = '00:15'

		set nocount on

		while @hora >= '00:15'
		begin
			declare @win0mg int = 0
			declare @win1mg int = 0
			declare @win2mg int = 0
			declare @loss int = 0
			declare @skip int = 0
			declare @dias int = 0
			declare @dtUltLoss datetime

			select @win0mg = count(*) from estrategias
			where par = @par and hora = @hora and resultado = 'win' and martinGale = 0 and data >= @dtInicial
			and tempo = @tempo
			and estrategia = @estrategia
			and DATEPART(dw, data) not in (1,7)

			select @win1mg = count(*) from estrategias
			where par = @par and hora = @hora and resultado = 'win' and martinGale = 1 and data >= @dtInicial
			and tempo = @tempo
			and estrategia = @estrategia
			and DATEPART(dw, data) not in (1,7)

			select @win2mg = count(*) from estrategias
			where par = @par and hora = @hora and resultado = 'win' and martinGale = 2 and data >= @dtInicial
			and tempo = @tempo
			and estrategia = @estrategia
			and DATEPART(dw, data) not in (1,7)

			select @loss = count(*) from estrategias
			where par = @par and hora = @hora and resultado = 'loss' and data >= @dtInicial
			and tempo = @tempo
			and estrategia = @estrategia
			and DATEPART(dw, data) not in (1,7)

			select @skip = count(*) from estrategias
			where par = @par and hora = @hora and resultado = 'skip' and data >= @dtInicial
			and tempo = @tempo
			and estrategia = @estrategia
			and DATEPART(dw, data) not in (1,7)

			select @dias = count(*) from estrategias
			where par = @par and hora = @hora  and data >= @dtInicial
			and tempo = @tempo
			and estrategia = @estrategia
			and DATEPART(dw, data) not in (1,7)

			select @dtUltLoss = max(data) from estrategias
			where par = @par and hora = @hora  and resultado = 'loss' 
			and tempo = @tempo
			and estrategia = @estrategia
			and DATEPART(dw, data) not in (1,7)
			insert into @tb values (@par, @hora, @win0mg, @win1mg, @win2mg, @loss, @skip, @dias, @dtUltLoss)


			set @hora = dateadd(MINUTE, 5, @hora)
		end

		set @ip += 1
	end
	set nocount off

	print @dtInicial



	select a.par, a.hora, a.win0mg, a.win1mg, a.win2mg, a.loss, a.skip, a.dias, a.ultLoss, @dtInicial
	from @tb a
	order by ultLoss