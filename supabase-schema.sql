-- ============================================================
-- SPARK CRM – Schema SQL para Supabase
-- ============================================================
-- Como executar:
--   Dashboard Supabase → SQL Editor → New query → Cole e execute
-- ============================================================


-- ─── USERS ──────────────────────────────────────────────────
create table if not exists public.users (
  id          integer       primary key,
  name        text          not null,
  role        text          not null,       -- 'diretoria' | 'lideranca' | 'agente'
  cargo       text,                         -- 'Gestor' | 'Assessor'
  email       text          unique,         -- must match Supabase Auth user email
  unidade     text,
  "parentId"  integer       references public.users(id),
  username    text          unique,
  password    text,                         -- unused in CLOUD mode (auth via Supabase)
  status      text          default 'active',
  auth_id     uuid          references auth.users(id) on delete set null
);


-- ─── PRODUCTS (fundos) ──────────────────────────────────────
create table if not exists public.products (
  id               integer  primary key,
  name             text     not null,
  "taxAdm"         numeric(8,4),
  "feeCap"         numeric(8,4),
  "splitStrivo"    integer,
  "splitLider"     integer,
  "splitAgente"    integer,
  cnpj             text,
  administrator    text,
  "investorType"   text,
  "performanceFee" text,
  benchmark        text,
  status           text     default 'active'
);


-- ─── STAGES (etapas do funil) ───────────────────────────────
create table if not exists public.stages (
  key          text    primary key,
  label        text    not null,
  "order"      integer,
  "colorClass" text
);


-- ─── LEADS ──────────────────────────────────────────────────
create table if not exists public.leads (
  id            integer   primary key,
  name          text      not null,
  phone         text,
  email         text,
  source        text,
  "extraInfo"   text,
  status        text,
  "productId"   integer   references public.products(id),
  "agentId"     integer   references public.users(id),
  "leaderId"    integer   references public.users(id),
  value         numeric(15,2),
  splits        jsonb     default '[]',
  "clientCode"  text,
  "createdDate" text,
  attachments   jsonb     default '[]',
  tasks         jsonb     default '[]'
);


-- ─── CLIENTS (carteira ativa) ────────────────────────────────
create table if not exists public.clients (
  code        text    primary key,
  name        text    not null,
  "agentId"   integer references public.users(id),
  "leaderId"  integer references public.users(id),
  "productId" integer references public.products(id)
);


-- ─── APORTES (solicitações de investimento) ─────────────────
create table if not exists public.aportes (
  id            integer   primary key,
  "clientName"  text,
  "productId"   integer   references public.products(id),
  "agentId"     integer   references public.users(id),
  "leaderId"    integer   references public.users(id),
  value         numeric(15,2),
  date          text,
  status        text,
  logs          jsonb     default '[]'
);


-- ─── FATURAMENTO HISTÓRICO ───────────────────────────────────
-- Chave composta (period + clientCode) para evitar duplicatas no upsert
create table if not exists public."faturamentoHistorico" (
  period          text     not null,
  "clientCode"    text     not null,
  "clientName"    text,
  value           numeric(12,2),
  "productId"     integer  references public.products(id),
  "processedDate" text,
  primary key (period, "clientCode")
);


-- ============================================================
-- PERMISSÕES (modo MVP – anon key sem Row Level Security)
-- ============================================================
-- A chave "sb_publishable" (anon) precisa de permissão explícita
-- para cada operação. RLS desativado para simplicidade inicial.
--
-- ⚠️  ATENÇÃO: qualquer pessoa com a chave pode ler e gravar.
--     Migrar para Supabase Auth + RLS antes de escalar o acesso.
-- ============================================================

alter table public.users                   disable row level security;
alter table public.products                disable row level security;
alter table public.stages                  disable row level security;
alter table public.leads                   disable row level security;
alter table public.clients                 disable row level security;
alter table public.aportes                 disable row level security;
alter table public."faturamentoHistorico"  disable row level security;

grant all privileges on public.users                   to anon;
grant all privileges on public.products                to anon;
grant all privileges on public.stages                  to anon;
grant all privileges on public.leads                   to anon;
grant all privileges on public.clients                 to anon;
grant all privileges on public.aportes                 to anon;
grant all privileges on public."faturamentoHistorico"  to anon;
