# 🖥️ Guia — Oracle Cloud Free Tier: criar a VM, abrir portas e instalar Docker

Guia para principiantes que nunca mexeram numa VPS. No fim, tens um servidor Ubuntu
**24/7 grátis** (Always Free) pronto para a stack do bot WhatsApp (`whatsapp-bot/`).

**Tempo total:** ~40 min na primeira vez. **Custo:** 0 € (Always Free).

> Lê cada passo até ao fim antes de executar. Quando um comando começa com
> `$` , escreve-o no terminal; o resto é explicação.

---

## 0. Pré-requisitos

- [ ] Conta na **Oracle Cloud** (oracle.com/cloud/free) — cartão de crédito para
      verificação, mas **não cobra nada** no Always Free
- [ ] Um **computador com terminal** (Windows: Git Bash ou PowerShell; Mac/Linux: terminal)
- [ ] (Recomendado) Um **domínio próprio** para HTTPS — sem ele o bot funciona por IP,
      mas os webhooks da Evolution preferem HTTPS (ver passos finais)
- [ ] ~10 min de paciência para a propagação do DNS (mais tarde)

---

## 1. Criar a máquina virtual (VM)

1. Entra em **cloud.oracle.com** → canto superior esquerdo → menu ☰ →
   **Compute → Instances → Create instance**.
2. **Name**: `whatsapp-bot`.
3. **Placement / Image and shape**:
   - *Image*: muda para **Ubuntu** → **Canonical Ubuntu 24.04** (versão *Minimal* se aparecer).
   - *Shape*: clica em **Change shape** → separador **Ampere** → seleciona
     **VM.Standard.A1.Flex** → deixa **4 OCPUs / 24 GB** (limite Always Free).
     > Se o ARM não aparecer, a região não tem capacidade — muda a **region**
     > (canto superior direito) e tenta de novo.
4. **Networking**: deixa tudo predefinido (a Oracle cria uma VCN e subnet novas).
5. **SSH keys**: escolhe **Generate a key pair** (em alternativa, cola uma pública tua):
   - Clica **Save private key** → guarda o ficheiro (ex.: `oracle-vps.key`) **num lugar seguro**.
   - ⚠️ **Sem esta chave não há segunda via** — perdeu-se a chave, perdeu-se o acesso à VM.
6. **Boot volume**: expande *Boot volume* → **Specify a custom boot volume size** →
   **50 GB** (ou 100 GB — o free tier inclui 200 GB no total).
7. Clica **Create**. Aguarda 30–60 s até o estado ficar **Running**.

8. Copia o **IP público**: na lista de instâncias, clica no nome → o *Public IP address*
   aparece em cima (ex.: `146.56.xx.xx`). Guarda-o — vais usar em todos os passos.

---

## 2. Abrir as portas 22, 80 e 443 no firewall da Oracle

A Oracle tem **dois** firewalls: o da consola (security list) e o do sistema operativo.
Fechar um deles basta para bloquear — por isso tens de abrir portas **nos dois**.

### 2.1 Firewall da consola (security list)

1. Menu ☰ → **Networking → Virtual cloud networks** → clica na VCN criada (ex.: `vcn-...`).
2. Na página, clica na **subnet pública** (*Public Subnet-...*).
3. Na lista de *Security Lists*, clica na **Default Security List for ...**.
4. **Add Ingress Rules** (regras de entrada) — adiciona **três**:

| Source CIDR | IP Protocol | Destination Port | Descrição |
|---|---|---|---|
| `0.0.0.0/0` | TCP | `22` | SSH (normalmente já existe) |
| `0.0.0.0/0` | TCP | `80` | HTTP |
| `0.0.0.0/0` | TCP | `443` | HTTPS |

5. **Add Ingress Rules** para guardar.

> **Nunca** abras as portas 8080 (Evolution), 5678 (n8n) nem 9000 (Portainer) —
> esses serviços ficam só internos, atrás do Caddy.

---

## 3. Ligar por SSH (primeira entrada)

Abre um terminal no teu computador. **Windows**: usa **Git Bash** (recomendado) ou PowerShell.

