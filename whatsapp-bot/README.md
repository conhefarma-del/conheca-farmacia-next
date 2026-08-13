# 🤖 Conheça Farmácia — WhatsApp Bot

Bot de WhatsApp do Conheça Farmácia a correr numa VPS **Oracle Cloud (Always Free)**, com:

| Serviço | Função | Porta interna |
|---|---|---|
| **Caddy** | Reverse proxy + HTTPS automático (única porta pública) | 80 / 443 |
| **n8n** | Workflows do bot (recebe webhook → processa → responde) | 5678 |
| **Evolution API** | Ligação ao WhatsApp (Baileys / Cloud API) | 8080 |
| **Postgres ×2** | Bases de dados do n8n e da Evolution | 5432 |
| **Redis** | Cache/eventos da Evolution | 6379 |
| **Portainer** | GUI web para gerir o Docker | 9000 |

> **⚠️ Importante antes de começar:** a Evolution API usa o protocolo do WhatsApp Web (Baileys) — API **não oficial**. Para uma marca como o Conheça Farmácia, o caminho recomendado a médio prazo é a **Cloud API oficial da Meta** (a Evolution suporta ambos na mesma instalação). Como o bot só **responde** a utilizadores (sem spam), o risco é baixo. Nunca faças envios em massa não solicitados.

---

## Checklist de setup na Oracle Cloud

### 1. Criar a VM (5 min)

1. Entra na consola Oracle Cloud → **Compute → Instances → Create instance**.
2. Nome: `whatsapp-bot`.
3. **Image**: Ubuntu **24.04** (mínima).
4. **Shape**: muda para **Ampere (ARM)** → `VM.Standard.A1.Flex` (free tier). Mantém **4 OCPUs / 24 GB RAM**.
5. **Networking**: deixa a VCN/Subnet predefinidas.
6. **SSH keys**: escolhe *Generate a key pair* e **guarda o ficheiro `.key` num lugar seguro** (é a tua única porta de entrada).
7. **Boot volume**: 50 GB ou 100 GB (boot volume também tem free tier).
8. Create → espera ~1 min → copia o **IP público** (público e privado).

### 2. Abrir portas no firewall da Oracle (não esquecer!)

A Oracle tem firewall próprio **além** do firewall do sistema. Tens de abrir **80 e 443** (e confirmar o **22**).

1. Consola → **Networking → Virtual cloud networks → (a tua VCN)**.
2. No subnet público → **Security List** (ou *Network Security Group*, se usares) → *Ingress Rules* → **Add Ingress Rules**:
   - `22/tcp` (SSH, já deve existir) — origem `0.0.0.0/0`
   - `80/tcp` (HTTP) — origem `0.0.0.0/0`
   - `443/tcp` (HTTPS) — origem `0.0.0.0/0`
3. **Nunca abras a 8080** (Evolution) nem a 5678 (n8n) publicamente — ficam só internas.

### 3. Ligar por SSH (Windows: usa Git Bash ou PowerShell)

```bash
ssh -i caminho/para/chave.key ubuntu@IP_PUBLICO
```

> No Windows PowerShell, se der erro de permissões na chave: `icacls chave.key /inheritance:r /grant:r "$($env:USERNAME):(R)"`.

### 4. Atualizar o sistema e abrir portas no firewall do SO

```bash
sudo apt update && sudo apt upgrade -y
# Firewall do SO (portas 22, 80, 443)
sudo ufw allow OpenSSH
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable
sudo ufw status
```

### 5. Instalar Docker e o plugin do Compose

```bash
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER
# Sair e voltar a entrar para o grupo docker ser ativado:
exit
# ...voltou ao SSH? ...
docker --version && docker compose version
```

### 6. DNS — apontar os subdomínios para a VPS

No registrador do teu domínio (ex.: Cloudflare, Namecheap), cria registos **A**:

```
n8n.exemplo.com          A   IP_PUBLICO
evo.exemplo.com          A   IP_PUBLICO
portainer.exemplo.com    A   IP_PUBLICO
```

> Sem um domínio real não há HTTPS automático. Para testes rápidos sem domínio, podes usar o IP direto, mas os webhooks da Evolution preferem HTTPS — um domínio barato (~10 €/ano) resolve.

### 7. Subir a stack

```bash
mkdir -p ~/whatsapp-bot
cd ~/whatsapp-bot
# Copia os ficheiros deste repositório (docker-compose.yml, Caddyfile, .env.example)
cp .env.example .env
nano .env        # preenche TODOS os valores (ver secção "Gerar segredos")
nano Caddyfile   # substitui os 3 domínios pelos teus
docker compose up -d
docker compose ps        # tudo "Up"? 
```

