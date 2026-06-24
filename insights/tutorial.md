# Tutorial: Como Criar um CRM e Dashboard com HTML, Supabase e GitHub Pages

> Este tutorial documenta a criação do Spark CRM — um sistema completo de gestão comercial com funil de vendas, pipeline, motor de rateios de comissões, painel executivo e autenticação via Supabase Auth. Qualquer pessoa com conhecimentos básicos de programação consegue replicar seguindo estes passos.

---

## Stack Tecnológica

| Camada | Tecnologia | Por quê |
|---|---|---|
| Interface | HTML + JavaScript (vanilla) | Sem build system, abre no browser direto |
| Estilo | Tailwind CSS (CDN) | Utilitários prontos, sem configuração |
| Dados locais | localStorage (JSON) | Funciona offline, zero infraestrutura |
| Banco de dados | Supabase (PostgreSQL) | Gratuito, tem Auth embutido, API REST automática |
| Autenticação | Supabase Auth | Login, reset de senha por e-mail, sessão |
| Hospedagem | GitHub Pages | Gratuito, deploy automático via git push |
| E-mail transacional | Gmail SMTP (via Supabase) | Gratuito para volume baixo (<500/dia) |

---

## Parte 1 — Estrutura do Projeto

### 1.1 Crie a pasta e os arquivos base

```
meu-crm/
├── index.html       ← toda a UI (uma única página)
├── app.js           ← toda a lógica
├── mock-data.js     ← dados iniciais / estrutura do banco
├── styles.css       ← estilos customizados além do Tailwind
├── config.js        ← credenciais Supabase (commitável — chave pública)
├── supabase-schema.sql  ← script SQL para criar tabelas no Supabase
├── .gitignore
└── assets/
    └── logo.png
```

### 1.2 .gitignore mínimo

```
supabase.md
pendencias
*.local.js
```

---

## Parte 2 — index.html: estrutura da página única (SPA)

O app inteiro roda em um único `index.html`. Cada "tela" é uma `div` com classe `app-view` que fica oculta até ser ativada.

### 2.1 Cabeçalho com Tailwind e Supabase via CDN

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Spark CRM</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="styles.css">
</head>
<body class="bg-[#040711] text-white min-h-screen">
    <!-- conteúdo -->

    <!-- Scripts: ordem importa -->
    <script src="config.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
    <script src="mock-data.js"></script>
    <script src="app.js"></script>
</body>
</html>
```

> **Atenção à ordem dos scripts:** `config.js` antes do Supabase CDN, `mock-data.js` antes de `app.js`.

### 2.2 Tela de login

```html
<div id="login-container" class="fixed inset-0 z-50 flex items-center justify-center bg-[#040711]">
    <div class="login-card w-full max-w-sm bg-zinc-900 border border-zinc-700 rounded-2xl p-8 space-y-4">
        <img src="assets/logo.png" class="h-10 mx-auto">
        <form onsubmit="attemptLogin(event)" class="space-y-3">
            <label class="text-zinc-400 text-sm">Usuário ou E-mail</label>
            <input id="login-username" type="text" placeholder="usuário ou e-mail"
                class="w-full bg-zinc-800 text-white rounded-lg px-3 py-2 text-sm border border-zinc-600">
            <input id="login-password" type="password" placeholder="senha"
                class="w-full bg-zinc-800 text-white rounded-lg px-3 py-2 text-sm border border-zinc-600">
            <p id="login-error-msg" class="text-rose-400 text-sm hidden">Usuário ou senha incorretos.</p>
            <button type="submit" class="w-full bg-emerald-600 hover:bg-emerald-500 text-white rounded-lg py-2 font-semibold">
                Entrar
            </button>
            <button type="button" onclick="requestPasswordReset()"
                class="text-xs text-zinc-400 hover:text-zinc-200 underline w-full text-center mt-1">
                Esqueci minha senha
            </button>
        </form>
    </div>
