# Vídeos & Roteiros — Conteúdo Técnico

Ideias de vídeos com roteiros prontos para gravação. Cada vídeo tem versão longa (YouTube) e versão curta (Reels/Shorts).

---

## VÍDEO 1 — Como eu criei um CRM do zero sem saber programar (usando IA)

### Versão longa (YouTube ~12 min)

**Overview (0:00–1:30) ← gravar esse trecho com energia máxima**
> "Eu criei um CRM completo — funil de vendas, dashboard, gestão de clientes, planejamento financeiro — em menos de uma semana. Sem contratar desenvolvedor. Sem saber programar do zero. Vou te mostrar exatamente como fiz isso usando inteligência artificial, e o mais importante: você pode fazer o mesmo para o seu negócio hoje."

Mostrar na tela: o CRM rodando — kanban, dashboard com gráficos, tela de planejamento financeiro.

**Contexto (1:30–3:00)**
- Problema: ferramentas prontas de CRM são caras e genéricas (Pipedrive, HubSpot)
- Solução: construir algo 100% personalizado para o seu processo comercial
- Custo: próximo de zero (GitHub Pages gratuito + Supabase gratuito)

**Ferramentas usadas (3:00–5:00)**
- Claude Code (IA que escreve o código)
- VS Code (editor)
- GitHub Pages (hospedagem gratuita)
- Supabase (banco de dados na nuvem gratuito)
- Sem framework, sem servidor, sem complicação

**Demo ao vivo (5:00–10:00)**
- Mostrar login
- Criar um lead no funil
- Mover pelo kanban
- Abrir dashboard com métricas
- Gerar planejamento financeiro em PDF

**Como replicar (10:00–12:00)**
- Repositório GitHub disponível
- Tutorial completo no arquivo tutorial.md
- Próximos vídeos: cada módulo em detalhe

**CTA final**
> "Se você quer o código ou quer que eu monte isso para o seu negócio, comenta aqui embaixo."

---

### Versão curta — Reels/Shorts (45–60 seg)

**Gancho (0–3 seg)**
> "Eu criei um CRM completo em uma semana. Sem programador. Sem pagar nada."

**Prova visual (3–15 seg)**
Tela gravada: abrir o CRM, mostrar o kanban com leads, dashboard, PDF do planejamento. Sem falar, só mostrar com música.

**Como (15–35 seg)**
> "Usei o Claude Code — uma IA que escreve código — e descrevi o que eu queria. Ele construiu. Eu refinei. Está rodando em produção hoje."

**Resultado (35–50 seg)**
> "Funil de vendas, dashboard em tempo real, planejamento financeiro com geração de PDF. Hospedado de graça no GitHub. Banco de dados no Supabase, também gratuito."

**CTA (50–60 seg)**
> "Tutorial completo no YouTube. Link na bio."

---
---

## VÍDEO 2 — Como automatizar a captação de leads do Instagram direto para o CRM

### Versão longa (YouTube ~10 min)

**Overview (0:00–1:30)**
> "Toda vez que alguém preenche o formulário da sua campanha no Instagram, esse lead cai automaticamente no seu CRM — sem você fazer nada. Vou mostrar como configurar isso hoje usando n8n e Supabase."

Mostrar: formulário no Instagram → lead aparecendo no CRM em tempo real.

**O problema (1:30–2:30)**
- Leads gerados pelo Meta ficam presos no Gerenciador de Anúncios
- Você precisa exportar CSV manualmente
- Perde velocidade de resposta (lead frio = lead perdido)

**A solução (2:30–4:00)**
- Meta Lead Ads tem webhook — avisa em tempo real quando chega lead
- n8n recebe esse aviso e insere direto no banco de dados do CRM
- Tudo automático, 24h por dia

**Arquitetura (4:00–5:30)**
```
Instagram → Meta Lead Ads → Webhook → n8n → Supabase → CRM
```
Desenhar isso na tela enquanto explica.

**Configuração passo a passo (5:30–9:00)**
- Criar app no Meta for Developers
- Configurar webhook no n8n
- Mapear campos (nome, telefone, e-mail) para a tabela de leads
- Testar com lead real

