# Plano de Implementação — Módulo de Planejamento Financeiro
> Arquivo de contexto completo para retomada em caso de queda de conexão.  
> Última atualização: 2026-06-23

---

## 1. CONTEXTO DO PROJETO

### O que é
Integração de um **módulo de planejamento financeiro de aposentadoria** dentro do CRM Spark (crm-safra). O módulo replica as funcionalidades da plataforma **fin-tracks.com** (versão legada), com design moderno e integrado ao fluxo de clientes já existente no CRM.

### Objetivo
O assessor financeiro usa o CRM para gerir leads e clientes. Quando um lead é fechado (vira cliente), o assessor precisa fazer um planejamento financeiro de aposentadoria para ele — gerando cenários, gráficos e um relatório PDF profissional para entregar ao cliente.

---

## 2. ANÁLISE DA PLATAFORMA LEGADA (fin-tracks.com)

### Funcionalidades mapeadas (via Playwright + capturas)
Todas as capturas estão em: `G:\Meu Drive\_TRABALHO\fintrack\screenshots\`  
Relatório bruto em: `G:\Meu Drive\_TRABALHO\fintrack\platform_report.md`

#### Telas capturadas:
| Arquivo | Seção |
|---------|-------|
| `01_Simulacao_Financeira.png` | Aba principal da simulação |
| `02_Diagnostico_Aposentadoria_e_Independenci.png` | Gráfico diagnóstico |
| `03_Evolucao_da_Reserva_Financeira.png` | Gráfico evolução + tabela |
| `04_Comparacao_de_Cenarios.png` | Comparação entre cenários |
| `05_Relatorio.png` | Configurações do relatório |
| `06_Relatorio_Parte_2.png` | Relatório — parte 2 |
| `07_Relatorio_Parte_3.png` | Relatório — parte 3 |
| `screenshots/pdf_pages/page_01.png` a `page_12.png` | PDF exportado completo |

#### Estrutura de abas do formulário de cliente:
1. **Dados Básicos** — perfil, renda, idade, responsabilidade
2. **Simulação Financeira** — parâmetros + cenários + gráficos
3. **Considerações Finais** — texto livre do assessor
4. **Relatório** — configurações de exportação
5. **Acompanhamento** — histórico

#### Parâmetros da simulação:
- % CDI Anual
- % Retorno sobre o CDI
- Taxa de Juros
- % Inflação Anual
- % Retorno Anual Real (calculado)
- Data da Simulação

#### Dados do cliente na simulação:
- Nome Curto
- Idade atual
- Vai trabalhar até (idade)
- Expectativa de Vida
- Idade Data Simulação
- Receita Mensal
- % Responsabilidade

#### Campos por cenário:
- Nome do cenário
- Aporte Mensal antes de aposentar
- Retirada Mensal depois de aposentar
- Capacidade de Poupança / Sugestão de Aporte
- Aportes/Retiradas Mensais por faixa de idade (tabela dinâmica)
- Aportes/Retiradas Anuais ou Únicos por faixa (tabela dinâmica)
- Checkboxes para exibir valores com inflação

#### Ações por cenário:
- Adicionar Cenário
- Alterar o Cenário
- Excluir o Cenário
- Controle de visibilidade (visibility toggle)
- Percentual de alocação (ex: 100%)

#### Gráficos:
1. **Diagnóstico Aposentadoria & Independência Financeira**
   - Linha: evolução da reserva por idade
   - Eixo X: idade (do atual até expectativa de vida)
   - Eixo Y: valor da reserva em R$
   - Anotação: valor atual da reserva no início
   - Destaque: ponto de aposentadoria
   - Legenda: retirada máxima preservar / consumir / reserva
   - Barra de Independência Financeira: `%`

2. **Evolução da Reserva Financeira**
   - Mesma linha, com destaque fase acúmulo vs. fase retirada
   - Tabela ano a ano abaixo do gráfico

3. **Comparação de Cenários**
   - Múltiplas linhas (uma por cenário)
   - Tabela comparativa ano a ano

#### Configurações do Relatório PDF (checkboxes):
- Exibir Capacidade de Poupança
- Exibir Aportes e Retiradas Planejados
- Exibir/Ocultar Gráfico Diagnóstico
- Exibir/Ocultar Evolução da Reserva
- Exibir Proteção Sugerida
- Exibir Sucessão Vitalícia
- Exibir Comparação de Cenários
- Exibir Comparação de Cenários sem Tabela/Gráfico
- Formato do relatório (radio — 2 opções)
- Seleção do cenário principal

---

## 3. ANÁLISE DO PDF GERADO

**12 páginas**, todas com cabeçalho teal + logo Spark + rodapé "Elaborado por: FILIPE ROSA"

| Pág | Seção | Conteúdo |
|-----|-------|----------|
| 1 | **Capa** | Logo Spark + "NOME, o seu planejamento financeiro" — fundo teal escuro |
| 2 | **Conferência de Dados** | Foto/avatar + dados pessoais + tabela Parâmetros + tabela Cliente |
| 3 | **Aportes e Retiradas Planejados** | Tabela Mensais (Idade Inicial, Final, Aporte, Retirada, Observação) + Tabela Anuais/Únicos |
| 4 | **Diagnóstico: Aposentadoria & Independência Financeira** | Gráfico de linha + 3 bullets de retirada máxima + barra % Independência |
| 5–7 | **Evolução da Reserva Financeira** | Tabela: Ano, Idade, Rec. Fin. Começo, Aporte Mensal, Retirada Mensal, Aporte/Retirada Anual, Rendimento Mensal, Rec. Fin. Final |
| 7 (final) | **Texto resumo** | "Com reserva inicial de R$X, aportes de R$Y e rendimento de R$Z, a reserva no início da aposentadoria será de R$W. Importante: aportes precisam ser reajustados pela inflação." |
| 8–10 | **Comparação de Cenários** | Gráfico multi-linha + tabela Ano, Idade, Cenário 1, Cenário 2... |
| 11 | **Resumo Comparativo** | Tabela: Parâmetros / Retiradas Planejadas / Aportes Planejados / Aposentadoria (por cenário) |
| 12 | **Disclaimer** | Texto legal + "Elaborado por: FILIPE ROSA em DD/MM/AAAA" |

---

## 4. ANÁLISE DO CRM EXISTENTE (crm-safra)

### Stack
- **Frontend:** Vanilla JavaScript (ES6+) — SPA, sem framework
- **UI:** Tailwind CSS v3 via CDN + design system custom (styles.css)
- **Backend:** Supabase JS v2 via CDN
- **Banco:** PostgreSQL (Supabase)
- **Auth:** Supabase Auth + sessionStorage

### Arquivos principais
```
crm-safra/
├── index.html       # Toda a markup (1226 linhas)
├── app.js           # Toda a lógica (2782 linhas)
├── styles.css       # Design system (886 linhas)
├── mock-data.js     # Dados iniciais
├── config.js        # Credenciais Supabase
├── database.sql     # Schema completo com RLS + triggers
└── supabase-schema.sql
```

### Tema visual
- **Dark mode (padrão):** background `#0c0e15`, primária cyan `#008394`
- **Light mode:** background `#f8fafc`, primária amber `#d97706`
- **Componente chave:** `.glass-card` (glassmorphism com blur 12px)
- **Fontes:** Inter (UI) + JetBrains Mono (números)

