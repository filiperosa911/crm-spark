---
name: supabase-static-integration
description: Guidelines and best practices for integrating static client-side web applications with Supabase (PostgreSQL), handling Row Level Security (RLS) without full Supabase Auth, preventing infinite recursion in PostgreSQL policies, sanitizing connection URLs, and managing UI state sync. Use this skill whenever building or debugging Supabase integrations, writing PostgreSQL policies, or designing database schemas for client-side applications.
---

# Supabase Static Integration Guide & Best Practices

## Resumo de Como Usar / How to Use
Este guia serve como uma "Skill" (bula de instruções) para que agentes de IA e desenvolvedores configurem de forma robusta a conexão entre aplicações estáticas (frontend-only) e o Supabase. Sempre que iniciar um novo projeto com Supabase ou estiver depurando erros de RLS (Row Level Security), siga esta bula para garantir:
1. **Sanitização de URLs:** Impede erros `404` ou de caminhos duplicados (`/rest/v1//rest/v1/...`).
2. **Autenticação RLS Simples (Sem Supabase Auth):** Uso de cabeçalhos CORS-safelisted (`Accept-Language`) para passar sessões locais de forma imune a bloqueios de proxies e gateways.
3. **Prevenção de Recursão Infinita:** Estruturação correta das políticas PostgreSQL usando funções `SECURITY DEFINER` e separando regras de escrita (`INSERT/UPDATE/DELETE`) da regra de leitura (`SELECT`).
4. **Bootstrapping Seguro:** Evitar o problema do "ovo e da galinha" em tabelas vazias com políticas RLS ativas.
5. **Consistência de Interface (UI):** Garantir que a UI reflita o estado real do banco no caso de erros assíncronos de conexão.

---

## 1. Sanitização de URLs de Entrada
Ao coletar a URL do Supabase fornecida pelo usuário, é comum que ele copie a URL completa da Data API (que contém `/rest/v1/` ao final) ou insira barras no final. O SDK do Supabase adiciona o sufixo `/rest/v1` internamente, o que gera caminhos duplicados e o erro `Invalid path specified in request URL` do PostgREST.

### 💡 Solução no Frontend:
Sempre sanitize a string da URL antes de salvar no `localStorage` ou instanciar o cliente:
```javascript
function sanitizeSupabaseUrl(url) {
    return url
        .trim()
        .replace(/\/$/, "")            // Remove barras no final
        .replace(/\/rest\/v1\/?$/, "") // Remove o sufixo da API rest
        .trim();
}
```

---

## 2. Autenticação RLS sem Supabase Auth (CORS-Safelisted Header)
Se a aplicação usa um sistema de login próprio (armazenado em banco local/sessionStorage) e não o Supabase Auth, o cliente se conecta de forma anônima (`anon key`). Para aplicar políticas de RLS baseadas na hierarquia do usuário, precisamos passar o ID do usuário conectado para o banco de dados.

* **O Problema:** Cabeçalhos personalizados (como `x-logged-user-id`) são frequentemente bloqueados por CORS ou limpos pelo API Gateway (Kong) do Supabase antes de chegarem ao PostgREST.
* **A Solução:** Enviar o ID no cabeçalho padrão **`Accept-Language`**, que é classificado como *CORS-safelisted* e passa intacto por qualquer barreira de proxy do navegador ou servidor.

### 💡 Configuração no Javascript:
```javascript
const loggedUserId = sessionStorage.getItem('strivo_logged_user_id');
const options = {};
if (loggedUserId) {
    options.global = {
        headers: {
            'Accept-Language': loggedUserId.toString()
        }
    };
}
const supabaseClient = window.supabase.createClient(supaUrl, supaKey, options);
```