**Resultado (9:00–10:00)**
- Demo ao vivo: preencher formulário no Instagram → lead aparece no CRM
- Custo: zero (n8n self-hosted no VPS)

---

### Versão curta — Reels/Shorts (45–60 seg)

**Gancho (0–3 seg)**
> "Seu lead do Instagram ainda chega por planilha? Isso aqui vai mudar."

**Demo visual (3–20 seg)**
Tela dividida: formulário Instagram sendo preenchido de um lado, CRM abrindo o lead do outro lado em tempo real.

**Como funciona (20–45 seg)**
> "O Meta avisa o n8n quando chega um lead. O n8n insere direto no banco de dados. O CRM atualiza na hora. Zero intervenção manual. Zero custo — n8n roda no próprio servidor."

**CTA (45–60 seg)**
> "Tutorial completo no canal. Qual ferramenta de automação você usa hoje?"

---
---

## VÍDEO 3 — Monte seu servidor por R$ 44/mês e pare de pagar por SaaS

### Versão longa (YouTube ~15 min)

**Overview (0:00–2:00)**
> "Eu estava pagando por Zapier, por Supabase Pro, por serviços de e-mail, por hospedagem... Aí percebi que por R$ 44 por mês eu consigo rodar tudo isso no meu próprio servidor — e ainda sobra capacidade. Vou te mostrar o que coloquei lá e quanto estou economizando."

**O problema dos SaaS (2:00–4:00)**
- Cada ferramenta tem seu plano, seu limite, sua cobrança
- Zapier: R$ 100+/mês para volume mínimo
- Supabase Pro: $25/mês
- Hospedagem: variável
- Tudo somado: caro e fragmentado

**A solução: VPS + Coolify (4:00–7:00)**
- VPS = servidor virtual na nuvem (Hostinger, DigitalOcean, Hetzner)
- Coolify = painel que gerencia tudo com interface visual
- HTTPS automático, deploy do GitHub automático, one-click install

**O que roda no servidor (7:00–11:00)**
- n8n (substitui Zapier/Make — R$ 0)
- Supabase self-hosted (substitui Supabase Pro — R$ 0)
- Projetos estáticos com deploy automático (substitui Netlify/Vercel — R$ 0)
- Servidor de e-mail próprio (substitui SendGrid/Resend — R$ 0)

**Demo do Coolify (11:00–14:00)**
- Mostrar o painel
- Instalar o n8n em um clique
- Configurar domínio + HTTPS automático

**Conta final (14:00–15:00)**
- VPS: R$ 44/mês
- Substituiu: R$ 300–500/mês em SaaS
- ROI: imediato

---

### Versão curta — Reels/Shorts (45–60 seg)

**Gancho (0–3 seg)**
> "Por R$ 44 por mês eu substituí mais de R$ 400 em ferramentas SaaS."

**Lista rápida (3–30 seg)**
> "No meu servidor roda: n8n — que substitui o Zapier. Supabase self-hosted — banco de dados sem limite. Deploy automático dos meus projetos. Servidor de e-mail próprio. Tudo com HTTPS, tudo com painel visual, instalado em minutos com o Coolify."

**Comparativo (30–50 seg)**
Mostrar na tela: coluna "Antes" com logos e preços vs coluna "Depois" com VPS único.

**CTA (50–60 seg)**
> "O link do tutorial completo está no YouTube. Qual SaaS você pagaria menos se tivesse um servidor próprio?"

---
---

## VÍDEO 4 — Planejamento financeiro de aposentadoria: como gerei o PDF automaticamente

### Versão longa (YouTube ~8 min)

**Overview (0:00–1:00)**
> "Assessores de investimento precisam entregar um relatório de planejamento financeiro para cada cliente. Esse processo era manual, demorado, cheio de erros. Automatizei tudo — o sistema calcula, gera o PDF e já está pronto para entregar. Vou mostrar como funciona."

**O módulo (1:00–3:00)**
- Campos: idade, aporte mensal, retirada desejada, expectativa de vida
- Parâmetros: CDI, inflação, retorno
- Cenários comparativos
- Indicadores: reserva na aposentadoria, independência financeira, retirada máxima

