#!/bin/bash

loki_ajuda(){
 echo  " LOKI-AP 1.0			Manual					 LOKI-AP 1.0



  NOME
	Loki-ap -  e uma ferramenta  de seguranca e pesquisa voltada para engenharia social.

  MODO DE USO
	 Deve rodar no modo root
	 Modo de uso basico: ./Fenrir-ap.sh  [-k] [-i interface] [-c canal] [-e essid] [-p portal]
  	 Exemplo: ./Fenrir-ap.sh -k -i wlan0 -c 11 -e FreeWifi -p 1

  OPCOES
         -h      		exibe este manual.
	 -d			verifica se todas as dependencias estao instaladas, caso não,
				instala automaticamente.
  	 -k	 		mata processos conflitantes (recomendado).
         -i <interface>		interface a ser utilizada.
	 -c <numero do canal>	canal para iniciar o AP, default 11.
         -e <nome do AP>	ESSID do AP, default FreeWifi
	 -p <opcao> 		carrega o captive portal para ataques de engenharia social. 
				Opções:
		 			1 - TPLink Firmware Update.
					2 - Login com midias sociais.
         -b <ip do host>	ip do host, default 192.168.2.0, seu uso torna obrigatorios
				-g, -n e -r
         -g <ip do gateway>	gateway a ser utilizado, default 192.168.2.1, seu uso torna
				obrigatorios -b, -n e -r.
  	 -n <netmask>		netmask a ser usado, default 255.255.255.0, seu uso torna
				obrigatorios  -b, -g e -r.
	 -r <range de ip>	range de IP a ser usado, default 192.168.2.2,192.168.2.30,
				seu uso  torna obrigatorios -b, -g e -n.
	 -w <opcao>		tipo de conexao, default WEP(open). Seu uso torna obrigatorio -P. 
				Utiliza criptografia CCMP (AES). Opcoes:
					1 - WEP Open (default).
					2 - WPA2.
					3 - WPA+WPA2.
	 -P <password>		Senha para conexao WPA2, minimo de 8 caracteres, uso obrigatorio 
				caso -w esteja sendo utilizado com opcoes 2 ou 3.
	 -s <interface>		ao utilizar esta opcao com uma interface conectada a internet, o
				Loki-ap realiza um ataque MITM e salva o trafego.


  AUTOR

	 Fenrir
"
}