</div>
```

### 2.3 Layout principal (sidebar + conteúdo)

```html
<div id="main-app" class="hidden flex h-screen">
    <!-- Sidebar -->
    <aside class="w-56 bg-zinc-900 border-r border-zinc-800 flex flex-col p-4 space-y-2">
        <div id="sidebar-user-info" class="mb-4"></div>
        <nav id="sidebar-nav"></nav>
        <button onclick="logoutUser(event)" class="mt-auto text-rose-400 text-sm">Sair da conta</button>
    </aside>

    <!-- Área de conteúdo -->
    <main class="flex-1 overflow-y-auto p-6">
        <div id="view-dashboard" class="app-view hidden">...</div>
        <div id="view-leads"     class="app-view hidden">...</div>
        <div id="view-pipeline"  class="app-view hidden">...</div>
        <div id="view-users"     class="app-view hidden">...</div>
        <div id="view-settings"  class="app-view hidden">...</div>
        <!-- adicione quantas views precisar -->
    </main>
</div>
```

### 2.4 Overlay de reset de senha

Cole antes de `</body>`, fora de qualquer outro container:

```html
<div id="reset-password-container"
    class="fixed inset-0 z-[9999] flex items-center justify-center bg-black/90 hidden">
    <div class="bg-zinc-900 border border-zinc-700 rounded-xl p-8 w-full max-w-sm space-y-4">
        <h2 class="text-white text-lg font-semibold">Nova Senha</h2>
        <div id="reset-password-error" class="text-rose-400 text-sm hidden"></div>
        <form onsubmit="updateOwnPassword(event)" class="space-y-3">
            <input type="password" id="reset-password-input" required placeholder="mínimo 6 caracteres"
                class="w-full bg-zinc-800 text-white rounded-lg px-3 py-2 text-sm border border-zinc-600">
            <input type="password" id="reset-password-confirm" required placeholder="repita a nova senha"
                class="w-full bg-zinc-800 text-white rounded-lg px-3 py-2 text-sm border border-zinc-600">
            <button type="submit"
                class="w-full bg-emerald-600 hover:bg-emerald-500 text-white rounded-lg py-2 font-semibold">
                Salvar Nova Senha
            </button>
        </form>
    </div>