**Demo ao vivo (3:00–6:00)**
- Criar planejamento para um cliente fictício
- Preencher cenário
- Gerar PDF de 5 páginas: capa, conferência de dados, diagnóstico, evolução da reserva, disclaimer

**Tecnologia (6:00–7:30)**
- html2pdf.js para geração do PDF no browser
- Chart.js para os gráficos
- Cálculos financeiros em JavaScript puro (sem backend)
- Tudo roda no cliente — zero servidor

**CTA (7:30–8:00)**
> "Esse módulo está integrado ao CRM que mostrei no vídeo 1. Link nos comentários."

---

### Versão curta — Reels/Shorts (30–45 seg)

**Gancho (0–3 seg)**
> "Planejamento financeiro de aposentadoria gerado em PDF em 30 segundos."

**Demo (3–30 seg)**
Gravação de tela: preencher os dados do cliente → clicar em exportar → PDF aparece com capa, gráficos, tabela de evolução.

**CTA (30–45 seg)**
> "Esse sistema é open source e gratuito. Tutorial no canal."

---
---

## VÍDEO 5 — Claude Code: como usar IA para construir software sem saber programar

### Versão longa (YouTube ~10 min)

**Overview (0:00–1:30)**
> "O Claude Code não é um chatbot. É uma IA que opera dentro do seu projeto, lê os arquivos, edita o código, roda comandos no terminal e commita no GitHub — tudo sozinho. Vou te mostrar como usá-lo para construir funcionalidades reais."

**O que é o Claude Code (1:30–3:00)**
- Diferença entre Claude chat e Claude Code
- Roda no terminal / VS Code
- Lê e edita arquivos do projeto
- Tem memória do projeto entre sessões
- Age como um desenvolvedor júnior que você orienta

**Demo ao vivo (3:00–7:30)**
- Mostrar uma funcionalidade sendo pedida em linguagem natural
- Claude lendo os arquivos relevantes
- Escrevendo o código
- Commitando no GitHub
- Resultado aparecendo no site

**Boas práticas (7:30–9:00)**
- Ser específico no que pede
- Revisar o que foi feito antes de commitar
- Usar para bugfix, novas features, refatoração
- Não usar para decisões de negócio

**CTA (9:00–10:00)**
> "No próximo vídeo mostro como usei o Claude Code para construir um módulo financeiro completo em uma tarde."

---

### Versão curta — Reels/Shorts (45–60 seg)

**Gancho (0–3 seg)**
> "Essa IA lê o seu código, edita os arquivos e commita no GitHub sozinha."

**Demo (3–40 seg)**
Gravação de tela: digitar instrução em linguagem natural → Claude abrindo arquivos, editando código, rodando git commit → mudança aparecendo no site ao vivo.

**CTA (40–60 seg)**
> "Chama Claude Code. Está disponível no VS Code. Tutorial completo no canal."

---
---

## Ordem de gravação sugerida

| Prioridade | Vídeo | Motivo |
|---|---|---|
| 1º | Vídeo 1 — CRM do zero | Âncora do canal, apresenta tudo |
| 2º | Vídeo 5 — Claude Code | Explica a ferramenta usada em todos os outros |
| 3º | Vídeo 4 — PDF financeiro | Demo visual forte, nicho específico (assessores) |
| 4º | Vídeo 3 — Servidor próprio | Relevante quando tiver o VPS contratado |
| 5º | Vídeo 2 — Leads do Instagram | Gravar após integração Meta → n8n estar funcionando |

---

## Dicas de gravação

- **Primeiros 30 segundos são decisivos** — mostrar o resultado final antes de explicar o processo
- Gravar tela em resolução 1920x1080 mínimo
- Usar OBS Studio (gratuito) para gravação
- Shorts/Reels: gravar em vertical (9:16) ou cortar o centro do vídeo horizontal
- Legendas automáticas no CapCut ou Descript aumentam retenção em ~40%
- Postar o Reel primeiro, usar a repercussão para validar se o vídeo longo vale gravar
