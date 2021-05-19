![LOKI-AP](https://raw.githubusercontent.com/lokisuite/images/main/logo.png)

# Loki-Ap é uma solução simples para captura de credenciais e ataques MITM em WPA e WEP

Loki-ap é uma ferramenta da suiteloki voltada para pesquisa em engenharia social. Ela tem a capacidade de criar um rogue ap com um fake captive portal preparado para salvar em disco as credenciais digitadas. Também pode criar um Evil Twin linkado a uma rede real, que permite que as vítimas possam ter acesso à internet, enquanto salva o monitoramento do acesso.

Loki-ap pode criar pontos de acesso com WEP sem credencial e WPA e WPA2 com credencial. Possui atualmente 2 tipos de captive portal que podem ser utilizados em infinitas possibilidades.


## Instalação

**Faça o download da ultima versão**
```
git clone https://github.com/lokisuite/loki-ap.git
```
**Mude para o diretorio do loki-ap**
```
cd loki-ap
```
**Dê permissão de execussão**
```
chmod +x Loki-ap.sh
```
**Rode o help do Loki-ap**
```
./Loki-ap.sh -h
```
**Para instalar as dependências**
```
./Loki-ap.sh -d
```



## Modos de uso básico

O Loki-ap permite combinações de tecnicas para melhor utilizar de acordo com a necessidade.


### Rogue AP WEP sem segurança

O uso mais básico permite criar um rogue AP sem credenciais que pode carregar um captive portal que savlva credenciais digitadas. Este tipo de ataque pode ser feito para capturar credenciais de senhas de conexão, de rede social ou de algum portal personalizado que o atacante saiba que avitima utiliza. Através de um AP com internet gratis.
```
./Loki-ap -k -i <interface> -c <canal> -e <"nome do AP"> -w <tipo de segunraça> -p <codigo do captive portal>
```
Onde:

| Argumento | Resultado |
|-------|------------|
| -k | mata processos conflitantes (recomendado)|
| -i | define qual interface será utilizada para criar um AP |(wlan0, wlan1...)
| -c | define o canal em que o AP será criado (1, 2, 3...)|
| -e | nome parra o AP ("Internet Gratis")|
| -w | tipo de segunraca (1 - WEP, 2 - WPA, 3 - WPA+WPA2)|
| -p | codigo do captive portal (1 - Update de firmware, 2 - Login com rede social)|



#### Imagens do portal WEP em utilização e credenciais capturadas do lado do atacante


```
./Loki-ap.sh -k -i wlan0 -c 6 -e "Loki WiFi" -w 1 -p 2
```

![WEP](https://raw.githubusercontent.com/lokisuite/images/main/print1.png)



#### Do lado da vítima (smartphone)


![WEP](https://raw.githubusercontent.com/lokisuite/images/main/print2.jpeg) 

![WEP](https://raw.githubusercontent.com/lokisuite/images/main/print3.jpeg) 



### Rogue AP ou Evil Twin com segurança WPA2 para ataques MITM

O uso demonstrado abaixo pode criar um Rogue AP ou Evil Twin que utiliza senha criptografaca para autenticação. O uso desta tecnica pode ser feito tanto para capturar uma credencial utilizando um captive portal, quanto para dar acesso real à vitima e iniciar uma captura de dados que pode ser lido posteriormente com softwares como Wireshark ou tcpdump.
Recomenda-se utilizar o Evil Twin caso saiba a senha da conexão real que será clonada, pois ao enviar pacotes de desautenticação para o AP real utilizando outra ferramenta, a vítima automaticamente se conectará ao Evil Twin sem a necessidade de se autenticar, genrando um acesso real à internet, porém monitorado.

```
./Loki-ap -k -i <interface> -c <canal> -e <"nome do AP"> -w <tipo de segunraça> -P <senha> -s <interface>
```

Onde:

| Argumento | Resultado |
|-------|------------|
| -k | mata processos conflitantes (recomendado)|
| -i | define qual interface será utilizada para criar um AP |(wlan0, wlan1...)
| -c | define o canal em que o AP será criado (1, 2, 3...)|
| -e | nome parra o AP ("Internet Gratis")|
| -w | tipo de segunraca (1 - WEP, 2 - WPA, 3 - WPA+WPA2)|
| -P | senha de acesso para autenticacao (minimo de 8 caracteres)|
| -s | indica que um ataque MITM fois escolhido e exige a interface com conexão à internet que será a ponte para gerar o MITM (recomenda-se interface cabeada)|



#### Imagens AP WAP em utilização e MITM em curso

```
./Loki-ap.sh -k -i wlan0 -c 11 -e Loki_WPA -w 2 -P 12345678 -s eth0
```

![WAP](https://raw.githubusercontent.com/lokisuite/images/main/print4.jpeg)



#### Do lado da vítima (smartphone)

![WAP](https://raw.githubusercontent.com/lokisuite/images/main/print5.jpeg)

![WAP](https://raw.githubusercontent.com/lokisuite/images/main/print6.jpeg)

![WAP](https://raw.githubusercontent.com/lokisuite/images/main/print7.jpeg)


Enquanto a vítima estiver conectada,ou até quando o portal ainda estiver ativo pelo atacante, um arquivo de monitoramento será salvo em um diretório apontado pelo Loki-ap. Este arquivo pode ser lido com o uso de ferramentas como Wireshark ou tcpdump.

![WAP](https://raw.githubusercontent.com/lokisuite/images/main/print8.png)


## Opções default

Algumas das configurações de conexão são inseridas de forma default, porém podem ser mudadas manualmente, tais como:

| Argumentos | Resultado | Opção default |
|------------|-----------|---------------|
| -g | altera o gateway | default 192.168.2.1 |
| -r | range de IPs |default 192.168.2.2,192.168.2.300 |
| -n | netmask | default 255.255.255.0 |
| -b | IP do host | default 192.168.2.0|
| -c | canal | default 11 |
| -e | essid | default Loki_WiFi |


## :heavy_exclamation_mark: Requisitos

- um sistema operacional baseado em Linux. Recomendamos Kali Linux 2021.1
- uma placa externa wifi com capacidade para modo monitor e modo AP


