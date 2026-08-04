# datetime-backup

Backups automatizados via `tar --zstd` + `systemd timer`, com nome de arquivo baseado em data/hora e retenção automática dos backups mais recentes.

O repositório contém dois pares independentes de script + unidades systemd:

| Arquivo | Papel |
| --- | --- |
| `datetime-backup-v1-0.sh` | Script de backup de `/home/son` |
| `datetime-backup-v1-1.service` | Unidade systemd (oneshot) que executa o script v1 |
| `datetime-backup-v1-2.timer` | Timer que dispara o serviço v1 diariamente às 04:00 |
| `datetime-backup-v2-0.sh` | Script de backup de `/home/andersoncastro/pulse-backup` |
| `datetime-backup-v2-1.service` | Unidade systemd (oneshot) que executa o script v2 |
| `datetime-backup-v2-2.timer` | Timer que dispara o serviço v2 diariamente às 04:00 |

## Requisitos

- `bash`
- `tar` com suporte a Zstandard (pacote `zstd` instalado)
- `systemd` (para agendamento via `.service`/`.timer`)

## Configuração dos scripts

### v1 — `datetime-backup-v1-0.sh`

- **Origem:** `/home/son`
- **Destino:** `/mnt/d/OneDrive/backups/home_son`
- **Exclusões:** `go`, `snap`
- **Ocultos incluídos:** `.ssh`
- **Nome do arquivo:** `home_son_AAAA-MM-DD_HH-MM.tar.zst`
- **Retenção:** mantém apenas os **3** backups mais recentes

### v2 — `datetime-backup-v2-0.sh`

- **Origem:** `/home/andersoncastro/pulse-backup`
- **Destino:** `/home/andersoncastro/MEGA/backups/pulse-backup/Linux`
- **Exclusões:** nenhuma (backup completo, incluindo ocultos)
- **Nome do arquivo:** `pulse-backup_AAAA-MM-DD_HH-MM.tar.zst`
- **Retenção:** mantém apenas os **2** backups mais recentes

Para ajustar origem, destino, exclusões ou retenção, edite as variáveis no topo do script correspondente.

## Instalação (systemd service + timer)

Os passos abaixo servem tanto para v1 quanto para v2 — basta usar o conjunto de arquivos correspondente (`v1` ou `v2`). Os exemplos usam v1.

### 1. Permissão de execução ao script

```bash
chmod +x datetime-backup-v1-0.sh
```

### 2. Instalar o serviço

Copiar a unidade para `/etc/systemd/system/`, com proprietário root:

```bash
sudo cp datetime-backup-v1-1.service /etc/systemd/system/
```

O `ExecStart` já aponta para o caminho absoluto do script neste repositório:

```ini
[Unit]
Description=Executa o script datetime-backup-v1-0.sh

[Service]
Type=oneshot
User=andersoncastro
ExecStart=/home/andersoncastro/pulse-backup/git/github-andersongdecastro/datetime-backup/datetime-backup-v1-0.sh
```

### 3. Instalar o timer

```bash
sudo cp datetime-backup-v1-2.timer /etc/systemd/system/
```

```ini
[Unit]
Description=Executa o script datetime-backup-v1-0.sh diariamente às 04:00

[Timer]
OnCalendar=*-*-* 04:00:00
Persistent=true
Unit=datetime-backup-v1-1.service

[Install]
WantedBy=timers.target
```

### 4. Recarregar o systemd

```bash
sudo systemctl daemon-reload
```

### 5. Ativar e iniciar o timer

```bash
sudo systemctl enable --now datetime-backup-v1-2.timer
```

### 6. Verificar o timer

```bash
systemctl status datetime-backup-v1-2.timer
```

Para listar todos os timers e conferir a próxima execução:

```bash
systemctl list-timers --all
```

Você deverá encontrar uma linha referente a `datetime-backup-v1-2.timer`.

### 7. Testar o serviço manualmente

Antes de esperar até as 04:00, testar:

```bash
sudo systemctl start datetime-backup-v1-1.service
```

Depois ver o resultado:

```bash
systemctl status datetime-backup-v1-1.service
```

Um serviço com `Type=oneshot` executa uma tarefa e termina. Por isso, depois de uma execução bem-sucedida, o estado pode aparecer como `inactive (dead)`. Isso é normal para esse tipo de serviço.

### 8. Consultar os registros

Para consultar os registros da última execução:

```bash
journalctl -u datetime-backup-v1-1.service
```

Para ver somente os registros do boot atual:

```bash
journalctl -u datetime-backup-v1-1.service -b
```

Para acompanhar em tempo real:

```bash
journalctl -u datetime-backup-v1-1.service -f
```

## Evitar execução simultânea

O systemd normalmente não inicia uma segunda instância do mesmo serviço enquanto ele já estiver ativo. Portanto, se o script ainda estiver executando, o timer não deverá criar várias instâncias paralelas do mesmo serviço.

## Depois de editar um `.service` ou `.timer`, recarregar as unidades

```bash
sudo systemctl daemon-reload
```

Para verificar se os arquivos possuem erros:

```bash
systemd-analyze verify /etc/systemd/system/datetime-backup-v1-1.service
systemd-analyze verify /etc/systemd/system/datetime-backup-v1-2.timer
```

## Estrutura final (exemplo v1)

```
/home/andersoncastro/pulse-backup/git/github-andersongdecastro/datetime-backup/datetime-backup-v1-0.sh
/etc/systemd/system/datetime-backup-v1-1.service
/etc/systemd/system/datetime-backup-v1-2.timer
```

E os comandos principais serão:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now datetime-backup-v1-2.timer
systemctl list-timers --all
```

Para o comportamento de timer, **`systemd timer` com `Persistent=true` é a opção recomendada** — se o sistema estiver desligado no horário agendado, a execução ocorre assim que o sistema voltar a ligar.