### Rotas (views) existentes
| data-target | Função | Descrição |
|-------------|--------|-----------|
| `crm` | `renderCRM()` | Funil Kanban/Lista |
| `pipeline` | `renderPipeline()` | Pipeline consolidado |
| `financial` | `renderFinancial()` | Motor de rateios |
| `approvals` | `renderApprovals()` | Aprovações de aportes |
| `partnerships` | `renderPartnerships()` | Parcerias |
| `dashboard` | `renderDashboard()` | Painel executivo |
| `settings` | `renderFunnelStages()` | Ajustes do funil |
| `users` | `renderUsersManagement()` | Gestão de usuários |

### Padrão de código (a seguir rigorosamente)
```javascript
// Render function padrão
function renderNomeSecao() {
  const container = document.getElementById('view-nome-secao');
  container.innerHTML = `...html com template literal...`;
  // event listeners após innerHTML
}

// Modal padrão
function openNomeModal(id = null) {
  document.getElementById('modal-overlay').innerHTML = `...`;
  document.getElementById('modal-overlay').classList.remove('hidden');
}

// Salvar padrão
async function saveNome(event) {
  event.preventDefault();
  // 1. Coletar dados do form
  // 2. Salvar em db local
  // 3. saveDataStore() → Supabase upsert
  // 4. Re-render
}
```

