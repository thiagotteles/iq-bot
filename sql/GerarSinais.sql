
exec spCatalogar_5M_MHI_MENOR
exec spCatalogar_5M_MHI_MAIOR
exec spCatalogar_15M_MHI_MENOR
exec spCatalogar_15M_MHI_MAIOR
EXEC spCatalogar_5M_TRES_VIZINHOS
EXEC spCatalogar_5M_MINORIA_ULTIMAS_5
EXEC spCatalogar_5M_MAIORIA_ULTIMAS_5
 
delete a
from estrategias a
inner join noticias on 
		   a.par like '%' + moeda + '%'
	   and CAST(data AS DATETIME) + CAST(hora AS DATETIME) between DATEADD(MINUTE, -30, horario) and  DATEADD(MINUTE, 30, horario)
	   and impacto > 0

	   

exec spSinais 5, 'MINORIA_ULTIMAS_3'
exec spSinais 5, 'MAIORIA_ULTIMAS_3'
exec spSinais 5, 'MINORIA_ULTIMAS_5'
exec spSinais 5, 'MAIORIA_ULTIMAS_5'
exec spSinais 15, 'MINORIA_ULTIMAS_3'
exec spSinais 15, 'MAIORIA_ULTIMAS_3'

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






select * from estrategias


