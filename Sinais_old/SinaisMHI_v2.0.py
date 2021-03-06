'''
BOT MHI COM SINAIS

Linkedin: linkedin.com/in/thiagotteles
'''

from iqoptionapi.stable_api import IQ_Option
from datetime import datetime, timedelta
import time, json
import sys
from colorama import init, Fore, Back, Style

init(convert=True, autoreset=True)

#region defs

def stop(lucro, gain, loss):
	if lucro >= float(abs(gain)):
		print('Stop Gain Batido!')
		sys.exit()

def Martingale(index, gale1, gale2):
	if index == 0:
		return gale1
	if index == 1:
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

#endregion defs

print(Fore.BLUE +  ''' 
------------------------------------------------------------------------
	     Sinais MHI 5M Automatico V2
	  linkedin.com/in/thiagotteles
 ------------------------------------------------------------------------
''')

email = "thiagojames_@hotmail.com" #input(' Qual seu email: ')
senha = "D0natell@20" #input(' Qual sua senha: ')
balance = input(' Quer operar aonde (REAL | PRACTICE): ').upper()

API = IQ_Option(email, senha)
API.connect()

if API.check_connect():
	print(' \n Conectado com sucesso!')
else:
	print(' \n Erro ao conectar')
	input('\n\n Aperte enter para sair')
	sys.exit()

API.change_balance(balance) # PRACTICE / REAL

# valor_entrada = float(input(' Indique um valor para entrar: '))
# valor_entrada_b = float(valor_entrada)
qtdLoss = float(input(' Quantos loss voce pode ter: '))
stop_gain = float(input(' Indique o valor de Stop Gain: '))
min_payout = float(input(' Indique a porcentagem minima do payout (%): '))
lucro = 0

horaVerificacao = datetime.now()
while True:
	# print('Primeiro While',datetime.now())
	if datetime.now().second == 0 and horaVerificacao.minute != datetime.now().minute:
		print (Fore.MAGENTA + 'Verificando...  ' + datetime.now().strftime("%m/%d/%Y, %H:%M:%S"), end="", flush=True)
		print("\r", end="", flush=True)
		with open('sinais.txt') as json_file:
			dados = json.load(json_file)

			for op in dados:
				min = int(op['horario'].split(':')[1])
				hor = int(op['horario'].split(':')[0])
				tempo = int(op['tempo'])
				valor_entrada_b = float(op['valor'])
				gale1 = float(op['gale1'])
				gale2 = float(op['gale2'])
				estrategia = op['estrategia']
				qtdEntradas = 1
				if gale2 > 0:
					qtdEntradas = 3
				elif gale1 > 0:
					qtdEntradas = 2

				dtSinal = datetime(1900, 1, 1, hor, min)
				dtSinal = dtSinal - timedelta(minutes=1)
				
				if dtSinal.hour == datetime.now().hour and dtSinal.minute == datetime.now().minute: 
					par = op['par']
					payoutVerificado = False
					payout = 0
					print('\n' + par, ' na fila')
					while dtSinal.hour == datetime.now().hour and dtSinal.minute == datetime.now().minute:
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
							buscarVelas = 0
							
							if estrategia.upper() == "MHI_MENOR" or estrategia.upper() == "MHI_MAIOR":
								buscarVelas = 3
								print('Analisando as cores', par, datetime.now())
								velas = API.get_candles(par, tempo * 60, buscarVelas, time.time())
								velas[0] = 'g' if velas[0]['open'] < velas[0]['close'] else 'r' if velas[0]['open'] > velas[0]['close'] else 'd'
								velas[1] = 'g' if velas[1]['open'] < velas[1]['close'] else 'r' if velas[1]['open'] > velas[1]['close'] else 'd'
								velas[2] = 'g' if velas[2]['open'] < velas[2]['close'] else 'r' if velas[2]['open'] > velas[2]['close'] else 'd'
								
								cores = velas[0] + ' ' + velas[1] + ' ' + velas[2]		
								print(cores)

								if cores.count('g') > cores.count('r') and cores.count('d') == 0 : dir = ('put') if estrategia.upper() == "MHI_MENOR" else ('call')
								if cores.count('r') > cores.count('g') and cores.count('d') == 0 : dir = ('call') if estrategia.upper() == "MHI_MENOR" else ('put')
								
								if dir != 'call' and dir != 'put':
									print('dogi, nao entrar')
							
							if estrategia.upper() == "CALL" or estrategia.upper() == "PUT":
								dir = estrategia.lower()

							if dir:
								print('Dire????o:',dir)
								valor_entrada = valor_entrada_b
								
								for i in range(qtdEntradas):
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
												
												print('Resultado opera????o: ', end='')
												# print('WIN /' if valor > 0 else 'LOSS /' , round(valor, 2) ,'/', round(lucro, 2),('/ '+str(i)+ ' GALE' if i > 0 else '' ))
												
												if valor > 0:
													print(Back.GREEN + 'WIN ', round(valor, 2) ,'/', round(lucro, 2),('/ '+str(i)+ ' GALE \n' if i > 0 else ' \n' ))
												else:
													print(Back.RED +'LOSS', round(valor, 2) ,'/', round(lucro, 2),('/ '+str(i)+ ' GALE \n' if i > 0 else '\n' ))
													valor_entrada = Martingale(i, gale1, gale2)
													if valor < 0 and i + 1 == qtdEntradas:
														qtdLoss -= 1

													if qtdLoss == 0:
														print(Back.RED + 'Quantidade de loss batida')
														sys.exit()

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