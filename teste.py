from bs4 import BeautifulSoup
import requests
import time, json
from datetime import datetime, timedelta
import pyodbc 
conn = pyodbc.connect('Driver={SQL Server};'
					  'Server=localhost\SQLEXPRESS;'
                      'Database=iqBot2;'
                      'Trusted_Connection=yes;')


noticias = []
def CarregarNoticias():

	headers = requests.utils.default_headers()
	headers.update({'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:79.0) Gecko/20100101 Firefox/79.0'})

	data = requests.get('https://firebasestorage.googleapis.com/v0/b/beauty9-4de2a.appspot.com/o/noticia.html?alt=media&token=9e372601-88f0-4d40-bd4f-2a92e48830ec', headers=headers)
	print(data)
	if data.status_code == requests.codes.ok:
		info = BeautifulSoup(data.text, 'html.parser')
		
		blocos = ((info.find('table', {'id': 'economicCalendarData'})).find('tbody')).findAll('tr', {'class': 'js-event-item'})
		
		for blocos2 in blocos:
			impacto = str((blocos2.find('td', {'class': 'sentiment'})).get('data-img_key')).replace('bull', '')
			horario = str(blocos2.get('data-event-datetime')).replace('/', '-')
			moeda = (blocos2.find('td', {'class': 'left flagCur noWrap'})).text.strip()
			evento = (blocos2.find('td', {'class': 'left event'})).text.strip()
			noticias.append({'par': moeda, 'horario': horario, 'impacto': impacto})
			cursor = conn.cursor()
			print('INSERT INTO [dbo].[noticias] ([moeda] ,[evento] ,[horario], [impacto])  VALUES (\''+ moeda + '\',\''+ evento + '\',\'' + horario +'\',\'' + impacto + '\' ) ''')
			cursor.execute('INSERT INTO [dbo].[noticias] ([moeda] ,[evento] ,[horario], [impacto])  VALUES (\''+ moeda + '\',\''+ evento.replace("'"," ") + '\',\'' + horario +'\',\'' + impacto + '\' ) ''')
			conn.commit()

		# print(noticias)

CarregarNoticias()
# conn = pyodbc.connect('Driver={SQL Server};'
# 					  'Server=localhost\SQLEXPRESS;'
#                       'Database=iqBot2;'
#                       'Trusted_Connection=yes;')

# par = 'GBPUSD'
# cor = 'd'
# cursor = conn.cursor()

# cursor.execute('INSERT INTO [dbo].[velaM5] ([par] ,[abertura] ,[cor])   VALUES (\''+ par + '\',getdate(),\'' + cor +'\') ''')
# print('''
#                 INSERT INTO [dbo].[velaM5] ([par] ,[abertura] ,[cor]) 
#                 VALUES
#                 ('{par}',getdate(),'{cor}'),
#                 ('{par}',getdate(),'{cor}')
#                 ''')

# cursor.execute('SELECT * FROM iqBot2.dbo.velaM5')
 
# for row in cursor:
#     print(row)


######### base de emails ###########

# import requests

# r = requests.get('https://firebasestorage.googleapis.com/v0/b/beauty9-4de2a.appspot.com/o/sinais.txt?alt=media&token=d15e93ee-833a-4e63-a203-9031a6098c32')

# print (r.json())
