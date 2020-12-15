'''
BOT MHI COM SINAIS

Linkedin: linkedin.com/in/thiagotteles
'''
from bs4 import BeautifulSoup
import requests
from iqoptionapi.stable_api import IQ_Option
from datetime import datetime, timedelta
import time, json
import sys
from colorama import init, Fore, Back, Style

init(convert=True, autoreset=True)

#region defs
def Tendencia(velas, i, count):
    if i <= count:
        return ''
    
    ultimo = round(velas[i - count]['close'], 4)
    primeiro = round(velas[i - 1]['close'], 4)
    
    diferenca = abs( round( ( (ultimo - primeiro) / primeiro ) * 100, 5) )
    return "call" if ultimo < primeiro and diferenca > 0.01 else "put" if ultimo > primeiro and diferenca > 0.01 else ''


def stop(lucro, gain, loss):
	if lucro >= float(abs(gain)):
		print('Stop Gain Batido!')
		time.sleep(86400) #sys.exit()

def Martingale(index, gale1, gale2):
	if index == 0 and tipo_mhi == 1:
		return gale1
	elif index == 1 and tipo_mhi == 1:
		return gale2
	elif index == 0 and tipo_mhi == 2:
		return gale2

def Payout(par):
	try:
		API.subscribe_strike_list(par, 5)
		while True:
			d = API.get_digital_current_profit(par, 5)
			if d != False:
				d = round(int(d) / 100, 2)
				break
			time.sleep(1)
		API.unsubscribe_strike_list(par, 5)

		return d
	except:
		return 0

noticias = []
def CarregarNoticias():
	print(Fore.CYAN +' carregando noticias')
	headers = requests.utils.default_headers()
	headers.update({'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:79.0) Gecko/20100101 Firefox/79.0'})

	data = requests.get('http://br.investing.com/economic-calendar/', headers=headers)

	if data.status_code == requests.codes.ok:
		info = BeautifulSoup(data.text, 'html.parser')
		
		blocos = ((info.find('table', {'id': 'economicCalendarData'})).find('tbody')).findAll('tr', {'class': 'js-event-item'})
		
		for blocos2 in blocos:
			impacto = str((blocos2.find('td', {'class': 'sentiment'})).get('data-img_key')).replace('bull', '')
			horario = str(blocos2.get('data-event-datetime')).replace('/', '-')
			moeda = (blocos2.find('td', {'class': 'left flagCur noWrap'})).text.strip()
			evento = (blocos2.find('td', {'class': 'left event'})).text.strip()
			noticias.append({'evento': evento, 'par': moeda, 'horario': horario, 'impacto': impacto})

def temNoticiaAgora(now, start, end):
	if start <= end:
		return start <= now < end
	else: # over midnight e.g., 23:30-04:15
		return start <= now or now < end
#endregion defs

print(Fore.MAGENTA +  ''' 
------------------------------------------------------------------------
	Sinais MHI Automatico v.5.0
	linkedin.com/in/thiagotteles
 ------------------------------------------------------------------------
''')

email = input(' Qual seu email: ')
senha = input(' Qual sua senha: ')
balance = input(' Quer operar aonde (REAL | PRACTICE): ').upper()

API = IQ_Option(email, senha)
API.connect()

if API.check_connect():
	print(' \n Conectado com sucesso!')
else:
	print(' \n Erro ao conectar')
	input('\n\n Aperte enter para sair')
	time.sleep(86400) #sys.exit()

API.change_balance(balance) # PRACTICE / REAL

qtdLoss = float(input(' Quantos loss voce pode ter: '))
stop_gain = float(input(' Indique o valor de Stop Gain: '))
min_payout = float(input(' Indique a porcentagem minima do payout (%): '))
qtdSoros_b = float(input(' Nivel de SOROS: '))
qtdSoros = qtdSoros_b
valorSoros = 0
lucro = 0

while True:
	try:
		tipo_mhi = int(input(' Quer entrar em qual vela?\n  1 - Primeira (2 MG)\n  2 - Segunda (1 MG)\n  3 - Terceira(Sem MG)\n :: '))	
		if tipo_mhi > 0 and tipo_mhi < 4 : break
	except:
		print('\n Opção invalida')

while True:
	try:
		filtroTendencia = int(input(' Filtrar tendencia?\n  1 - Sim\n  0 - Nao\n :: '))
		if filtroTendencia >= 0 and filtroTendencia < 2 : break
	except:
		print('\n Opção invalida')

while True:
	try:
		filtroNoticia = int(input(' Filtrar noticias?\n  1 - Sim\n  0 - Nao\n :: '))
		if filtroNoticia >= 0 and filtroNoticia < 2 : break
	except:
		print('\n Opção invalida')

