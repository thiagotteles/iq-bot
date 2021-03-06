USE [iqBot]
GO
/****** Object:  UserDefinedFunction [dbo].[fnPadraoVelas]    Script Date: 15/11/2020 23:07:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Function [dbo].[fnPadraoVelas]      
(      
 @v1 char(1),
 @v2 char(1), 
 @v3 char(1)
)       
returns varchar(100)      
as      
Begin      
      
declare @ret  varchar(200) = ''

if (@v1 = @v2 and @v2 = @v3)
	set @ret = 'Tres iguais'
if (@v1 = @v3 and @v2 <> @v1)
	set @ret = 'Menor no meio'
if (@v1 = @v2 and @v3 <> @v1)
	set @ret = 'Menor na ultima'
if (@v3 = @v2 and @v3 <> @v1)
	set @ret = 'Menor na primeia'
if (@v1 = 'd' or @v2 = 'd' or @v3 = 'd')
	set @ret = 'Dogi'
 return @ret      
      
      
End      
      
GO
/****** Object:  Table [dbo].[estrategias]    Script Date: 15/11/2020 23:07:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[estrategias](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[estrategia] [varchar](200) NULL,
	[tempo] [int] NULL,
	[par] [varchar](20) NULL,
	[data] [date] NULL,
	[hora] [time](7) NULL,
	[resultado] [varchar](10) NULL,
	[martinGale] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[sinais]    Script Date: 15/11/2020 23:07:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sinais](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[estrategia] [varchar](200) NULL,
	[tempo] [int] NULL,
	[par] [varchar](20) NULL,
	[hora] [time](7) NULL,
	[win0mg] [int] NULL,
	[win1mg] [int] NULL,
	[win2mg] [int] NULL,
	[skip] [int] NULL,
	[dias] [int] NULL,
	[loss] [int] NULL,
	[ultLoss] [datetime] NULL,
	[dtConsulta] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[velaM15]    Script Date: 15/11/2020 23:07:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[velaM15](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[par] [varchar](10) NULL,
	[abertura] [datetime] NULL,
	[cor] [char](1) NULL,
	[bCatalogadoMHI] [bit] NULL,
	[bCatalogadoMHI_Maioria] [bit] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[velaM5]    Script Date: 15/11/2020 23:07:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[velaM5](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[par] [varchar](10) NULL,
	[abertura] [datetime] NULL,
	[cor] [char](1) NULL,
	[bCatalogadoMHI] [bit] NULL,
	[bCatalogadoMHI_Maioria] [bit] NULL,
	[bCatalogado3Vizinhos] [bit] NULL
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[spCatalogar_15M_MHI_MAIOR]    Script Date: 15/11/2020 23:07:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--SELECT * FROM velaM15

create proc [dbo].[spCatalogar_15M_MHI_MAIOR]	
as

DELETE estrategias 
where tempo = 15 and estrategia = 'MHI_MAIOR'

update velaM15
set bCatalogadoMHI = 0

declare @i int = (select min(id) from velaM15 where bCatalogadoMHI = 0)

while @i <= (select max(id) from velaM15 where bCatalogadoMHI = 0)
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
	from velaM15
	where id = @i

	select @countg = count(*) 
	from velaM15 
	where id between @i - 3 and @i - 1 and cor = 'g' and par = @par

	select @countr = count(*) 
	from velaM15 
	where id between @i - 3 and @i - 1 and cor = 'r' and par = @par

	select @countd = count(*) 
	from velaM15 
	where id between @i - 3 and @i - 1 and cor = 'd' and par = @par

	if @countd > 0
		set @dirWin = 'd'
	else if @countg > @countr 
		set @dirWin = 'g'
	else if @countr > @countg
		set @dirWin = 'r'


	--if (DATEPART(MINUTE,(@hora)) in (0,15,30,45))
	--begin
		--print convert(varchar(1), @countg) + '' + convert(varchar(1), @countr) + '' + convert(varchar(1), @countd)
		if @dirWin = 'd'
			insert into estrategias values ('MHI_MAIOR', 15, @par, @data, @hora, 'skip', 0)
		else if @cor = @dirWin
			insert into estrategias values ('MHI_MAIOR', 15, @par, @data, @hora, 'win', 0)
		else
		begin
			select @cor = cor
			from velaM15
			where id = @i + 1 and par = @par

			if @cor = @dirWin
				insert into estrategias values ('MHI_MAIOR', 15, @par, @data, @hora, 'win', 1)
			else
			begin
				select @cor = cor
				from velaM15
				where id = @i + 2 and par = @par

				if @cor = @dirWin
					insert into estrategias values ('MHI_MAIOR', 15, @par, @data, @hora, 'win', 2)
				else
					insert into estrategias values ('MHI_MAIOR', 15, @par, @data, @hora, 'loss', 2)
			end

		--end

	end

	print @i

	set @i += 1
end

update velaM15
set bCatalogadoMHI = 1
GO
/****** Object:  StoredProcedure [dbo].[spCatalogar_15M_MHI_MENOR]    Script Date: 15/11/2020 23:07:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--SELECT * FROM velaM15

create proc [dbo].[spCatalogar_15M_MHI_MENOR]
as

DELETE estrategias 
where tempo = 15 and estrategia = 'MHI_MENOR'

update velaM15
set bCatalogadoMHI = 0

declare @i int = (select min(id) from velaM15 where bCatalogadoMHI = 0)

while @i <= (select max(id) from velaM15 where bCatalogadoMHI = 0)
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
	from velaM15
	where id = @i

	select @countg = count(*) 
	from velaM15 
	where id between @i - 3 and @i - 1 and cor = 'g' and par = @par

	select @countr = count(*) 
	from velaM15 
	where id between @i - 3 and @i - 1 and cor = 'r' and par = @par

	select @countd = count(*) 
	from velaM15 
	where id between @i - 3 and @i - 1 and cor = 'd' and par = @par

	if @countd > 0
		set @dirWin = 'd'
	else if @countg > @countr 
		set @dirWin = 'r'
	else if @countr > @countg
		set @dirWin = 'g'


	--if (DATEPART(MINUTE,(@hora)) in (0,15,30,45))
	--begin
		--print convert(varchar(1), @countg) + '' + convert(varchar(1), @countr) + '' + convert(varchar(1), @countd)
		if @dirWin = 'd'
			insert into estrategias values ('MHI_MENOR', 15, @par, @data, @hora, 'skip', 0)
		else if @cor = @dirWin
			insert into estrategias values ('MHI_MENOR', 15, @par, @data, @hora, 'win', 0)
		else
		begin
			select @cor = cor
			from velaM15
			where id = @i + 1 and par = @par

			if @cor = @dirWin
				insert into estrategias values ('MHI_MENOR', 15, @par, @data, @hora, 'win', 1)
			else
			begin
				select @cor = cor
				from velaM15
				where id = @i + 2 and par = @par

				if @cor = @dirWin
					insert into estrategias values ('MHI_MENOR', 15, @par, @data, @hora, 'win', 2)
				else
					insert into estrategias values ('MHI_MENOR', 15, @par, @data, @hora, 'loss', 2)
			end

		--end

	end

	print @i

	set @i += 1
end

update velaM15
set bCatalogadoMHI = 1
GO
/****** Object:  StoredProcedure [dbo].[spCatalogar_5M_MHI_MAIOR]    Script Date: 15/11/2020 23:07:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--SELECT * FROM velaM5

create proc [dbo].[spCatalogar_5M_MHI_MAIOR]	
as

DELETE estrategias 
where tempo = 5 and estrategia = 'MHI_MAIOR'

update velaM5
set bCatalogadoMHI = 0

declare @i int = (select min(id) from velaM5 where bCatalogadoMHI = 0)

while @i <= (select max(id) from velaM5 where bCatalogadoMHI = 0)
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
		set @dirWin = 'g'
	else if @countr > @countg
		set @dirWin = 'r'


	--if (DATEPART(MINUTE,(@hora)) in (0,15,30,45))
	--begin
		--print convert(varchar(1), @countg) + '' + convert(varchar(1), @countr) + '' + convert(varchar(1), @countd)
		if @dirWin = 'd'
			insert into estrategias values ('MHI_MAIOR', 5, @par, @data, @hora, 'skip', 0)
		else if @cor = @dirWin
			insert into estrategias values ('MHI_MAIOR', 5, @par, @data, @hora, 'win', 0)
		else
		begin
			select @cor = cor
			from velaM5
			where id = @i + 1 and par = @par

			if @cor = @dirWin
				insert into estrategias values ('MHI_MAIOR', 5, @par, @data, @hora, 'win', 1)
			else
			begin
				select @cor = cor
				from velaM5
				where id = @i + 2 and par = @par

				if @cor = @dirWin
					insert into estrategias values ('MHI_MAIOR', 5, @par, @data, @hora, 'win', 2)
				else
					insert into estrategias values ('MHI_MAIOR', 5, @par, @data, @hora, 'loss', 2)
			end

		--end

	end

	print @i

	set @i += 1
end

update velaM5
set bCatalogadoMHI = 1
GO
/****** Object:  StoredProcedure [dbo].[spCatalogar_5M_MHI_MENOR]    Script Date: 15/11/2020 23:07:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--SELECT * FROM velaM5

create proc [dbo].[spCatalogar_5M_MHI_MENOR]	
as

DELETE estrategias 
where tempo = 5 and estrategia = 'MHI_MENOR'

update velaM5
set bCatalogadoMHI = 0

declare @i int = (select min(id) from velaM5 where bCatalogadoMHI = 0)

while @i <= (select max(id) from velaM5 where bCatalogadoMHI = 0)
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


	--if (DATEPART(MINUTE,(@hora)) in (0,15,30,45))
	--begin
		--print convert(varchar(1), @countg) + '' + convert(varchar(1), @countr) + '' + convert(varchar(1), @countd)
		if @dirWin = 'd'
			insert into estrategias values ('MHI_MENOR', 5, @par, @data, @hora, 'skip', 0)
		else if @cor = @dirWin
			insert into estrategias values ('MHI_MENOR', 5, @par, @data, @hora, 'win', 0)
		else
		begin
			select @cor = cor
			from velaM5
			where id = @i + 1 and par = @par

			if @cor = @dirWin
				insert into estrategias values ('MHI_MENOR', 5, @par, @data, @hora, 'win', 1)
			else
			begin
				select @cor = cor
				from velaM5
				where id = @i + 2 and par = @par

				if @cor = @dirWin
					insert into estrategias values ('MHI_MENOR', 5, @par, @data, @hora, 'win', 2)
				else
					insert into estrategias values ('MHI_MENOR', 5, @par, @data, @hora, 'loss', 2)
			end

		--end

	end

	print @i

	set @i += 1
end

update velaM5
set bCatalogadoMHI = 1
GO
/****** Object:  StoredProcedure [dbo].[spCatalogar_5M_TRES_VIZINHOS]    Script Date: 15/11/2020 23:07:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spCatalogar_5M_TRES_VIZINHOS]
AS

declare @i int = (select min(id) from velaM5 where bCatalogado3Vizinhos = 0 or bCatalogado3Vizinhos is null)

while @i <= (select max(id) from velaM5 where bCatalogado3Vizinhos = 0 or bCatalogado3Vizinhos is null)
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


	if (DATEPART(MINUTE, @hora) = 00 or DATEPART(MINUTE, @hora) = 30)
	begin
		declare @corWin char(1)
		declare @win int = 0

		select @win = 
			case when qui.id is not null then 0
			when sex.id is not null then 1
			when sete.id is not null then 2
		 else -1 end 

		from velaM5 qua 
		left join velaM5 qui on qua.par =  qui.par and qui.id = @i + 4 and qua.cor = qui.cor
		left join velaM5 sex on qua.par = sex.par and sex.id = @i + 5 and qua.cor = sex.cor
		left join velaM5 sete on qua.par = sete.par and sete.id = @i + 6 and qua.cor = sete.cor
		where qua.id = @i + 3 and qua.par = @par


		insert into estrategias (estrategia, tempo, par, data, hora, resultado, martinGale)
		select 'TRES_VIZINHOS', 5, @par, @data, @hora, 
			case 
				when @cor = 'd' then 'skip'
				when @win >= 0 then 'win'
			else 'loss' end,
			@win
				
	end

	print @i

	set @i += 1
end

update velaM5
set bCatalogado3Vizinhos = 0


GO
/****** Object:  StoredProcedure [dbo].[spSinais]    Script Date: 15/11/2020 23:07:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spSinais]
			@tempo int,
			@estrategia varchar(200)
AS

delete sinais 
where tempo = @tempo
and estrategia = @estrategia

set dateformat dmy

declare @meses int = 2


while @meses <= 11
begin
	declare @dtInicial datetime = dateadd(MONTH, @meses, '01/11/2019')


	declare @tb table (estrategia varchar(200), tempo int, par varchar(10), hora time, win0mg int, win1mg int, win2mg int, loss int, skip int, dias int, ultLoss datetime)

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

			insert into @tb values (@estrategia, @tempo, @par, @hora, @win0mg, @win1mg, @win2mg, @loss, @skip, @dias, @dtUltLoss)


			set @hora = dateadd(MINUTE, 5, @hora)
		end

		set @ip += 1
	end
	set nocount off

	print @dtInicial

	declare @minLoss int = 0
	select @minLoss = min(a.loss) from @tb a
	left join sinais b on a.par = b.par and a.hora = b.hora
	and a.tempo = @tempo
	and a.estrategia = @estrategia
	where b.par is null
	
	insert into sinais (estrategia, tempo ,par, hora, win0mg, win1mg, win2mg, loss, skip, dias, ultLoss, dtConsulta)
	select A.estrategia, A.tempo, a.par, a.hora, a.win0mg, a.win1mg, a.win2mg, a.loss, a.skip, a.dias, a.ultLoss, @dtInicial
	from @tb a
	left join sinais b on a.par = b.par and a.hora = b.hora 
	and b.tempo = a.tempo
	and b.estrategia = a.estrategia
	where a.loss = @minLoss and b.par is null	

	set @meses += 1
end



declare @tbs table (id int identity(1,1),
					par varchar(20),
					hora time,
					dtConsulta datetime)

insert into @tbs (par, hora)
select  par, hora from estrategias 
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
	from sinais 
	where par = @pars and hora = @horas and tempo = @tempo and estrategia = @estrategia

	delete sinais
	where par = @pars and hora = @horas and id > @idMIn and tempo = @tempo and estrategia = @estrategia

	set @i += 1
end

delete sinais where dias < 30


GO