### 💡 Funções Auxiliares no PostgreSQL (`SECURITY DEFINER`):
Para ler o cabeçalho no banco de dados e obter o perfil do usuário logado de forma limpa:
```sql
-- Obter o ID do usuário enviado via Accept-Language
CREATE OR REPLACE FUNCTION get_logged_user_id()
RETURNS BIGINT AS $$
BEGIN
    RETURN NULLIF(current_setting('request.headers', true)::json->>'accept-language', '')::bigint;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Obter a role do usuário (executa com privilégios de owner para ignorar RLS e evitar loops)
CREATE OR REPLACE FUNCTION get_logged_user_role()
RETURNS TEXT AS $$
DECLARE
    v_role TEXT;
    v_user_id BIGINT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## 3. Prevenindo Recursão Infinita em Políticas RLS
Criar políticas do tipo `FOR ALL` que fazem subconsultas na própria tabela da política (`SELECT 1 FROM users WHERE...`) faz com que o PostgreSQL aplique a política a si mesma recursivamente durante o planejamento da query, disparando o erro: `infinite recursion detected in policy for relation "users"`.

### 💡 Solução no PostgreSQL:
1. **Regra de Leitura (`SELECT`) Simples:** Defina uma política para `SELECT` limpa, que não execute consultas recursivas (ex: `USING (true)`).
2. **Separação de Escritas:** Crie regras específicas `FOR INSERT WITH CHECK (...)`, `FOR UPDATE USING (...)` e `FOR DELETE USING (...)`. Como o `SELECT` da subconsulta não aciona mais a regra de escrita, a recursão é quebrada.
3. **Mapeamento Prático (Exemplo):**
```sql
-- Permite leitura de usuários a todos
CREATE POLICY "Leitura pública de usuários" ON "users" FOR SELECT USING (true);

-- Gravação restrita usando a função SECURITY DEFINER
CREATE POLICY "Apenas diretoria altera usuários" ON "users" FOR INSERT WITH CHECK (
    get_logged_user_role() = 'diretoria'
);
CREATE POLICY "Edição por diretoria" ON "users" FOR UPDATE USING (
    get_logged_user_role() = 'diretoria'
);
```

---

## 4. Resolução do Problema "Ovo e Galinha" (Tabelas Vazias)
Se a política de `INSERT` na tabela `users` exige que o usuário criador já exista no banco de dados e possua uma role (ex: `get_logged_user_role() = 'diretoria'`), você nunca conseguirá inserir o primeiro usuário (o banco estará vazio e o ID de sessão não existirá).

### 💡 Solução no PostgreSQL:
Adicione um fallback para permitir inserções caso a tabela esteja totalmente vazia (útil para o processo de migração inicial):
```sql
CREATE POLICY "Inserção inicial ou diretoria em users" ON "users" 
FOR INSERT WITH CHECK (
    (NOT EXISTS (SELECT 1 FROM "users")) -- Permite se a tabela estiver vazia
    OR 
    get_logged_user_role() = 'diretoria' -- Caso contrário, exige role diretoria
);
```

---

## 5. Sincronização e Estados de UI Robustos
Em requisições assíncronas em lote (como uma migração de base de dados), a aplicação pode alterar o estado visual da tela para "Online" antes que a conexão seja validada de fato. Se houver falha na leitura dos dados da nuvem, a variável em memória é revertida para `LOCAL` (offline), mas a interface pode mentir para o usuário mostrando "Online".

### 💡 Solução no Código de Interface:
Sempre atualize ou resete a UI dentro do bloco `catch` dos métodos de inicialização ou salvamento de conexões assíncronas:
```javascript
try {
    supabaseClient = window.supabase.createClient(supaUrl, supaKey, options);
    supabaseMode = 'CLOUD';
    updateBadge("Modo Nuvem (Online)", "bg-emerald-500");
    await loadDataStoreFromCloud(); // Tenta carregar
} catch (err) {
    console.error("Conexão falhou, revertendo...", err);
    supabaseMode = 'LOCAL';
    // Garanta o reset visual
    updateBadge("Erro de Conexão (Offline)", "bg-rose-500");
    disableSyncButtons();
}
```

### 💡 Sincronização de Menus de Navegação:
Evite que botões fiquem com a marcação visual ativa (`.active`) de forma desalinhada ao trocar de tela programaticamente. Faça a atualização da classe `.active` ser centralizada dentro do próprio método de transição de tela (`switchView`):
```javascript
function switchView(viewId) {
    // Esconde/mostra elementos
    document.querySelectorAll('.app-view').forEach(view => view.classList.add('hidden'));
    document.getElementById(`view-${viewId}`).classList.remove('hidden');

    // Sincroniza visualmente os links da barra lateral
    document.querySelectorAll('.sidebar-link').forEach(link => {
        if (link.getAttribute('data-target') === viewId) {
            link.classList.add('active');
        } else {
            if (link.getAttribute('onclick') && link.getAttribute('onclick').includes('logoutUser')) return;
            link.classList.remove('active');
        }
    });
}
```
