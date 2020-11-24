
set dateformat dmy

declare @meses int = 2


while @meses <= 11
begin
	declare @dtInicial datetime = dateadd(MONTH, @meses, '01/11/2019')


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

			select @win0mg = count(*) from maioriaMHI5m
			where par = @par and hora = @hora and resultado = 'win' and martinGale = 0 and data >= @dtInicial
			and DATEPART(dw, data) not in (1,7)

			select @win1mg = count(*) from maioriaMHI5m
			where par = @par and hora = @hora and resultado = 'win' and martinGale = 1 and data >= @dtInicial
			and DATEPART(dw, data) not in (1,7)

			select @win2mg = count(*) from maioriaMHI5m
			where par = @par and hora = @hora and resultado = 'win' and martinGale = 2 and data >= @dtInicial
			and DATEPART(dw, data) not in (1,7)

			select @loss = count(*) from maioriaMHI5m
			where par = @par and hora = @hora and resultado = 'loss' and data >= @dtInicial
			and DATEPART(dw, data) not in (1,7)

			select @skip = count(*) from maioriaMHI5m
			where par = @par and hora = @hora and resultado = 'skip' and data >= @dtInicial
			and DATEPART(dw, data) not in (1,7)

			select @dias = count(*) from maioriaMHI5m
			where par = @par and hora = @hora  and data >= @dtInicial
			and DATEPART(dw, data) not in (1,7)

			select @dtUltLoss = max(data) from maioriaMHI5m
			where par = @par and hora = @hora  and resultado = 'loss' 
			and DATEPART(dw, data) not in (1,7)

			insert into @tb values (@par, @hora, @win0mg, @win1mg, @win2mg, @loss, @skip, @dias, @dtUltLoss)


			set @hora = dateadd(MINUTE, 5, @hora)
		end

		set @ip += 1
	end
	set nocount off

	print @dtInicial

	declare @minLoss int = 0
	select @minLoss = min(a.loss) from @tb a
	left join sinaisMHIM5_Maioria b on a.par = b.par and a.hora = b.hora
	where b.par is null
	

	insert into sinaisMHIM5_Maioria (par, hora, win0mg, win1mg, win2mg, loss, skip, dias, ultLoss, dtConsulta)
	select a.par, a.hora, a.win0mg, a.win1mg, a.win2mg, a.loss, a.skip, a.dias, a.ultLoss, @dtInicial
	from @tb a
	left join sinaisMHIM5_Maioria b on a.par = b.par and a.hora = b.hora
	where a.loss = @minLoss and b.par is null	

	set @meses += 1
end

declare @tbs table (id int identity(1,1),
					par varchar(20),
					hora time,
					dtConsulta datetime)

insert into @tbs (par, hora)
select  par, hora from sinaisMHIM5_Maioria 
group by par, hora

declare @i int = 1
while @i <= (select count(*) from @tbs)
begin
	
	declare @pars varchar(20) = ''
	declare @horas time
	declare @idMIn int

	select top 1 @pars = par, @horas = hora from @tbs
	where id = @i

	select @idMIn = min(id)
	from sinaisMHIM5_Maioria 
	where par = @pars and hora = @horas

	delete sinaisMHIM5_Maioria
	where par = @pars and hora = @horas and id > @idMIn

	set @i += 1
end

delete sinaisMHIM5_Maioria where dias < 30


select * from sinaisMHIM5_Maioria 
order by hora


--{ "par": "EURUSD", "hora": "10", "minuto" : "15" }
select '{ "par": "' + par + '", "hora": "'+ convert(varchar(2), datepart(HOUR,hora)) +'", "minuto" : "'+ convert(varchar(2), datepart(MINUTE,hora)) +'" },'
from sinaisMHIM5_Maioria 
order by hora