</div>
```

---

## Parte 3 — mock-data.js: estrutura de dados

Este arquivo define a estrutura do banco e os dados iniciais. Em modo local, é a "fonte da verdade". Em modo cloud, serve de template para as tabelas do Supabase.

```js
const INITIAL_DB = {
    users: [
        {
            id: 1,
            name: "Filipe Rosa",
            email: "filipe@empresa.com.br",
            username: "filipe.rosa",
            password: "",          // vazio: autenticação via Supabase Auth
            role: "diretoria",     // diretoria | lideranca | agente
            cargo: "Gestor",
            unidade: "Porto Alegre",
            parentId: null,
            status: "active"
        }
    ],
    leads: [],
    clients: [],
    products: [],
    stages: [
        { id: 1, name: "Prospecção", order: 1 },
        { id: 2, name: "Qualificação", order: 2 },
        { id: 3, name: "Proposta", order: 3 },
        { id: 4, name: "Fechado", order: 4, isClosed: true }
    ],
    aportes: [],
    faturamentoHistorico: [],
    logs: []
};
```

> **Dica:** nunca salve senhas em plaintext. O campo `password` pode existir para modo local de desenvolvimento, mas em produção deve estar vazio — a autenticação é delegada ao Supabase Auth.

---

## Parte 4 — app.js: lógica central

### 4.1 Variáveis globais

```js
let db = {};                  // banco de dados em memória
let supabaseClient = null;    // cliente Supabase (null em modo local)
let supabaseMode = 'LOCAL';   // 'LOCAL' | 'CLOUD'
let currentUserId = null;
let currentRole = null;
```

### 4.2 Inicialização (initApp)

```js
async function initApp() {
    // 1. Carrega dados do localStorage (ou mock-data como fallback)
    const stored = localStorage.getItem('meu_crm_datastore');
    db = stored ? JSON.parse(stored) : JSON.parse(JSON.stringify(INITIAL_DB));

    // 2. Inicializa Supabase se credenciais disponíveis
    const supaUrl = localStorage.getItem('crm_supabase_url')
        || (typeof SPARK_CONFIG !== 'undefined' ? SPARK_CONFIG.supabaseUrl : '');
    const supaKey = localStorage.getItem('crm_supabase_key')
        || (typeof SPARK_CONFIG !== 'undefined' ? SPARK_CONFIG.supabaseKey : '');

    if (supaUrl && supaKey) {
        supabaseClient = supabase.createClient(supaUrl, supaKey);
        supabaseMode = 'CLOUD';

        // Detecta quando usuário clicou no link de reset de senha
        supabaseClient.auth.onAuthStateChange((event) => {
            if (event === 'PASSWORD_RECOVERY') showPasswordResetScreen();
        });

        // Carrega dados da nuvem
        await loadDataStoreFromCloud();
    }

    // 3. Verifica sessão
    let loggedUserId = sessionStorage.getItem('crm_logged_user_id');

    // Fallback: restaura sessão do Supabase Auth após reload
    if (!loggedUserId && supabaseMode === 'CLOUD' && supabaseClient) {
        const { data: { session } } = await supabaseClient.auth.getSession();
        if (session?.user?.email) {
            const found = db.users.find(u =>
                u.email?.toLowerCase() === session.user.email.toLowerCase());
            if (found) {
                loggedUserId = String(found.id);
                sessionStorage.setItem('crm_logged_user_id', loggedUserId);
            }
        }
    }

    // 4. Redireciona para login ou carrega app
    if (!loggedUserId) {
        showLoginScreen();
        return;
    }

    const user = db.users.find(u => String(u.id) === loggedUserId);
    if (!user) { showLoginScreen(); return; }

    currentUserId = user.id;
    currentRole = user.role;

    // 5. Renderiza interface
    renderSidebar();
    switchView('dashboard');
    document.getElementById('main-app').classList.remove('hidden');
    document.getElementById('login-container').classList.add('hidden');
}

document.addEventListener('DOMContentLoaded', initApp);
```

### 4.3 Controle de views

```js
function switchView(viewId) {
    document.querySelectorAll('.app-view').forEach(v => v.classList.add('hidden'));
    const target = document.getElementById('view-' + viewId);
    if (target) target.classList.remove('hidden');

    // Atualiza link ativo na sidebar
    document.querySelectorAll('.sidebar-link').forEach(l => l.classList.remove('active'));
    const activeLink = document.querySelector(`[data-view="${viewId}"]`);
    if (activeLink) activeLink.classList.add('active');
}
window.switchView = switchView;
```

### 4.4 Persistência de dados

```js
function saveDataStore(data) {
    localStorage.setItem('meu_crm_datastore', JSON.stringify(data));
    if (supabaseMode === 'CLOUD' && supabaseClient) {
        syncToCloud(data); // upsert assíncrono, não bloqueia UI
    }
}