### Tabelas existentes no Supabase
1. `users` — assessores, gestores, diretoria
2. `products` — fundos de investimento
3. `stages` — etapas do funil
4. `leads` — oportunidades no funil
5. `clients` — clientes efetivados (leads fechados)
6. `aportes` — transações / investimentos
7. `faturamentohistorico` — receitas de taxa adm

### Entidade "Cliente" no CRM
- Lead com `status: 'fechado'` gera um `clientCode` (ex: `CLI-SPK-001`)
- Cliente tem `agentId`, `leaderId`, `productId`
- O módulo de planejamento se vincula ao `client_code`

---

## 5. PLANO DE IMPLEMENTAÇÃO

### Fase 1 — Banco de dados (Supabase)
Arquivo: `financial-schema.sql`

```sql
-- Tabela principal do plano
CREATE TABLE financial_plans (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  client_code TEXT NOT NULL,
  client_name TEXT,
  agent_id INTEGER REFERENCES users(id),
  leader_id INTEGER,
  -- Parâmetros globais
  cdi_anual NUMERIC(8,4) DEFAULT 11.00,
  retorno_cdi NUMERIC(8,4) DEFAULT 110.00,
  taxa_juros NUMERIC(8,4) DEFAULT 12.10,
  inflacao_anual NUMERIC(8,4) DEFAULT 5.82,
  retorno_anual_real NUMERIC(8,4),  -- calculado
  -- Config do relatório
  exibir_capacidade_poupanca BOOLEAN DEFAULT true,
  exibir_aportes_planejados BOOLEAN DEFAULT true,
  exibir_grafico_diagnostico BOOLEAN DEFAULT true,
  exibir_evolucao_reserva BOOLEAN DEFAULT true,
  exibir_protecao_sugerida BOOLEAN DEFAULT false,
  exibir_sucessao_vitalicia BOOLEAN DEFAULT false,
  exibir_comparacao_cenarios BOOLEAN DEFAULT true,
  formato_relatorio TEXT DEFAULT 'completo',
  consideracoes_finais TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Cenários por plano
CREATE TABLE financial_scenarios (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  plan_id UUID REFERENCES financial_plans(id) ON DELETE CASCADE,
  nome TEXT DEFAULT 'Cenário 1',
  ordem INTEGER DEFAULT 1,
  is_active BOOLEAN DEFAULT true,
  is_visible BOOLEAN DEFAULT true,
  -- Dados do cliente neste cenário
  idade_inicial INTEGER,
  vai_trabalhar_ate INTEGER,
  expectativa_vida INTEGER DEFAULT 90,
  receita_mensal NUMERIC(15,2),
  percentual_responsabilidade NUMERIC(5,2) DEFAULT 100,
  -- Fluxo financeiro
  reserva_inicial NUMERIC(15,2) DEFAULT 0,
  aporte_mensal NUMERIC(15,2) DEFAULT 0,
  retirada_mensal_apos NUMERIC(15,2) DEFAULT 0,
  -- Taxas diferenciadas pós-aposentadoria
  diferenciar_taxas_apos BOOLEAN DEFAULT false,
  cdi_apos NUMERIC(8,4),
  retorno_cdi_apos NUMERIC(8,4),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Fluxos de caixa planejados (aportes/retiradas por período)
CREATE TABLE financial_cashflows (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  scenario_id UUID REFERENCES financial_scenarios(id) ON DELETE CASCADE,
  tipo TEXT CHECK (tipo IN ('mensal', 'anual')),
  idade_inicial INTEGER,
  idade_final INTEGER,
  mes INTEGER,  -- só para tipo anual
  aporte NUMERIC(15,2) DEFAULT 0,
  retirada NUMERIC(15,2) DEFAULT 0,
  observacao TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- RLS Policies
ALTER TABLE financial_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE financial_scenarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE financial_cashflows ENABLE ROW LEVEL SECURITY;

-- Policies básicas (ajustar conforme necessidade)
CREATE POLICY "Usuários veem seus próprios planos"
  ON financial_plans FOR ALL
  USING (agent_id = (get_logged_user_id())::integer
         OR (SELECT role FROM users WHERE id = (get_logged_user_id())::integer) IN ('diretoria', 'lideranca'));
```

### Fase 2 — Motor de cálculos (financial-engine.js)

Arquivo separado `financial-engine.js`, incluído no `index.html` antes de `app.js`.

