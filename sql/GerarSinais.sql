
exec spCatalogar_5M_MHI_MENOR
exec spCatalogar_15M_MHI_MENOR
EXEC spCatalogar_5M_MINORIA_ULTIMAS_5

exec spCatalogar_5M_CALL
exec spCatalogar_5M_PUT
exec spCatalogar_15M_CALL
exec spCatalogar_15M_PUT


exec spCatalogar_5M_MHI_MAIOR
exec spCatalogar_15M_MHI_MAIOR
EXEC spCatalogar_5M_TRES_VIZINHOS
EXEC spCatalogar_5M_MAIORIA_ULTIMAS_5
 
update a
set impactoNoticia = n.impacto
from estrategias a
inner join (select moeda, horario, max(impacto) as impacto from noticias group by moeda, horario) as n on 
		   a.par like '%' + moeda + '%'
	   and CAST(data AS DATETIME) + CAST(hora AS DATETIME) between DATEADD(MINUTE, -30, horario) and  DATEADD(MINUTE, 30, horario)
	   and impacto > 0
where estrategia IN ('CALL', 'PUT')


exec spSinais 5, 'MINORIA_ULTIMAS_3'
exec spSinais 5, 'CALL'
exec spSinais 5, 'put'
exec spSinais 5, 'MINORIA_ULTIMAS_5'
exec spSinais 5, 'MAIORIA_ULTIMAS_5'
exec spSinais 15, 'MINORIA_ULTIMAS_3'
exec spSinais 15, 'CALL'
exec spSinais 15, 'PUT'

SELECT * FROM sinais
--order by hora
order by dias - loss desc

declare @valor varchar(10) = 2
declare @gale1 varchar(10) = 44
declare @gale2 varchar(10) = 97



select
estrategia,  tempo, par, convert(varchar(5), hora), win0mg, win1mg, win2mg, skip, dias, dias-loss as dif, loss, convert(varchar(10), ultLoss, 103) as ultLoss
,convert(varchar(5), hora) + ';' + convert(varchar(3), par) + '/' + substring(par, 4,3) + ';' + 
estrategia + ';' + convert(varchar(10), tempo) as b2IQ,
 '{ "par": "' + par + '", "horario": "'+ convert(varchar(5), hora) +'", "tempo": "' + convert(varchar(10),tempo) +'"
 , "estrategia": "' + UPPER(estrategia) +  
	'", "valor": "0'+
	'", "gale1": "0'+
	'", "gale2": "0'+
	'"},' as roboThiago

from sinais 
where dias > 40
AND (hora < '17:30' or hora > '21:30')
order by hora

select distinct moeda, horario, impacto from noticias
order by horario desc






select * from estrategias


