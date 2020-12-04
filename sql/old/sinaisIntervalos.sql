set dateformat dmy
	declare @dtInicial datetime ='01/01/2020'
	declare @tempo int = 5
	declare @estrategia  varchar(100) = 'MINORIA_ULTIMAS_3'


	declare @tb table (par varchar(10), hora time, diasAntePenultimo int, diasPenultimo int, diasUltimo int, ultLoss date)

	declare @pares table (id int identity(1,1), par varchar(10))

	insert into @pares (par)
	select distinct par from velaM5

	declare @ip int = 1

	while @ip <= (select count(*) from @pares)
	begin
		declare @par varchar(10) = (select par from @pares where id = @ip)

		declare @hora time = '00:30'

		set nocount on

		while @hora >= '00:30'
		begin
			declare @ultLoss date 
			declare @penultimoLoss date
			declare @antePenultimoLoss date

			select top 1 @ultLoss = data from estrategias
			where par = @par and
				  tempo = @tempo and
				  hora = @hora and
				  estrategia = @estrategia and 
				  resultado = 'loss'
				  and DATEPART(dw, data) not in (1,7)
			order by data desc

			select top 1 @penultimoLoss = data from estrategias
			where par = @par and
				  tempo = @tempo and
				  hora = @hora and
				  estrategia = @estrategia and 
				  resultado = 'loss' and
				  data < @ultLoss
				  and DATEPART(dw, data) not in (1,7)
			order by data desc

			select top 1 @antePenultimoLoss = data from estrategias
			where par = @par and
				  tempo = @tempo and
				  hora = @hora and
				  estrategia = @estrategia and 
				  resultado = 'loss' and
				  data < @penultimoLoss and
				  DATEPART(dw, data) not in (1,7)
			order by data desc

			declare @diasAntePenultimo int = DATEDIFF(DAY, @antePenultimoLoss, @penultimoLoss)
			declare @diasPenultimo int = DATEDIFF(DAY, @penultimoLoss, @ultLoss)
			declare @diasUltimo int = DATEDIFF(DAY, @ultLoss, getdate())

			if (@diasAntePenultimo > 1 and @diasPenultimo > 1) 
			   and (@diasUltimo < ( @diasAntePenultimo + @diasPenultimo) / 2)
			begin
				insert into @tb (par, hora, diasAntePenultimo, diasPenultimo, diasUltimo, ultLoss)
				select @par, @hora, @diasAntePenultimo, @diasPenultimo, @diasUltimo, @ultLoss
			end



			set @hora = dateadd(MINUTE, 5, @hora)
		end

		set @ip += 1
	end
	set nocount off

	print @dtInicial



	select
@estrategia,  @tempo, par, convert(varchar(5), hora), diasAntePenultimo, diasPenultimo, diasUltimo, convert(varchar(10), ultLoss, 103) as ultLoss
,convert(varchar(5), hora) + ';' + convert(varchar(3), par) + '/' + substring(par, 4,3) + ';' + 
@estrategia + ';' + convert(varchar(10), @tempo) as b2IQ,
 '{ "par": "' + par + '", "horario": "'+ convert(varchar(5), hora) +'", "tempo": "' + convert(varchar(10),@tempo) +'"
 , "estrategia": "' + UPPER(@estrategia) +  
	'", "valor": "0'+
	'", "gale1": "0'+
	'", "gale2": "0'+
	'"},' as roboThiago

	from @tb a
	where ((diasAntePenultimo + diasPenultimo) / 2) - diasUltimo  > 20
	order by 
	((diasAntePenultimo + diasPenultimo) / 2) - diasUltimo desc