```javascript
// Funções puras — sem dependências externas

function calcularRetornoReal(cdiAnual, percentualCdi, inflacaoAnual) {
  const retornoBruto = (cdiAnual / 100) * (percentualCdi / 100);
  return ((1 + retornoBruto) / (1 + inflacaoAnual / 100) - 1) * 100;
}

function calcularProjecaoAnual(params, cenario, cashflows) {
  // Retorna array de objetos { ano, idade, recInicioAno, aporteTotal, retiradaTotal, 
  //                            rendimentoMensal, recFimAno }
  // Lógica: para cada ano, para cada mês:
  //   saldo = saldo * (1 + taxaMensal) + aporte - retirada
}

function calcularRetiradaPreservar(reserva, retornoRealAnual) {
  // Renda perpétua: saldo nunca diminui
  return reserva * (retornoRealAnual / 100) / 12;
}

function calcularRetiradaConsumir(reserva, retornoRealAnual, anosRestantes) {
  // Amortização: reserva chega a zero na expectativa de vida
  const taxaMensal = retornoRealAnual / 100 / 12;
  const n = anosRestantes * 12;
  if (taxaMensal === 0) return reserva / n;
  return reserva * taxaMensal / (1 - Math.pow(1 + taxaMensal, -n));
}

function calcularIndependenciaFinanceira(reserva, retornoRealAnual, retiradaMensalDesejada) {
  const rendimentoMensalPerpetuo = reserva * (retornoRealAnual / 100) / 12;
  return (rendimentoMensalPerpetuo / retiradaMensalDesejada) * 100;
}
```

### Fase 3 — HTML (index.html)

#### 3a. Link no sidebar (após o item "financial"):
```html
<a class="sidebar-link flex items-center gap-3 px-4 py-3 rounded-xl cursor-pointer
          text-slate-400 hover:bg-white/5 hover:text-white transition-all duration-200"
   data-target="planejamentos">
  <svg><!-- ícone de gráfico/chart --></svg>
  <span class="text-sm font-medium">Planejamentos</span>
</a>
```

#### 3b. View container (após as outras views):
```html
<div id="view-planejamentos" class="view hidden space-y-6">
  <!-- renderizado por renderPlanejamentos() -->
</div>
```

#### 3c. Botão no card do lead fechado:
- Adicionar botão "Planejamento" dentro do template de lead card quando `lead.status === 'fechado'`

#### 3d. Modal fullscreen do planejamento:
- Stepper com 5 abas
- Cada aba com seu formulário
- Botões Anterior / Próximo / Salvar / Exportar PDF

### Fase 4 — CSS (styles.css)

Adicionar estilos para:
- `.planning-stepper` — barra de progresso das abas
- `.planning-tab` — aba inativa
- `.planning-tab.active` — aba ativa
- `.scenario-card` — card de cada cenário
- `.scenario-card.selected` — cenário selecionado
- `.chart-container` — wrapper dos gráficos
- `.projection-table` — tabela de evolução (números com mono font)
- `.pdf-template` — template oculto para geração do PDF
- `.independence-bar` — barra de progresso de independência financeira

### Fase 5 — app.js

Novas funções a adicionar:

```javascript
// Render da seção principal
function renderPlanejamentos()

// CRUD de planos
function openPlanejamentoModal(clientCode = null, planId = null)
function savePlanejamento(event)
function deletePlanejamento(planId)

// CRUD de cenários
function addCenario(planId)
function editCenario(scenarioId)
function deleteCenario(scenarioId)

// Cashflows
function addCashflow(scenarioId, tipo)
function deleteCashflow(cashflowId)

// Cálculo e render dos gráficos
function renderGraficoDiagnostico(canvasId, cenarios, params)
function renderGraficoEvolucao(canvasId, projecao)
function renderGraficoComparacao(canvasId, cenarios, params)

// Tabelas
function renderTabelaEvolucao(containerId, projecao)
function renderTabelaComparacao(containerId, cenarios, params)

// PDF
function exportarPDF(planId)

// Supabase sync
async function loadFinancialPlans()
async function saveFinancialPlan(plan)
async function saveFinancialScenario(scenario)
async function saveFinancialCashflow(cashflow)
```

### Fase 6 — Gráficos (Chart.js)

CDN a adicionar no `index.html`:
```html
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-annotation@3.0.1/dist/chartjs-plugin-annotation.min.js"></script>
```

