
set dateformat dmy
declare @dtInicial datetime = '11/01/2020'
declare @tb table (par varchar(10), sinal varchar(10), hora time, win0mg int, win1mg int, win2mg int, loss int, skip int, dias int, ultLoss datetime)

declare @pares table (id int identity(1,1), par varchar(10), sinal varchar(10))

insert into @pares (par, sinal)
select distinct par, sinal from putCallm5

declare @ip int = 1

while @ip <= (select count(*) from @pares)
begin

	declare @par varchar(10) = ''
	declare @sinal varchar(10) = ''

	select @par=par, @sinal = sinal from @pares where id = @ip

	declare @hora time = '00:15'


	while @hora >= '00:15'
	begin
		declare @win0mg int = 0
		declare @win1mg int = 0
		declare @win2mg int = 0
		declare @loss int = 0
		declare @skip int = 0
		declare @dias int = 0
		declare @dtUltLoss datetime

		select @win0mg = count(*) from putCallm5
		where par = @par and sinal = @sinal and hora = @hora and resultado = 'win' and martinGale = 0 and data >= @dtInicial
		and DATEPART(dw, data) not in (1,7)

		select @win1mg = count(*) from putCallm5
		where par = @par and sinal = @sinal and hora = @hora and resultado = 'win' and martinGale = 1 and data >= @dtInicial
		and DATEPART(dw, data) not in (1,7)

		select @win2mg = count(*) from putCallm5
		where par = @par and sinal = @sinal and hora = @hora and resultado = 'win' and martinGale = 2 and data >= @dtInicial
		and DATEPART(dw, data) not in (1,7)

		select @loss = count(*) from putCallm5
		where par = @par and sinal = @sinal and hora = @hora and resultado = 'loss' and data >= @dtInicial
		and DATEPART(dw, data) not in (1,7)

		select @skip = count(*) from putCallm5
		where par = @par and sinal = @sinal and hora = @hora and resultado = 'skip' and data >= @dtInicial
		and DATEPART(dw, data) not in (1,7)

		select @dias = count(*) from putCallm5
		where par = @par and sinal = @sinal and hora = @hora  and data >= @dtInicial
		and DATEPART(dw, data) not in (1,7)

		select @dtUltLoss = max(data) from putCallm5
		where par = @par and sinal = @sinal and hora = @hora and data >= @dtInicial and resultado = 'loss' 
		and DATEPART(dw, data) not in (1,7)

		insert into @tb values (@par, @sinal, @hora, @win0mg, @win1mg, @win2mg, @loss, @skip, @dias, @dtUltLoss)


		set @hora = dateadd(MINUTE, 15, @hora)
	end





	set @ip += 1
end


select par, sinal, hora, win0mg, win1mg, win2mg, loss, skip, dias, convert(varchar(10), ultLoss, 103) ultLoss, DATEPART(dw, ultLoss) as diaUltLoss from @tb
--where loss <= 5
order by loss,hora
--select distinct resultado from putCallm5
--truncate table putCallm5

--select par, hora, resultado, martinGale, count(*) from putCallm5
--where resultado = 'win'
--group by par, hora, resultado, martinGale

