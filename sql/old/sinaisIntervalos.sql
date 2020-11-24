set dateformat dmy
declare @dataInicial datetime =  '01/05/2020'


declare @tb table (id int identity(1,1), par varchar(20), hora time)

insert into @tb (par, hora)
select distinct par, hora from mhi5m
order by par, hora

declare @i int = 1

while @i <= (select COUNT(*) from @tb)
begin
	declare @par varchar(20) = 'EURUSD'
	declare @hora time = '12:15'

	select @par = par,
		   @hora = hora
	from @tb
	where id = @i



	--select * from mhi5m
	--where par =	@par and hora = @hora and resultado = 'loss' and data > @dataInicial

	declare @tbDias table (id int identity(1,1),data date)
	insert into @tbDias (data)
	select data from mhi5m
	where par =	@par and hora = @hora and resultado = 'loss' and data > @dataInicial

	declare @d int = 1
	declare @minDias int = 999999
	declare @sumDias int = 0
	declare @medDias int = 0
	declare @dias int = 0
	declare @diasSemLoss int = 0

	while @d <= (select count(*) from @tbDias )
	begin
		--set @minDias = 999999
		--set @sumDias = 0
		--set @medDias = 0
		--set @dias = 0
		--set @diasSemLoss = 0

		select @dias = DATEDIFF(DAY, b.data, a.data)
		from @tbDias a,
				@tbDias b 
		where a.id = @d and b.id = @d - 1

		if (@d = (select count(*) from @tbDias))
		begin
			select @dias = DATEDIFF(DAY, a.data, getdate())
			from @tbDias a
			where a.id = @d 

			set @diasSemLoss = @dias
		end

		if @minDias > @dias and @dias > 0
		   set @minDias = @dias

		set @sumDias += @dias

		set @medDias = @sumDias / (select count(*) from @tbDias) 

		

		set @d += 1
	end

	insert into sinaisIntervalosMHI5 values (@par, @hora, @minDias, @medDias, @diasSemLoss, @sumDias)

	set @i += 1
end

select * from sinaisIntervalosMHI5

-- truncate table sinaisIntervalosMHI5

--print 'min: ' + convert(varchar(10), @minDias)
--print 'sum: ' + convert(varchar(10), @sumDias)
--print 'med: ' + convert(varchar(10), @medDias)
--print 'sem: ' + convert(varchar(10), @diasSemLoss)
--print '-------------------------------------------'


