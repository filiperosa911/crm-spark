# Infraestrutura & Ferramentas — Roadmap Técnico

Registro das alternativas avaliadas e decisões de infraestrutura para os projetos da Spark/Strivo.

---

## Projetos em andamento

### CRM Spark
CRM comercial da equipe Spark/Safra. Stack atual: HTML/JS/CSS estático hospedado no GitHub Pages, banco de dados no Supabase cloud (plano gratuito), autenticação via Supabase Auth.

### Plataforma Strivo (em planejamento)
CRM ampliado com automação de processos de pagamento. Além das funcionalidades do CRM Spark, incluirá integração com gateways de pagamento, automação de cobranças e fluxos financeiros.

---

## Stack atual

| Camada | Ferramenta | Observação |
|---|---|---|
| Frontend | HTML/JS/CSS estático | Sem framework, sem build |
| Hospedagem | GitHub Pages | Gratuito, deploy via git push |
| Banco de dados | Supabase cloud (free tier) | Limite: 500 MB, 2 projetos ativos |
| Autenticação | Supabase Auth | E-mail + reset de senha |
| E-mail transacional | Gmail SMTP | Limite de envios, domínio pessoal |

---

## Stack alvo (com VPS)

```
VPS (Hostinger KVM 2 ou similar)
└── Coolify (painel de controle unificado)
    ├── Supabase self-hosted     → supabase.seudominio.com
    ├── n8n                      → n8n.seudominio.com
    ├── CRM Spark (staging)      → crm-dev.seudominio.com
    └── Plataforma Strivo        → app.strivo.com.br
```

---

## Ferramentas avaliadas

### Coolify
**O que é:** plataforma open source de gerenciamento de serviços no VPS (alternativa self-hosted ao Heroku/Vercel/Railway).

**Benefícios:**
- Painel web para gerenciar todos os containers sem linha de comando
- HTTPS automático via Let's Encrypt para todos os serviços
- Reverse proxy (Traefik) configurado automaticamente
- Integração com GitHub: deploy automático a cada push
- One-click install para n8n, Supabase, PostgreSQL, Redis e outros
- Gratuito e open source

**Como usar:** instalar no VPS com um único comando. Todo o resto é gerenciado pela interface web.

---

### n8n
**O que é:** plataforma de automação open source (alternativa ao Zapier/Make).

**Benefícios:**
- Self-hosted = sem custo por operação (diferente do Zapier/Make)
- Integração nativa com Meta Lead Ads, Supabase, WhatsApp, Gmail, Notion e centenas de outros
- Visual, sem código — cria fluxos arrastando blocos
- Ideal para o fluxo: **Instagram Lead Ads → CRM Spark** (insere lead direto na tabela `leads` do Supabase)
- Útil também para: notificações automáticas, relatórios periódicos, automação de pagamentos (Plataforma Strivo)

**Fluxo imediato planejado:**
```
Meta Lead Ads → n8n → Supabase (tabela leads) → aparece no CRM automaticamente
```

---

### Supabase self-hosted
**O que é:** rodar o próprio Supabase no VPS em vez de usar o plano gratuito na nuvem.

**Benefícios:**
- Sem limite de banco de dados (free tier limita a 500 MB)
- Sem limite de projetos ativos (free tier limita a 2)
- Sem limite de Edge Functions
- Controle total dos dados (importante para compliance)
- Custo zero além do VPS

**Relevante para Strivo:** processos de pagamento exigem controle total dos dados — self-hosted elimina dependência de terceiros.

---

### VPS Hostinger KVM 2
**Especificações:** 2 vCPU, 8 GB RAM, 80 GB NVMe, 8 TB bandwidth
**Preço:** R$ 43,99/mês (promocional 60% off) → renova a R$ 77,99/mês

**Capacidade estimada simultânea:**
- Coolify
- n8n
- Supabase self-hosted (CRM Spark + Plataforma Strivo)
- Nginx/Traefik (incluso no Coolify)
- Projetos estáticos adicionais

**Alternativas de VPS gratuitas:**
- Oracle Cloud Always Free: 1 vCPU, 1 GB RAM — suficiente apenas para n8n isolado

---

### E-mail transacional (futuro)
Atual: Gmail SMTP (limite de envios, domínio @gmail).
Alternativas avaliadas:
- **Resend**: gratuito até 3.000 e-mails/mês, domínio próprio (@sparkinvest.com.br) — requer verificação de domínio
- **Postal** (self-hosted no VPS): servidor de e-mail próprio, custo zero além do VPS
- **Amazon SES**: ~$0,10 por mil e-mails, mais confiável para volume alto

---

## Próximos passos sugeridos

- [ ] Contratar VPS
- [ ] Instalar Coolify no VPS
- [ ] Instalar n8n via Coolify
- [ ] Configurar integração Meta Lead Ads → n8n → Supabase
- [ ] Avaliar migração do Supabase cloud para self-hosted
- [ ] Iniciar planejamento técnico da Plataforma Strivo
- [ ] Migrar e-mail transacional para domínio @sparkinvest.com.br (Resend ou Postal)
