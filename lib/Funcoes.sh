#!/bin/bash

dependencias(){
	clear
        local dep=()
        echo -ne "${verde}\n\n"

        local banner=()

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

        centralizado "${verde} Verificando dependencias...\n\n"
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
                centralizado "${azulbold}Instalando dependencias...\n"
                for lin in "${dep[@]}"
                do
                        centralizado "${verdebold}[+] ${normal} instalando $lin..."
                        apt install $lin -y
                        clear
                done
                echo -e "\n\n"
                centralizado "${azulbold}[+] Dependencias instaladas, execute normalmente.${normal}"
                exit
        else
                echo -e "\n\n"
        fi
        centralizado "${azulbold}[+] Todas as dependencias ja estao instaladas. Execute a aplicacao normalmente.\n\n${normal}"

}