async function syncToCloud(data) {
    // Exemplo para uma tabela — repita para cada entidade
    if (data.leads?.length) {
        await supabaseClient.from('leads').upsert(data.leads, { onConflict: 'id' });
    }
}
```

### 4.5 Login com suporte a username e e-mail

```js
async function attemptLogin(event) {
    if (event) event.preventDefault();

    const input = document.getElementById('login-username').value.trim();
    const password = document.getElementById('login-password').value;
    const errorMsg = document.getElementById('login-error-msg');

    const showError = () => {
        errorMsg.classList.remove('hidden');
        document.querySelector('.login-card')?.classList.add('shake-card');
        setTimeout(() => document.querySelector('.login-card')?.classList.remove('shake-card'), 500);
    };

    if (supabaseMode === 'CLOUD' && supabaseClient) {
        let email = input;
        // Se digitou username (sem @), resolve o e-mail correspondente
        if (!input.includes('@')) {
            const norm = s => s.normalize("NFD").replace(/[̀-ͯ]/g, "").toLowerCase();
            const found = db.users.find(u => u.username && norm(u.username) === norm(input));
            if (!found?.email) { showError(); return; }
            email = found.email;
        }
        const { data, error } = await supabaseClient.auth.signInWithPassword({ email, password });
        if (error || !data.user) { showError(); return; }

        const dbUser = db.users.find(u => u.email?.toLowerCase() === data.user.email.toLowerCase());
        if (!dbUser) { showError(); return; }

        sessionStorage.setItem('crm_logged_user_id', String(dbUser.id));
        errorMsg.classList.add('hidden');
        initApp();
    } else {
        // Modo local (desenvolvimento)
        const norm = s => s.normalize("NFD").replace(/[̀-ͯ]/g, "").toLowerCase();
        const user = db.users.find(u =>
            u.username && norm(u.username) === norm(input) && u.password === password);
        if (user) {
            sessionStorage.setItem('crm_logged_user_id', String(user.id));
            initApp();
        } else {
            showError();
        }
    }
}
window.attemptLogin = attemptLogin;
```

### 4.6 Logout

```js
async function logoutUser(event) {
    if (event) event.preventDefault();
    if (!confirm("Deseja realmente sair?")) return;
    if (supabaseMode === 'CLOUD' && supabaseClient) {
        await supabaseClient.auth.signOut();
    }
    sessionStorage.removeItem('crm_logged_user_id');
    showLoginScreen();
}
window.logoutUser = logoutUser;
```

### 4.7 Funções de reset de senha

```js
// Login screen — "Esqueci minha senha"
async function requestPasswordReset() {
    const input = document.getElementById('login-username').value.trim();
    if (!input) { alert('Digite seu usuário ou e-mail primeiro.'); return; }

    let email = input;
    if (!input.includes('@')) {
        const found = db.users.find(u => u.username?.toLowerCase() === input.toLowerCase());
        if (!found?.email) { alert('Usuário não encontrado.'); return; }
        email = found.email;
    }

    const redirectTo = (typeof SPARK_CONFIG !== 'undefined' && SPARK_CONFIG.appUrl)
        ? SPARK_CONFIG.appUrl
        : window.location.origin + window.location.pathname;

    const { error } = await supabaseClient.auth.resetPasswordForEmail(email, { redirectTo });
    alert(error
        ? 'Erro: ' + (error.message || JSON.stringify(error))
        : `E-mail enviado para ${email}. Verifique sua caixa de entrada.`);
}

// Overlay de nova senha — após clicar no link do e-mail
async function updateOwnPassword(event) {
    event.preventDefault();
    const newPass = document.getElementById('reset-password-input').value;
    const confirm = document.getElementById('reset-password-confirm').value;
    const errorEl = document.getElementById('reset-password-error');

    if (newPass !== confirm) {
        errorEl.textContent = 'As senhas não coincidem.';
        errorEl.classList.remove('hidden');
        return;
    }
    const { error } = await supabaseClient.auth.updateUser({ password: newPass });
    if (error) {
        errorEl.textContent = 'Erro: ' + error.message;
        errorEl.classList.remove('hidden');
    } else {
        hidePasswordResetScreen();
        alert('Senha atualizada! Faça login com a nova senha.');
        showLoginScreen();
    }
}

function showPasswordResetScreen() {
    document.getElementById('reset-password-container')?.classList.remove('hidden');
    document.getElementById('reset-password-error')?.classList.add('hidden');
}
function hidePasswordResetScreen() {
    document.getElementById('reset-password-container')?.classList.add('hidden');
}