Configurações dos gráficos:
- Tema escuro (`color: '#94a3b8'`, grid `rgba(255,255,255,0.05)`)
- Linha suave (`tension: 0.4`)
- Tooltips formatados em BRL
- Responsive: `true`, `maintainAspectRatio: false`

### Fase 7 — PDF (html2pdf.js)

CDN a adicionar:
```html
<script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
```

Template HTML (div oculta `#pdf-template`) com:
- Mesma estrutura visual do PDF analisado
- Fundo teal na capa e cabeçalhos
- Logo Spark (assets/spark-logo.webp)
- Tabelas com o mesmo layout
- Canvas para os gráficos (renderizados antes de gerar o PDF)

Configuração html2pdf:
```javascript
const opt = {
  margin: 0,
  filename: `planejamento-${clientName}-${data}.pdf`,
  image: { type: 'jpeg', quality: 0.98 },
  html2canvas: { scale: 2, useCORS: true },
  jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' }
};
```

---

## 6. FÓRMULAS DE CÁLCULO

### Retorno Real
```
retornoRealAnual = ((1 + CDI * %CDI/100) / (1 + inflacao/100) - 1) * 100
taxaMensalReal = (1 + retornoRealAnual/100)^(1/12) - 1
```

### Projeção ano a ano
Para cada mês no período:
```
rendimentoMes = saldoInicio * taxaMensalReal
saldoFim = saldoInicio + aporteMes - retiradaMes + rendimentoMes
           + aportesAnuais[mes] - retiradaAnuais[mes]
```

### Retirada máxima — Preservar reserva (renda perpétua)
```
retiradaMensal = reserva * taxaMensalReal
```

### Retirada máxima — Consumir reserva
```
retiradaMensal = reserva * i / (1 - (1+i)^-n)
onde: i = taxaMensalReal, n = (expectativaVida - idadeAposentadoria) * 12
```

### Independência Financeira
```
IF% = (reserva * taxaMensalReal) / retiradaMensalDesejada * 100
```

---

## 7. ORDEM DE EXECUÇÃO DOS ARQUIVOS

1. `financial-schema.sql` → rodar no Supabase SQL Editor
2. `financial-engine.js` → novo arquivo, incluir em index.html
3. `index.html` → adicionar CDNs, sidebar link, view, modal
4. `styles.css` → adicionar estilos do módulo
5. `app.js` → adicionar todas as funções do módulo

---

## 8. ESTADO ATUAL DA IMPLEMENTAÇÃO

- [x] Análise da plataforma legada (fin-tracks.com)
- [x] Análise do PDF gerado (12 páginas mapeadas)
- [x] Análise do CRM existente (stack, design, schema, padrões)
- [x] Plano de implementação documentado
- [x] Schema SQL (financial-schema.sql) — 3 tabelas + RLS + índices
- [x] Motor de cálculos (financial-engine.js) — funções puras, todas as fórmulas
- [x] HTML (index.html) — sidebar link, view, modal stepper 5 abas, CDNs
- [x] CSS (styles.css) — todos os componentes visuais do módulo
- [x] Lógica principal (app.js) — CRUD Supabase, render functions, cenários, cashflows
- [x] Gráficos (Chart.js) — diagnóstico, evolução, comparação
- [x] PDF (html2pdf.js) — template completo 6 páginas + geração automática

## 9. PRÓXIMOS PASSOS

1. **Rodar o schema SQL** no Supabase SQL Editor (`financial-schema.sql`)
2. **Testar** no browser: abrir index.html, clicar em "Planejamentos" na sidebar
3. **Criar um plano** com pelo menos 1 cenário e testar o cálculo
4. **Validar o PDF** exportado com o cliente real
5. **Ajustes de UX** após feedback visual

---

## 9. REFERÊNCIAS

- **CRM:** `G:\Meu Drive\_TRABALHO\SAFRA\crm-safra\`
- **Plataforma legada:** `https://www.app.fin-tracks.com`
- **Capturas de tela:** `G:\Meu Drive\_TRABALHO\fintrack\screenshots\`
- **PDF exportado:** `G:\Meu Drive\_TRABALHO\fintrack\screenshots\relatorio.pdf`
- **PDF em imagens:** `G:\Meu Drive\_TRABALHO\fintrack\screenshots\pdf_pages\`
- **Credenciais fin-tracks:** arquivo `G:\Meu Drive\_TRABALHO\fintrack\login`
