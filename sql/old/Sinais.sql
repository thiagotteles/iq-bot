set dateformat dmy
	declare @dtInicial datetime ='01/01/2020'
	declare @tempo int = 15
	declare @estrategia  varchar(100) = 'CALL'
	declare @impacto int = 0

	declare @tb table (par varchar(10), hora time, win0mg int, win1mg int, win2mg int, loss int, skip int, dias int, ultLoss datetime)

	declare @pares table (id int identity(1,1), par varchar(10))

	insert into @pares (par)
	select distinct par from velaM15

	declare @ip int = 1

	while @ip <= (select count(*) from @pares)
	begin
		declare @par varchar(10) = (select par from @pares where id = @ip)

		declare @hora time = '00:30'

		set nocount on

		while @hora >= '00:30'
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
			and DATEPART(dw, data) not in (7)
			and (impactoNoticia is null or impactoNoticia <= @impacto)

			select @win1mg = count(*) from estrategias
			where par = @par and hora = @hora and resultado = 'win' and martinGale = 1 and data >= @dtInicial
			and tempo = @tempo
			and estrategia = @estrategia
			and DATEPART(dw, data) not in (7)
			and (impactoNoticia is null or impactoNoticia <= @impacto)

			select @win2mg = count(*) from estrategias
			where par = @par and hora = @hora and resultado = 'win' and martinGale = 2 and data >= @dtInicial
			and tempo = @tempo
			and estrategia = @estrategia
			and DATEPART(dw, data) not in (7)
			and (impactoNoticia is null or impactoNoticia <= @impacto)

			select @loss = count(*) from estrategias
			where par = @par and hora = @hora and resultado = 'loss' and data >= @dtInicial
			and tempo = @tempo
			and estrategia = @estrategia
			and DATEPART(dw, data) not in (7)
			and (impactoNoticia is null or impactoNoticia <= @impacto)

			select @skip = count(*) from estrategias
			where par = @par and hora = @hora and resultado = 'skip' and data >= @dtInicial
			and tempo = @tempo
			and estrategia = @estrategia
			and DATEPART(dw, data) not in (7)
			and (impactoNoticia is null or impactoNoticia <= @impacto)

			select @dias = count(*) from estrategias
			where par = @par and hora = @hora  and data >= @dtInicial
			and tempo = @tempo
			and estrategia = @estrategia
			and DATEPART(dw, data) not in (7)
			and (impactoNoticia is null or impactoNoticia <= @impacto)

			select @dtUltLoss = max(data) from estrategias
			where par = @par and hora = @hora  and resultado = 'loss' 
			and tempo = @tempo
			and estrategia = @estrategia
			and DATEPART(dw, data) not in (7)
			and (impactoNoticia is null or impactoNoticia <= @impacto)

			insert into @tb values (@par, @hora, @win0mg, @win1mg, @win2mg, @loss, @skip, @dias, @dtUltLoss)


			set @hora = dateadd(MINUTE, 30, @hora)
		end

		set @ip += 1
	end
	set nocount off

	print @dtInicial



	select
@estrategia,  @tempo, par, convert(varchar(5), hora), win0mg, win1mg, win2mg, skip, dias, dias/(loss + 1) as dif, loss, convert(varchar(10), ultLoss, 103) as ultLoss,
'','','','','',
 '{ "par": "' + par + '", "horario": "'+ convert(varchar(5), hora) +'", "tempo": "' + convert(varchar(10),@tempo) +'"
 , "estrategia": "' + UPPER(@estrategia) +  
	'", "valor": "0'+
	'", "gale1": "0'+
	'", "gale2": "0'+
	'"},' as roboThiago

	from @tb a

	order by 
	--loss 
	--dias/(loss + 1) desc
	convert(datetime,convert(varchar(10), ultLoss, 103)) asc