window.requestPasswordReset = requestPasswordReset;
window.updateOwnPassword = updateOwnPassword;
window.showPasswordResetScreen = showPasswordResetScreen;
window.hidePasswordResetScreen = hidePasswordResetScreen;
```

---

## Parte 5 — config.js

```js
// Chave anon/publishable é segura para commitar — segurança vem do RLS, não do sigilo da chave
const SPARK_CONFIG = {
    supabaseUrl: 'https://SEU-PROJETO.supabase.co',
    supabaseKey: 'sb_publishable_SUA_CHAVE_AQUI',
    appUrl: 'https://SEU-USUARIO.github.io/SEU-REPO/'
};
```

---

## Parte 6 — supabase-schema.sql

Execute no `Supabase → SQL Editor → New query`:

```sql
-- USERS
create table if not exists public.users (
    id          integer  primary key,
    name        text     not null,
    role        text     not null,   -- 'diretoria' | 'lideranca' | 'agente'
    cargo       text,
    email       text     unique,     -- deve coincidir com o e-mail no Supabase Auth
    unidade     text,
    "parentId"  integer  references public.users(id),
    username    text     unique,
    password    text,                -- não usado em produção (auth via Supabase)
    status      text     default 'active',
    auth_id     uuid     references auth.users(id) on delete set null
);

-- LEADS
create table if not exists public.leads (
    id          integer  primary key,
    name        text     not null,
    email       text,
    phone       text,
    "stageId"   integer,
    "assignedTo" integer references public.users(id),
    value       numeric(12,2),
    status      text     default 'active',
    "createdAt" timestamptz default now()
);

-- PRODUCTS
create table if not exists public.products (
    id          integer  primary key,
    name        text     not null,
    status      text     default 'active'
);

-- STAGES (funil)
create table if not exists public.stages (
    id          integer  primary key,
    name        text     not null,
    "order"     integer,
    "isClosed"  boolean  default false
);

-- APORTES (investimentos/comissões)
create table if not exists public.aportes (
    id          integer  primary key,
    "clientId"  integer,
    "productId" integer  references public.products(id),
    value       numeric(15,2),
    status      text     default 'pending',
    "createdAt" timestamptz default now()
);

-- Desabilitar RLS para fase inicial (ative depois com políticas adequadas)
alter table public.users             disable row level security;
alter table public.leads             disable row level security;
alter table public.products          disable row level security;
alter table public.stages            disable row level security;
alter table public.aportes           disable row level security;

-- Dar acesso à chave anon
grant all privileges on all tables in schema public to anon;
grant all privileges on all tables in schema public to authenticated;
```

---

## Parte 7 — Hospedagem no GitHub Pages

### 7.1 Criar repositório

1. Acesse [github.com](https://github.com) → **New repository**
2. Nome: `meu-crm` (público)
3. Não inicialize com README

### 7.2 Subir o projeto

```bash
cd minha-pasta-do-projeto
git init
git add .
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/SEU-USUARIO/meu-crm.git
git push -u origin main
```

### 7.3 Ativar GitHub Pages

1. No repositório → **Settings → Pages**
2. Source: **Deploy from a branch**
3. Branch: `main` / `/ (root)`
4. Clique **Save**

O app estará disponível em `https://SEU-USUARIO.github.io/meu-crm/` em 1-2 minutos.

### 7.4 Deploy contínuo

A partir daqui, qualquer `git push origin main` atualiza o app automaticamente em ~1 minuto.

---

## Parte 8 — Supabase: configuração inicial

### 8.1 Criar projeto