noticias = []
CarregarNoticias()
horaVerificacao = datetime.now()
while True:
	# print('Primeiro While',datetime.now())
	if datetime.now().second == 0 and horaVerificacao.minute != datetime.now().minute:
		
		#carregando as noticias do dia
		if (datetime.now().hour == 0 and datetime.now().minute == 1):
			noticias = []
			CarregarNoticias()
		
		print (Fore.BLUE + 'Verificando...  ' + datetime.now().strftime("%m/%d/%Y, %H:%M:%S"), end="", flush=True)
		print("\r", end="", flush=True)
		with open('sinais5.0.txt') as json_file:
			dados = json.load(json_file)

			for op in dados:
				min = int(op['horario'].split(':')[1])
				hor = int(op['horario'].split(':')[0])
				tempo = int(op['tempo'])
				dtSinal = datetime(datetime.now().year, datetime.now().month, datetime.now().day, hor, min)
				dtConsultaSinal = dtSinal
				if tipo_mhi == 1:
					dtSinal = dtSinal - timedelta(minutes=1)
				if tipo_mhi == 2:
					dtSinal = dtSinal + timedelta(minutes= 4 if tempo == 5 else 14)
				if tipo_mhi == 3:
					dtSinal = dtSinal + timedelta(minutes= 9 if tempo == 5 else 29)
				
				if dtSinal.hour == datetime.now().hour and dtSinal.minute == datetime.now().minute: 
					par = op['par']
					valor_entrada_b = float(op['valor'])
					gale1 = float(op['gale1'])
					gale2 = float(op['gale2'])
					estrategia = op['estrategia']
					velasAdd = 2 if estrategia.find('5') > -1 else 0

					if tipo_mhi == 3:
						valor_entrada_b = gale2 + valorSoros if valorSoros > 0 else gale2
					elif tipo_mhi == 2:
						valor_entrada_b = gale1 + (0.32 * valorSoros) if valorSoros > 0 else gale1
						gale2 = gale2 + (0.68 * valorSoros) if valorSoros > 0 else gale2
					elif tipo_mhi == 1:
						valor_entrada_b = valor_entrada_b + (0.13 * valorSoros) if valorSoros > 0 else valor_entrada_b
						gale1 = gale1 + (0.28 * valorSoros) if valorSoros > 0 else gale1
						gale2 = gale2 + (0.59 * valorSoros) if valorSoros > 0 else gale2

					tendenciaVerificada = False
					noticiaVerificada = False
					temNoticia = False
					payoutVerificado = False
					payout = 0
					MacroTendencia = 'x'
					MicroTendencia = 'x'
					print('\n' + par, ' na fila')
					while dtSinal.hour == datetime.now().hour and dtSinal.minute == datetime.now().minute:
						if noticiaVerificada == False and filtroNoticia == 1:
							for noticia in noticias:
								dt = datetime.strptime(noticia['horario'], '%Y-%m-%d %H:%M:%S')
								if temNoticiaAgora(dtConsultaSinal, dt - timedelta(minutes=30), dt + timedelta(minutes=30)) and par.find(noticia['par']) > -1 and int(noticia['impacto']) > 0:
									noticiaVerificada = True
									print(Fore.YELLOW + noticia['evento'], noticia['par'],' HORARIO: ', noticia['horario'], ' IMPACTO: ', noticia['impacto'], '\n')
									temNoticia = True
								else:
									noticiaVerificada = True

						if temNoticia:
							time.sleep(0.5)
							break

						if tendenciaVerificada == False and filtroTendencia == 1:
							velasTendencia = API.get_candles(par, (int(tempo) * 60), 37,  time.time())
							MacroTendencia = Tendencia(velasTendencia, 36, 36)								
							MicroTendencia = Tendencia(velasTendencia, 36, 6)	
						
						if payoutVerificado == False:
							payout = Payout(par)
							print('payout:', payout * 100)
							if payout >= (min_payout / 100):
								payoutVerificado = True
							else:
								payoutVerificado = True
								print(Fore.YELLOW + 'Payout muito baixo')
								break

						
						if datetime.now().second > 58.5:


							entradaPermitida = False
							print('Analisando as cores', par, datetime.now())
							
							velas = API.get_candles(par, tempo * 60, 2 + tipo_mhi + velasAdd, time.time())
							velas[0] = 'g' if velas[0]['open'] < velas[0]['close'] else 'r' if velas[0]['open'] > velas[0]['close'] else 'd'
							velas[1] = 'g' if velas[1]['open'] < velas[1]['close'] else 'r' if velas[1]['open'] > velas[1]['close'] else 'd'
							velas[2] = 'g' if velas[2]['open'] < velas[2]['close'] else 'r' if velas[2]['open'] > velas[2]['close'] else 'd'
							
							if velasAdd == 2:
								velas[3] = 'g' if velas[3]['open'] < velas[3]['close'] else 'r' if velas[3]['open'] > velas[3]['close'] else 'd'
								velas[4] = 'g' if velas[4]['open'] < velas[4]['close'] else 'r' if velas[4]['open'] > velas[4]['close'] else 'd'
							
							cores = velas[0] + ' ' + velas[1] + ' ' + velas[2] if velasAdd == 0 else velas[0] + ' ' + velas[1] + ' ' + velas[2] + ' ' + velas[3] + ' ' + velas[4] 	
							print(cores)

							if estrategia.upper().find('MINORIA') > -1:
								if cores.count('g') > cores.count('r') and cores.count('d') == 0 : dir = ('put')
								if cores.count('r') > cores.count('g') and cores.count('d') == 0 : dir = ('call')

							elif estrategia.upper().find('MAIORIA') > -1:
								if cores.count('g') > cores.count('r') and cores.count('d') == 0 : dir = ('call')
								if cores.count('r') > cores.count('g') and cores.count('d') == 0 : dir = ('put')

							elif estrategia.upper() == "CALL" or estrategia.upper() == "PUT":
								dir = estrategia.lower()
						
							if tipo_mhi == 1:
									entradaPermitida = True
							if tipo_mhi == 2:
								idx = 3
								if velasAdd == 2:
									idx = 5
								
								velas[idx] = 'call' if velas[idx]['open'] < velas[idx]['close'] else 'put' if velas[idx]['open'] > velas[idx]['close'] else 'put'
								
								if dir != velas[idx]:
									entradaPermitida = True
									print(Fore.GREEN + 'Permitido entrada no 1 Gale')
								else:
									entradaPermitida = False
									print(Fore.YELLOW + 'Nao entrou, deu win de primeira')
							if tipo_mhi == 3:
								idx = 3
								if velasAdd == 2:
									idx = 5

								velas[idx] = 'call' if velas[idx]['open'] < velas[idx]['close'] else 'put' if velas[idx]['open'] > velas[idx]['close'] else 'put'
								velas[idx + 1] = 'call' if velas[idx + 1]['open'] < velas[idx + 1]['close'] else 'put' if velas[idx + 1]['open'] > velas[idx + 1]['close'] else 'put'
								
								if dir != velas[idx] and dir != velas[idx + 1]:
									entradaPermitida = True
									print(Fore.GREEN +'Permitido entrada no 2 Gale')
								else:
									entradaPermitida = False
									print(Fore.YELLOW + 'Nao entrou, deu win antes')


							if dir != 'call' and dir != 'put':
								print('dogi, nao entrar')
								entradaPermitida = False


							if dir != MacroTendencia and dir != MicroTendencia and filtroTendencia == 1:
								print(Fore.YELLOW + 'contra tendencia, nao entrar')
								entradaPermitida = False

							if dir and entradaPermitida:
								print('Direção:',dir)
								valor_entrada = valor_entrada_b
								
								for i in range(4 - tipo_mhi):
									print("entrando:", par, " R$:", valor_entrada, dir, tempo,  datetime.now())
									status,id = API.buy_digital_spot(par, valor_entrada, dir, tempo) 
								
									if status:
										while True:
											try:
												status,valor = API.check_win_digital_v2(id) 
											except:
												status = True
												valor = 0
											
											if status:
												valor = valor if valor > 0 else float('-' + str(abs(valor_entrada)))
												lucro += round(valor, 2)
												
												print('Resultado operação: ', end='')
												# print('WIN /' if valor > 0 else 'LOSS /' , round(valor, 2) ,'/', round(lucro, 2),('/ '+str(i)+ ' GALE' if i > 0 else '' ))
												
												if valor > 0:
													print(Back.GREEN + 'WIN ', round(valor, 2) ,'/', round(lucro, 2),('/ '+str(i)+ ' GALE \n' if i > 0 else ' \n' ))
													if qtdSoros > 0 and lucro > 0:
														valorSoros += valor
														qtdSoros -= 1
													elif qtdSoros == 0:
														valorSoros = 0
														qtdSoros = qtdSoros_b
												
												else:
													print(Back.RED +'LOSS', round(valor, 2) ,'/', round(lucro, 2),('/ '+str(i)+ ' GALE \n' if i > 0 else '\n' ))
													valor_entrada = Martingale(i, gale1, gale2)
													if valor < 0 and i == 3 - tipo_mhi:
														qtdLoss -= 1
														valorSoros = 0
														qtdSoros = qtdSoros_b

													if qtdLoss == 0:
														print(Back.RED + 'Quantidade de loss batida')
														time.sleep(86400) #sys.exit()

												stop(lucro, stop_gain, 0)
												break
										if valor > 0 : break
									else:
										print('Erro ao realizar a operacao')
											
							else:
								break

							break
						time.sleep(0.2)


	time.sleep(0.5)