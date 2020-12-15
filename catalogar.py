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

def Tendencia(velas, i, count):
    if i <= count:
        return ''
    
    ultimo = round(velas[i - count]['close'], 4)
    primeiro = round(velas[i - 1]['close'], 4)
    
    diferenca = abs( round( ( (ultimo - primeiro) / primeiro ) * 100, 5) )
    return "g" if ultimo < primeiro and diferenca > 0.01 else "r" if ultimo > primeiro and diferenca > 0.01 else ''

while True:
	if API.check_connect() == False:
		print('Erro ao se conectar')
		API.connect()
	else:
		print('Conectado com sucesso')
		break
	
	time.sleep(1)

pares = ['EURUSD', 'EURCAD', 'AUDUSD', 'USDCAD', 'EURGBP', 'GBPUSD', 'GBPJPY', 'GBPAUD', 'AUDCAD']
# pares = ['EURUSD']
# with open('PARES_M15.sql', 'w') as f:
for par in pares:

    total = []
    tempo = time.time()

    for i in range(100):
        X = API.get_candles(par, 300, 1000, tempo)
        total = X+total
        tempo = int(X[0]['from'])-1
    
        # print(str(datetime.fromtimestamp(X[-36]['from'])), Tendencia(X, 7, 36))
        # print(str(datetime.fromtimestamp(X[-6]['from'])), Tendencia(X, 7, 6))

    iV = 0
    for velas in total:
        cor = 'g' if velas['open'] < velas['close'] else 'r' if velas['open'] > velas['close'] else 'd'
        # print('(\''+ par + '\',\''+ str(datetime.fromtimestamp(velas['from'])) + '\',\'' + cor +'\',\'' + str(velas['close']) +'\') ''')
        iV = iV + 1
        try:
            cursor = conn.cursor()
            # cursor.execute('INSERT INTO [dbo].[velaM5] ([par] ,[abertura] ,[cor],[fechamento],macroTendencia,microTendencia )  VALUES (\''+ par + '\',\''+ str(datetime.fromtimestamp(velas['from'])) + '\',\'' + cor +'\',\'' + str(round(velas['close'], 4)) +'\',\'' + Tendencia(velas, iV, 36) +'\',\'' + Tendencia(velas, iV, 6) +'\') ''')
            cursor.execute('INSERT INTO [dbo].[velaM5] ([par] ,[abertura] ,[cor],[fechamento],macroTendencia,microTendencia )  VALUES (\''+ par + '\',\''+ str(datetime.fromtimestamp(velas['from'])) + '\',\'' + cor +'\',\'' + str(round(velas['close'], 5)) +'\',\'' + Tendencia(total, iV, 36) +'\',\'' + Tendencia(total, iV, 6) +'\') ''')
            conn.commit()
        except:
            a = 1

for par in pares:
    total = []
    tempo = time.time()
    
    for j in range(100):
        Z = API.get_candles(par, 900, 300, tempo)
        total = Z+total
        tempo = int(Z[0]['from'])-1
        
    iV = 0
    for velas in total:
        cor = 'g' if velas['open'] < velas['close'] else 'r' if velas['open'] > velas['close'] else 'd'
        iV = iV + 1
        try:
            cursor = conn.cursor()
            cursor.execute('INSERT INTO [dbo].[velaM15] ([par] ,[abertura] ,[cor],[fechamento],macroTendencia,microTendencia )  VALUES (\''+ par + '\',\''+ str(datetime.fromtimestamp(velas['from'])) + '\',\'' + cor +'\',\'' + str(round(velas['close'], 5)) +'\',\'' + Tendencia(total, iV, 36) +'\',\'' + Tendencia(total, iV, 6) +'\') ''')  
            # cursor.execute('INSERT INTO [dbo].[velaM15] ([par] ,[abertura] ,[cor]) VALUES (\''+ par + '\',\''+ str(datetime.fromtimestamp(velas['from'])) + '\',\'' + cor +'\') ''')
            conn.commit()
        except:
            a = 1