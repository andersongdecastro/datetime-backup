# Timer do systemd

## 1\. Permissão de execução ao script

```bash
chmod +x arquivo.sh
```

A primeira linha do `arquivo.sh` deve ser:

```bash
#!/usr/bin/env bash
```

Ou pode ser mais específico da maneira abaixo. É mais recomendado no ecossistema Ubuntu:

```bash
#!/bin/bash
```

## 2\. Criar o serviço

```bash
sudo nano /etc/systemd/system/arquivo.service
```

Colocar o conteúdo abaixo:

```ini
[Unit]
Description=Executa o script arquivo.sh

[Service]
Type=oneshot
User=andersoncastro
ExecStart=/home/andersoncastro/scripts/arquivo.sh
```

## 3\. Criar o timer

```bash
sudo nano /etc/systemd/system/arquivo.timer
```

Colocar o conteúdo abaixo:

```ini
[Unit]
Description=Executa arquivo.sh diariamente às 04:00

[Timer]
OnCalendar=*-*-* 04:00:00
Persistent=true
Unit=arquivo.service

[Install]
WantedBy=timers.target
```

## 4\. Recarregar o systemd

```bash
sudo systemctl daemon-reload
```

## 5\. Ativar e iniciar o timer

```bash
sudo systemctl enable --now arquivo.timer
```

## 6\. Verificar o timer

```
systemctl status arquivo.timer
```

Para listar todos os timers e conferir a próxima execução:

```
systemctl list-timers --all
```

Você deverá encontrar uma linha referente a:

```
arquivo.timer
```

## 7\. Testar o serviço manualmente

Antes de esperar até as 04:00, testar:

```
sudo systemctl start arquivo.service
```

Depois ver o resultado:

```
systemctl status arquivo.service
```

Um serviço com:

```
Type=oneshot
```

executa uma tarefa e termina. Por isso, depois de uma execução bem-sucedida, o estado pode aparecer como:

```
inactive (dead)
```

Isso é normal para esse tipo de serviço.

## 8\. Consultar os registros

Para consultar os registros da última execução:

```
journalctl -u arquivo.service
```

Para ver somente os registros do boot atual:

```
journalctl -u arquivo.service -b
```

Para acompanhar em tempo real:

```
journalctl -u arquivo.service -f
```

## Evitar execução simultânea

O systemd normalmente não inicia uma segunda instância do mesmo serviço enquanto ele já estiver ativo. Portanto, se o script ainda estiver executando, o timer não deverá criar várias instâncias paralelas do mesmo serviço.

## Depois de editar um `.service` ou `.timer`, recarregar as unidades

```
sudo systemctl daemon-reload
```

Para verificar se os arquivos possuem erros:

```
systemd-analyze verify /etc/systemd/system/arquivo.service
systemd-analyze verify /etc/systemd/system/arquivo.timer
```

## Estrutura final

Será:

```
/home/andersoncastro/scripts/arquivo.sh
/etc/systemd/system/arquivo.service
/etc/systemd/system/arquivo.timer
```

E os comandos principais serão:

```
sudo systemctl daemon-reload
sudo systemctl enable --now arquivo.timer
systemctl list-timers --all
```

Para o comportamento de timer, **`systemd timer` com `Persistent=true` é a opção recomendada**.