Navega até à pasta onde guardaste a chave e liga:

```bash
cd caminho/para/a/pasta-da-chave
ssh -i oracle-vps.key ubuntu@IP_PUBLICO
```

**Windows PowerShell** — se der erro de permissões da chave (`UNPROTECTED PRIVATE KEY FILE`),
executa antes:

```powershell
icacls oracle-vps.key /inheritance:r /grant:r "$($env:USERNAME):(R)"
```

Na primeira ligação aparece *“Are you sure you want to continue connecting?”* → escreve `yes`.

Deves ver um prompt como `ubuntu@whatsapp-bot:~$` — **estás dentro da VPS**. 🎉

> **Erro comum:** `Permission denied (publickey)` → confirmaste o `-i` com o caminho
> certo? O utilizador é `ubuntu` (não `root`).

---

## 4. Atualizar o sistema e abrir portas no firewall do SO

Ainda dentro da VPS:

```bash
sudo apt update && sudo apt upgrade -y
```

Ativa o firewall `ufw` com **apenas** 22, 80 e 443:

```bash
sudo ufw allow OpenSSH
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable
sudo ufw status
```

Saída esperada (as 3 regras ativas):

```
Status: active
22/tcp                     ALLOW       Anywhere
80/tcp                     ALLOW       Anywhere
443/tcp                    ALLOW       Anywhere
```

---

## 5. Instalar Docker (com o instalador oficial)

```bash
curl -fsSL https://get.docker.com | sudo sh
```

No fim, adiciona o teu utilizador ao grupo `docker` (para não precisares de `sudo`
em todos os comandos):

```bash
sudo usermod -aG docker $USER
```

**Sai e volta a entrar** (o grupo só se ativa numa nova sessão):

```bash
exit
# ...e liga outra vez:
ssh -i oracle-vps.key ubuntu@IP_PUBLICO
```

Confirma a instalação:

```bash
docker --version
docker compose version
```

Saída esperada (versões podem variar):

```
Docker version 28.x.x, build ...
Docker Compose version v2.x.x
```

Testa que o Docker funciona (opcional):

```bash
docker run --rm hello-world
```

---

## 6. Próximos passos — a stack do bot

Já tens a VPS pronta. Agora:

1. **DNS** — no registrador do teu domínio, cria registos **A** para
   `n8n.exemplo.com`, `evo.exemplo.com` e `portainer.exemplo.com` → IP público da VPS.
2. Copia a pasta **`whatsapp-bot/`** para a VPS:

   ```bash
   # no teu computador (Git Bash), a partir da raiz do projeto:
   scp -i oracle-vps.key -r whatsapp-bot ubuntu@IP_PUBLICO:~/
   ```

3. Continua o guia de instalação em **`whatsapp-bot/README.md`** (passos 7–12):
   preencher o `.env`, `docker compose up -d`, Portainer, parear o WhatsApp e o webhook.

---

## 🔧 Problemas comuns

| Sintoma | Causa | Solução |
|---|---|---|
| `ssh: Connection timed out` | Porta 22 fechada no firewall da Oracle | Rever passo 2.1 (security list) |
| `Permission denied (publickey)` | Chave errada / utilizador errado | Usar `-i` com o caminho certo e utilizador `ubuntu` |
| `docker: permission denied` | Esqueceste o `usermod -aG docker` + relogin | `sudo usermod -aG docker $USER` e `exit` + religar |
| `Could not resolve host` no `curl` | Falta de DNS na VM (raro) | `sudo apt update` e tentar de novo |
| HTTPS não aparece (mais tarde) | DNS ainda a propagar | `dig n8n.exemplo.com` até devolver o teu IP |

---

## 💡 Dicas finais

- **Guarda o IP público e a chave SSH** num gestor de palavras-passe.
- O free tier inclui **200 GB** de armazenamento — não te preocupes com o disco por agora.
- Se a VM ficar parada por muito tempo, a Oracle pode *stop* a instância ARM (pouco
  provável com uso real) — liga-a pela consola.
- Nunca desligues o telemóvel do WhatsApp do bot por longos períodos (re-registo).