1. [app.supabase.com](https://app.supabase.com) → **New project**
2. Nome, senha do banco, região (South America - São Paulo)
3. Aguardar provisionamento (~2 min)

### 8.2 Pegar credenciais

`Project Settings → API`
- **Project URL** → vai para `config.js → supabaseUrl`
- **anon public key** → vai para `config.js → supabaseKey`

### 8.3 Executar schema SQL

`SQL Editor → New query` → cole o conteúdo de `supabase-schema.sql` → **Run**

### 8.4 Configurar Auth

`Authentication → URL Configuration`:
- **Site URL**: `https://SEU-USUARIO.github.io/meu-crm/`
- **Redirect URLs**: mesma URL acima

### 8.5 Criar usuários no Supabase Auth

`Authentication → Users → Add user → Create new user`

Para cada colaborador:
- E-mail igual ao cadastrado no campo `email` da tabela `users`
- Senha temporária para comunicar a ele

> O Supabase Auth e a tabela `users` são vinculados pelo e-mail. Mantenha-os sempre iguais.

### 8.6 Migrar dados locais para a nuvem

No próprio app (após conectar ao Supabase):
- Vá em **Configurações → Supabase → Migrar Dados Locais → Nuvem**

---

## Parte 9 — E-mail transacional (Gmail SMTP)

Para que os e-mails de reset de senha funcionem:

`Supabase → Project Settings → Auth → SMTP Settings`

1. Ative **"Enable Custom SMTP"**
2. Preencha:
   - **Host**: `smtp.gmail.com`
   - **Port**: `465`
   - **Username**: seu e-mail Gmail completo
   - **Password**: Senha de App (gere em `myaccount.google.com/apppasswords`)
   - **Sender email**: mesmo e-mail
3. Salve

### Personalizar o template do e-mail

`Authentication → Email Templates → Reset Password`

```html
<h2>Redefinição de senha</h2>
<p>Clique no link abaixo para criar uma nova senha:</p>
<a href="{{ .ConfirmationURL }}">Redefinir minha senha</a>
<p><small>Se não foi você, ignore este e-mail.</small></p>
```

> O token `{{ .ConfirmationURL }}` é obrigatório — é o link de reset.

---

## Parte 10 — Checklist de Go-Live

- [ ] `config.js` preenchido com URL e chave do Supabase
- [ ] Script tags em ordem correta no `index.html`
- [ ] Schema SQL executado no Supabase
- [ ] Site URL e Redirect URL configurados no Supabase Auth
- [ ] Usuários criados no Supabase Auth (um por colaborador)
- [ ] Dados locais migrados para a nuvem
- [ ] SMTP configurado e testado (e-mail de reset chega)
- [ ] Login testado com username e com e-mail
- [ ] Fluxo "Esqueci minha senha" testado de ponta a ponta
- [ ] App publicado no GitHub Pages e acessível

---

## Dicas e Armadilhas Comuns

### Ordem dos scripts importa
`config.js` deve vir antes do CDN do Supabase, e ambos antes do `app.js`. Caso contrário, `SPARK_CONFIG` será `undefined` quando `app.js` tentar lê-lo.

### Chave anon é pública por design
A chave `anon`/`publishable` do Supabase pode ser commitada no repositório. A segurança dos dados é garantida pelas **Row Level Security (RLS)** policies no banco, não pelo sigilo da chave.

### Nunca salve senhas em plaintext no código
Use `password: ""` nos dados de usuário. Em produção, a autenticação é 100% delegada ao Supabase Auth.

### Cada view deve ter um id único
Padrão: `view-nomedatela`. A função `switchView('nomedatela')` busca `#view-nomedatela`. Divs faltando fechamento (`</div>`) causam views invisíveis — inspecione o HTML se uma tela sumir.

### Reset de senha requer redirect URL configurado
Sem a URL correta em `Supabase → Authentication → URL Configuration`, os links de reset apontam para `localhost:3000` e não funcionam em produção.

### Gmail SMTP: use Senha de App, não sua senha normal
O Google bloqueia SMTP com senha comum. Vá em `myaccount.google.com/apppasswords`, gere uma senha de 16 caracteres e use ela no campo Password do Supabase.

### Limite do Gmail SMTP
500 e-mails/dia (Gmail pessoal) ou 2000/dia (Google Workspace). Para times maiores, use Resend com domínio verificado.

### Supabase Auth não permite criar usuários pelo browser
A função `admin.createUser()` requer service role key (nunca exposta no frontend). Para adicionar novos usuários: crie manualmente em `Supabase → Authentication → Users` e comunique a senha temporária.

---

## Evolução Sugerida

| Fase | O que fazer |
|---|---|
| MVP | HTML + localStorage + sem auth |
| Alpha | Supabase + migração de dados + GitHub Pages |
| Beta | Supabase Auth + reset de senha por e-mail |
| v1.0 | SMTP com domínio próprio + RLS policies + domínio customizado |
| v2.0 | Next.js ou SvelteKit se precisar de SSR / SEO |
