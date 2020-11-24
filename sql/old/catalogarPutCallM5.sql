declare @tbPut table (id int identity(1,1),
par varchar(10),
data date,
hora time,
resultado varchar(10),
martinGale int)

declare @tbCall table (id int identity(1,1),
par varchar(10),
data date,
hora time,
resultado varchar(10),
martinGale int)

declare @i int = (select min(id) from velaM5 )

while @i <= (select max(id) from velaM5 )
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

	if @cor = 'g'
	begin
	   insert into @tbCall values (@par, @data, @hora, 'win', 0)

		select @cor = cor
		from velaM5
		where id = @i + 1 and par = @par

		if @cor = 'g'
		begin
			insert into @tbCall values (@par, @data, @hora, 'win', 1)
		end
		else
		begin
			select @cor = cor
			from velaM5
			where id = @i + 2 and par = @par

			if @cor = 'g'
				insert into @tbCall values (@par, @data, @hora, 'win', 2)
			else
				insert into @tbCall values (@par, @data, @hora, 'loss', 2)
		end

	end

	
	if @cor = 'r'
	begin
	   insert into @tbPut values (@par, @data, @hora, 'win', 0)

		select @cor = cor
		from velaM5
		where id = @i + 1 and par = @par

		if @cor = 'r'
		begin
			insert into @tbPut values (@par, @data, @hora, 'win', 1)
		end
		else
		begin
			select @cor = cor
			from velaM5
			where id = @i + 2 and par = @par

			if @cor = 'r'
				insert into @tbPut values (@par, @data, @hora, 'win', 2)
			else
				insert into @tbPut values (@par, @data, @hora, 'loss', 2)
		end

	end

	set @i += 1
end

insert into putCallM5 (par, sinal, data, hora, resultado,martinGale) 
select par, 'put' as sinal, data, hora, resultado,martinGale from @tbPut 
 
 insert into putCallM5 (par, sinal, data, hora, resultado,martinGale) 
select par, 'call' as sinal, data, hora, resultado,martinGale from @tbCall
 
select * from putCallM5

 --create table putCallM5 (id int identity(1,1),
 --par varchar(10),
 --data date,
 --hora time,
 --resultado varchar(10),
 --martinGale int)

 --select * from mhi5m