**Gerar segredos** (colar nos campos do `.env`):

```bash
openssl rand -hex 32     # N8N_ENCRYPTION_KEY, EVOLUTION_API_KEY, EVOLUTION_WEBHOOK_SECRET
```

> Se editares `.env` depois de arrancar, `docker compose up -d` volta a aplicar.

### 8. Portainer (opcional mas recomendado)

1. Abre `https://portainer.exemplo.com` (aceita o aviso do browser na 1ª vez).
2. Cria o utilizador admin (só na 1ª entrada).
3. Escolhe o ambiente **Docker local** → tens a GUI de tudo (logs, restart, terminal).

### 9. Ligar o WhatsApp à Evolution API

1. Abre `https://evo.exemplo.com` → no browser pede a **API key** → cola a `EVOLUTION_API_KEY`.
2. **Instances → Criar instância** (ex.: `cf-bot`) → conecta.
3. **Gerar QR Code** → lê com o telemóvel do número que vai ser o bot.
4. Quando ligar, o estado fica *CONNECTED*. **Não desligues o telefone da internet por muito tempo** (o WhatsApp pode exigir re-registo).

### 10. Webhook no n8n → fluxo do bot

1. Abre `https://n8n.exemplo.com` (login com o `N8N_BASIC_AUTH_*`).
2. Cria um workflow com o node **Webhook**:
   - Path: `/evolution`
   - Método: `POST`
   - Ativa o workflow.
3. Volta à Evolution → instância → **Webhook**:
   - URL: `https://n8n.exemplo.com/webhook/evolution`
   - Eventos: `MESSAGES_UPSERT` (mensagens recebidas).
   - Guarda → o `EVOLUTION_WEBHOOK_URL` do `.env` já aponta para isto (a Evolution entrega por lá quando ativas *Global*).
4. No n8n: node **HTTP Request** → `POST https://evo.exemplo.com/message/sendText/{instance}` com header `apikey: EVOLUTION_API_KEY` e body `{ "number": "...", "text": "..." }`.

> **Dica:** para responder apenas quando o utilizador escreve (e ignorar as tuas próprias mensagens), filtra no n8n com `key.remoteJid` ≠ o número do bot e `key.fromMe` = false.

### 11. Backups (crítico!)

O estado da ligação WhatsApp vive na BD da Evolution — **perder a BD = perder a ligação**.

```bash
# Backups diários (cron):
# 05 03 * * * docker exec evolution-db pg_dump -U evolution evolution | gzip > ~/backups/evolution-$(date +\%F).sql.gz
# 05 04 * * * docker exec n8n-db pg_dump -U n8n n8n | gzip > ~/backups/n8n-$(date +\%F).sql.gz
```

Copia os backups para fora da VPS (ex.: `scp -i chave ubuntu@IP:~/backups/* .`) — uma VPS não é um backup.

### 12. Segurança extra (recomendado, 10 min)

```bash
sudo apt install -y fail2ban
sudo systemctl enable --now fail2ban        # bloqueia tentativas de SSH
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure --priority=low unattended-upgrades   # updates automáticos
```

---

## Comandos do dia-a-dia

```bash
cd ~/whatsapp-bot
docker compose ps                    # estado dos serviços
docker compose logs -f n8n           # logs do n8n
docker compose logs -f evolution     # logs da Evolution
docker compose restart evolution     # reiniciar só a Evolution
docker compose pull && docker compose up -d   # atualizar tudo (faz backup antes!)
```

## Problemas comuns

| Sintoma | Causa provável | Fix |
|---|---|---|
| Caddy não emite HTTPS | DNS não aponta / propagação | `dig n8n.exemplo.com`; espera propagação |
| Não acede ao n8n/Portainer | Porta 80/443 fechada no firewall da Oracle OU do SO | Rever o passo 2 e 4 |
| QR não aparece / instância desliga | Falta Redis ou BD | `docker compose logs evolution` |
| Bot não responde | Webhook errado ou evento não ativado | Rever passo 10 e testar com `curl` ao webhook |
| Número bloqueado | Envio em massa / comportamento de spam | Nunca enviar sem o utilizador pedir; usar número dedicado |

---

## Próximos passos possíveis

- Migrar para a **Cloud API oficial da Meta** (mesma Evolution API, só muda o *connection type* da instância).
- Ligar o bot à BD do site (Supabase) para responder com dados reais de medicamentos/interações.
- Notificações proativas (ex.: lembrar inscritos de eventos) — **apenas com Cloud API oficial** e opt-in.
