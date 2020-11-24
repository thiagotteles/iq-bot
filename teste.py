from bs4 import BeautifulSoup
import requests
import time, json
from datetime import datetime, timedelta
import pyodbc 
conn = pyodbc.connect('Driver={SQL Server};'
					  'Server=localhost\SQLEXPRESS;'
                      'Database=iqBot2;'
                      'Trusted_Connection=yes;')

par = 'GBPUSD'
cor = 'd'
cursor = conn.cursor()

cursor.execute('INSERT INTO [dbo].[velaM5] ([par] ,[abertura] ,[cor])   VALUES (\''+ par + '\',getdate(),\'' + cor +'\') ''')
# print('''
#                 INSERT INTO [dbo].[velaM5] ([par] ,[abertura] ,[cor]) 
#                 VALUES
#                 ('{par}',getdate(),'{cor}'),
#                 ('{par}',getdate(),'{cor}')
#                 ''')

cursor.execute('SELECT * FROM iqBot2.dbo.velaM5')
 
for row in cursor:
    print(row)


######### base de emails ###########

# import requests

# r = requests.get('https://firebasestorage.googleapis.com/v0/b/beauty9-4de2a.appspot.com/o/sinais.txt?alt=media&token=d15e93ee-833a-4e63-a203-9031a6098c32')

# print (r.json())
