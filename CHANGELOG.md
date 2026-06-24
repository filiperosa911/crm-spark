# Changelog — CRM Spark

Histórico de alterações do projeto, em ordem cronológica inversa.

---

## 2026-06-24

### Corrigido
- **Seletor de clientes no planejamento**: leads em qualquer etapa do funil (proposta, análise etc.) agora aparecem como opção ao criar um planejamento. Antes, só leads com status `fechado` eram exibidos. (`71e9715`)

---

## 2026-06-23

### Corrigido
- **PDF — páginas em branco entre seções**: removido o modo `legacy` do html2pdf que fatiava o canvas independentemente do CSS, causando quebras duplicadas e páginas em branco. Adicionado `windowWidth: 794` para renderização precisa na largura A4. (`42dbe39`)
- **PDF — filtragem hierárquica**: assessores veem apenas seus próprios planejamentos; lideranças veem os da equipe; diretoria vê todos. Antes, todos os planos eram carregados sem filtro. (`f5fc86f`)
- **Erro ao salvar planejamento financeiro**: removido campo `data_simulacao` do payload (coluna não existe na tabela). RLS desabilitado nas tabelas financeiras para seguir o padrão do restante do CRM (acesso via chave anon). (`b38ce1d`)
- **Schema financeiro idempotente**: `financial-schema.sql` reescrito para poder ser executado múltiplas vezes sem erro (DROP IF EXISTS, verificação via `pg_constraint`). (`d4840e8`)

### Adicionado
- **Tutorial**: `tutorial.md` com guia completo de como o CRM foi construído do zero. (`f90b03a`)
- **Módulo de Planejamento Financeiro**: tela de planejamentos com criação de planos, cenários, fluxos de caixa, gráficos (Chart.js) e exportação em PDF (html2pdf). Tabelas `financial_plans`, `financial_scenarios`, `financial_cashflows` no Supabase. (`87cca78`)

---

## 2026-06-22 / 2026-06-23

### Adicionado
- **Supabase Auth — login por e-mail**: login aceita nome de usuário ou e-mail. Botão "Esqueci minha senha" na tela de login envia e-mail de redefinição via Supabase. (`1689548`)
- **Reset de senha por admin**: diretoria pode disparar e-mail de redefinição para qualquer usuário pela tela de Gestão de Usuários. (`1689548`)
- **Overlay de nova senha**: tela de redefinição de senha exibida automaticamente ao acessar o link do e-mail (`PASSWORD_RECOVERY`). (`1689548`)
- **Conexão automática ao Supabase**: `config.js` (gitignored) centraliza URL, chave anon e URL do app. Conexão estabelecida automaticamente sem configuração manual. (`3222554`)

### Segurança
- **Senhas removidas do código-fonte**: senhas em texto plano eliminadas do `localStorage` / código. Autenticação delegada ao Supabase Auth. (`21a11e2`)

---

## 2026-06-17

### Adicionado
- **Integração com Supabase**: migração dos dados do `localStorage` para banco Supabase (PostgreSQL). RLS com função `get_logged_user_id()`. (`e2f62eb`)
- **Tela de login**: login com vidro líquido (glassmorphism), gestão de sessão via `sessionStorage`. (`282daed`)
- **Rebrand para Spark**: nome e visual atualizados de Strivo para Spark. (`341e98e`)

### Corrigido
- **RLS — recursão infinita**: políticas de segurança reescritas com funções `SECURITY DEFINER` para evitar recursão na tabela `users`. (`bbf7fe9`)
- **Header `Accept-Language`**: ID do usuário logado transmitido via header para bypass de CORS no gateway Supabase. (`5e2db3f`)
- **Painel de configurações do Supabase**: movido para dentro do container correto da view de configurações. (`24d9e03`)
- **Link ativo no sidebar**: classe `active` sincronizada com a página exibida. (`351c431`)
- **Tema do login**: tema escuro glassmorphism mantido no login independente do tema ativo. (`ce6211c`)

---

## 2026-06-16

### Adicionado
- **Dados reais**: fundos, time comercial e dados do CRM importados. Menu de navegação atualizado. (`86fdaf3`)

---

## 2026-06-11

### Adicionado
- **Pipeline em 2 colunas**: visão do funil exibe pirâmide e pipeline do usuário lado a lado. (`910a1bf`)
- **Versão inicial**: plataforma Spark — cockpit de gestão comercial e CRM. (`1bb1d33`)

---

> Commits referenciados pelo hash abreviado do Git. Para ver o diff completo: `git show <hash>`
