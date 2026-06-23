-- ============================================================
-- MÓDULO DE PLANEJAMENTO FINANCEIRO — SCHEMA SUPABASE
-- Idempotente: pode ser rodado múltiplas vezes sem erro
-- ============================================================

-- ------------------------------------------------------------
-- 0. FUNÇÃO get_logged_user_id()
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_logged_user_id()
RETURNS BIGINT AS $$
BEGIN
    RETURN NULLIF(current_setting('request.headers', true)::json->>'accept-language', '')::bigint;
EXCEPTION
    WHEN OTHERS THEN RETURN NULL;
END;
$$ LANGUAGE plpgsql STABLE;

-- ------------------------------------------------------------
-- 1. PLANOS FINANCEIROS
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS financial_plans (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  client_code TEXT NOT NULL,
  client_name TEXT,
  agent_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
  leader_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
  cdi_anual          NUMERIC(8,4) DEFAULT 11.00,
  retorno_cdi        NUMERIC(8,4) DEFAULT 110.00,
  taxa_juros         NUMERIC(8,4) DEFAULT 12.10,
  inflacao_anual     NUMERIC(8,4) DEFAULT 5.82,
  retorno_anual_real NUMERIC(8,4) GENERATED ALWAYS AS (
    ROUND((((1 + (cdi_anual/100) * (retorno_cdi/100)) / (1 + inflacao_anual/100)) - 1) * 100, 4)
  ) STORED,
  exibir_capacidade_poupanca   BOOLEAN DEFAULT true,
  exibir_aportes_planejados    BOOLEAN DEFAULT true,
  exibir_grafico_diagnostico   BOOLEAN DEFAULT true,
  exibir_evolucao_reserva      BOOLEAN DEFAULT true,
  exibir_protecao_sugerida     BOOLEAN DEFAULT false,
  exibir_sucessao_vitalicia    BOOLEAN DEFAULT false,
  exibir_comparacao_cenarios   BOOLEAN DEFAULT true,
  exibir_comparacao_sem_tabela BOOLEAN DEFAULT false,
  formato_relatorio            TEXT DEFAULT 'completo' CHECK (formato_relatorio IN ('completo', 'resumido')),
  cenario_principal_id         UUID,
  consideracoes_finais         TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ------------------------------------------------------------
-- 2. CENÁRIOS
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS financial_scenarios (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  plan_id UUID NOT NULL REFERENCES financial_plans(id) ON DELETE CASCADE,
  nome       TEXT    DEFAULT 'Cenário 1',
  ordem      INTEGER DEFAULT 1,
  is_visible BOOLEAN DEFAULT true,
  cor        TEXT    DEFAULT '#008394',
  idade_inicial               INTEGER NOT NULL DEFAULT 30,
  vai_trabalhar_ate           INTEGER NOT NULL DEFAULT 65,
  expectativa_vida            INTEGER NOT NULL DEFAULT 90,
  receita_mensal              NUMERIC(15,2) DEFAULT 0,
  percentual_responsabilidade NUMERIC(5,2)  DEFAULT 100,
  reserva_inicial             NUMERIC(15,2) DEFAULT 0,
  aporte_mensal               NUMERIC(15,2) DEFAULT 0,
  retirada_mensal_apos        NUMERIC(15,2) DEFAULT 0,
  capacidade_poupanca_perc    NUMERIC(5,2)  DEFAULT 0,
  diferenciar_taxas_apos      BOOLEAN DEFAULT false,
  cdi_apos                    NUMERIC(8,4),
  retorno_cdi_apos            NUMERIC(8,4),
  anos_exibicao_evolucao      INTEGER DEFAULT 66,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- FK reversa (idempotente via verificação em pg_constraint)
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'fk_cenario_principal'
      AND conrelid = 'financial_plans'::regclass
  ) THEN
    ALTER TABLE financial_plans
      ADD CONSTRAINT fk_cenario_principal
      FOREIGN KEY (cenario_principal_id)
      REFERENCES financial_scenarios(id)
      ON DELETE SET NULL
      DEFERRABLE INITIALLY DEFERRED;
  END IF;
END $$;

-- ------------------------------------------------------------
-- 3. FLUXOS DE CAIXA
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS financial_cashflows (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  scenario_id UUID NOT NULL REFERENCES financial_scenarios(id) ON DELETE CASCADE,
  tipo          TEXT NOT NULL CHECK (tipo IN ('mensal', 'anual')),
  idade_inicial INTEGER NOT NULL,
  idade_final   INTEGER NOT NULL,
  mes           INTEGER CHECK (mes BETWEEN 1 AND 12),
  aporte        NUMERIC(15,2) DEFAULT 0,
  retirada      NUMERIC(15,2) DEFAULT 0,
  observacao    TEXT,
  created_at    TIMESTAMPTZ DEFAULT now(),
  CONSTRAINT cashflow_anual_tem_mes CHECK (tipo != 'anual' OR mes IS NOT NULL)
);

-- ------------------------------------------------------------
-- 4. ACESSO (sem RLS — padrão do restante do CRM)
-- O app usa chave anon com acesso direto, sem JWT de usuário.
-- Controle de acesso é feito pela lógica do app (sessionStorage).
-- ------------------------------------------------------------
ALTER TABLE financial_plans     DISABLE ROW LEVEL SECURITY;
ALTER TABLE financial_scenarios DISABLE ROW LEVEL SECURITY;
ALTER TABLE financial_cashflows DISABLE ROW LEVEL SECURITY;

-- Remove policies antigas caso existam de execução anterior
DROP POLICY IF EXISTS "financial_plans_select"   ON financial_plans;
DROP POLICY IF EXISTS "financial_plans_insert"   ON financial_plans;
DROP POLICY IF EXISTS "financial_plans_update"   ON financial_plans;
DROP POLICY IF EXISTS "financial_plans_delete"   ON financial_plans;
DROP POLICY IF EXISTS "financial_scenarios_all"  ON financial_scenarios;
DROP POLICY IF EXISTS "financial_cashflows_all"  ON financial_cashflows;

-- Garante acesso completo para a chave anon (mesmo padrão das outras tabelas)
GRANT ALL ON financial_plans, financial_scenarios, financial_cashflows TO anon;
GRANT ALL ON financial_plans, financial_scenarios, financial_cashflows TO authenticated;

-- ------------------------------------------------------------
-- 5. UPDATED_AT AUTOMÁTICO
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_financial_plans_updated_at ON financial_plans;
CREATE TRIGGER trg_financial_plans_updated_at
  BEFORE UPDATE ON financial_plans
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS trg_financial_scenarios_updated_at ON financial_scenarios;
CREATE TRIGGER trg_financial_scenarios_updated_at
  BEFORE UPDATE ON financial_scenarios
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ------------------------------------------------------------
-- 6. ÍNDICES
-- ------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_financial_plans_client_code  ON financial_plans(client_code);
CREATE INDEX IF NOT EXISTS idx_financial_plans_agent_id     ON financial_plans(agent_id);
CREATE INDEX IF NOT EXISTS idx_financial_scenarios_plan_id  ON financial_scenarios(plan_id);
CREATE INDEX IF NOT EXISTS idx_financial_cashflows_scenario ON financial_cashflows(scenario_id);

-- ------------------------------------------------------------
-- 7. COMENTÁRIOS
-- ------------------------------------------------------------
COMMENT ON TABLE financial_plans     IS 'Planos de planejamento financeiro de aposentadoria por cliente';
COMMENT ON TABLE financial_scenarios IS 'Cenários de simulação dentro de cada plano';
COMMENT ON TABLE financial_cashflows IS 'Aportes e retiradas planejados por faixa de idade em cada cenário';

COMMENT ON COLUMN financial_plans.retorno_anual_real       IS 'Calculado automaticamente: ((1 + CDI*%CDI) / (1 + inflacao)) - 1';
COMMENT ON COLUMN financial_scenarios.aporte_mensal        IS 'Aporte mensal padrão antes da aposentadoria';
COMMENT ON COLUMN financial_scenarios.retirada_mensal_apos IS 'Retirada mensal desejada após aposentadoria';
