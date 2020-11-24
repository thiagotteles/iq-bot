--SELECT * FROM velaM5

declare @i int = 1

while @i <= 10
begin
	declare @cor char(1)
	declare @par varchar(10) = ''
	declare @hora time
	declare @data datetime
	declare @countr int = 0
	declare @countg int = 0
	declare @countd int = 0
	declare @dirWin char(1) = ''

	select @par=par,
		   @hora=convert(time,abertura),
		   @data = convert(date, abertura),
		   @cor = cor
	from velaM5
	where id = @i

	select @countg = count(*) 
	from velaM5 
	where id between @i - 3 and @i - 1 and cor = 'g' and par = @par

	select @countr = count(*) 
	from velaM5 
	where id between @i - 3 and @i - 1 and cor = 'r' and par = @par

	select @countd = count(*) 
	from velaM5 
	where id between @i - 3 and @i - 1 and cor = 'd' and par = @par

	if @countd > 0
		set @dirWin = 'd'
	else if @countg > @countr 
		set @dirWin = 'r'
	else if @countr > @countg
		set @dirWin = 'g'


	if (DATEPART(MINUTE,(@hora)) in (0,15,30,45))
	begin
		print convert(varchar(1), @countg) + '' + convert(varchar(1), @countr) + '' + convert(varchar(1), @countd)

		if @cor = @dirWin
			insert into mhi5m values (@data, @hora, 'win', 0)
		else
		begin
			select @cor = cor
			from velaM5
			where id = @i + 1 and par = @par

			if @cor = @dirWin
				insert into mhi5m values (@data, @hora, 'win', 1)
			else
			begin
				select @cor = cor
				from velaM5
				where id = @i + 2 and par = @par

				if @cor = @dirWin
					insert into mhi5m values (@data, @hora, 'win', 2)
				else
					insert into mhi5m values (@data, @hora, 'loss', 2)
			end

		end

	end

	print @hora

	set @i += 1
end

update velaM5
set bCatalogado = 1

