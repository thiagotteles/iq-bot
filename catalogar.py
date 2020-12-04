from iqoptionapi.stable_api import IQ_Option
import time, json
from datetime import datetime
import sys
import pyodbc 
conn = pyodbc.connect('Driver={SQL Server};'
					  'Server=localhost\SQLEXPRESS;'
                      'Database=iqBot2;'
                      'Trusted_Connection=yes;')

API = IQ_Option('thiagojames_@hotmail.com', 'D0natell@20')
API.connect()
API.change_balance('PRACTICE') # PRACTICE / REAL

while True:
	if API.check_connect() == False:
		print('Erro ao se conectar')
		API.connect()
	else:
		print('Conectado com sucesso')
		break
	
	time.sleep(1)

pares = ['EURUSD', 'EURJPY', 'USDJPY', 'GBPJPY','AUDUSD', 'EURGBP','GBPUSD','EURCAD']
# pares = ['EURUSD']
# with open('PARES_M15.sql', 'w') as f:
for par in pares:

    total = []
    tempo = time.time()

    for i in range(120):
        X = API.get_candles(par, 300, 1000, tempo)
        total = X+total
        tempo = int(X[0]['from'])-1

    for velas in total:
        cor = 'g' if velas['open'] < velas['close'] else 'r' if velas['open'] > velas['close'] else 'd'
        try:
            cursor = conn.cursor()
            cursor.execute('INSERT INTO [dbo].[velaM5] ([par] ,[abertura] ,[cor])  VALUES (\''+ par + '\',\''+ str(datetime.fromtimestamp(velas['from'])) + '\',\'' + cor +'\') ''')
            conn.commit()
        except:
            a = 1

for par in pares:
    total = []
    tempo = time.time()
    
    for j in range(120):
        Z = API.get_candles(par, 900, 300, tempo)
        total = Z+total
        tempo = int(Z[0]['from'])-1

    for velas in total:
        cor = 'g' if velas['open'] < velas['close'] else 'r' if velas['open'] > velas['close'] else 'd'
        try:
            cursor = conn.cursor()
            cursor.execute('INSERT INTO [dbo].[velaM15] ([par] ,[abertura] ,[cor]) VALUES (\''+ par + '\',\''+ str(datetime.fromtimestamp(velas['from'])) + '\',\'' + cor +'\') ''')
            conn.commit()
        except:
            a = 1