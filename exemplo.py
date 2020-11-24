from iqoptionapi.stable_api import IQ_Option
import time, json
from datetime import datetime

API = IQ_Option("thiagojames_@hotmail.com", "D0natell@20")
# API.max_reconnect(2)
API.change_balance('PRACTICE') # PRATICE / REAL

while True:
    if API.check_connect() == False:
        print("Erro ao se conectar")
        API.connect()
    else:
        print("Conectado")
        break 

    time.sleep(1)

def perfil():
    perfil = json.loads(json.dumps(API.get_profile()))    

    return perfil['result']

def banca():
    return API.get_balance()


def payout(par, tipo, timeframe = 1):
	if tipo == 'turbo':
		a = API.get_all_profit()
		return int(100 * a[par]['turbo'])
		
	elif tipo == 'digital':
	
		API.subscribe_strike_list(par, timeframe)
		while True:
			d = API.get_digital_current_profit(par, timeframe)
			if d != False:
				d = int(d)
				break
			time.sleep(1)
		API.unsubscribe_strike_list(par, timeframe)
		return d

par = API.get_all_open_time()

for paridade in par['turbo']:
	if par['turbo'][paridade]['open'] == True:
		print('[ TURBO ]: '+paridade+' | Payout: '+str(payout(paridade, 'turbo')))
		
print('\n')

for paridade in par['digital']:
	if par['digital'][paridade]['open'] == True:
		print('[ DIGITAL ]: '+paridade+' | Payout: '+str( payout(paridade, 'digital') ))




















## Pegar até 1000 velas #########################
# par = 'EURUSD'

# vela = API.get_candles(par, 60, 10, time.time())

# for velas in vela:
# 	print('Hora inicio: '+str(datetime.fromtimestamp(velas['from']))+' abertura: '+str(velas['open']))


## Pegar mais de 1000 velas #########################
# par = 'EURUSD'

# total = []
# tempo = time.time()

# for i in range(2):
# 	X = API.get_candles(par, 60, 1000, tempo)
# 	total = X+total
# 	tempo = int(X[0]['from'])-1

# for velas in total:
# 	print(datetime.fromtimestamp(velas['from']))
	
	
## Pegar velas em tempo real #########################
# par = 'EURUSD'

# API.start_candles_stream(par, 60, 1)
# time.sleep(1)



# while True:
# 	vela = API.get_realtime_candles(par, 60)
# 	for velas in vela:
# 		print(vela[velas]['close'])
# 	time.sleep(1)
# API.stop_candles_stream(par, 60)


## Para pegar de apenas uma paridade #################
# par = 'USDCHF-OTC'

# API.start_mood_stream(par)

# while True:
# 	x = API.get_traders_mood(par)
# 	print(int(100 * round(x, 2)))
	
# 	time.sleep(1)
	
# API.stop_mood_stream(par)


## Para pegar de multiplas paridades #################
# id = dict([(l, u) for u,l in API.get_all_ACTIVES_OPCODE().items()])

# API.start_mood_stream('USDCHF-OTC')
# API.start_mood_stream('GBPUSD-OTC')

# while True:
# 	x = API.get_all_traders_mood()
	
# 	for i in x:
# 		print(id[i]+': '+str(int(100 * round(x[i], 2))), end=' ')
		
# 	print('\n')
	
# 	time.sleep(1)
	
# API.stop_mood_stream('USDCHF-OTC')
# API.stop_mood_stream('GBPUSD-OTC')

# print(vela)
# print(datetime.fromtimestamp(vela[0]['from']))

# x = perfil()
 
# print(datetime.fromtimestamp(x["created"]))
# print(x["name"])
# print(x["email"])
# print(banca())
