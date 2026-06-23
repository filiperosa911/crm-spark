// ============================================================
// MOTOR DE CÁLCULOS FINANCEIROS — Planejamento de Aposentadoria
// Funções puras, sem dependências externas.
// ============================================================

const FinancialEngine = (() => {

  // ----------------------------------------------------------
  // TAXAS
  // ----------------------------------------------------------

  function calcularRetornoRealAnual(cdiAnual, percentualCdi, inflacaoAnual) {
    const retornoBruto = (cdiAnual / 100) * (percentualCdi / 100);
    return ((1 + retornoBruto) / (1 + inflacaoAnual / 100) - 1) * 100;
  }

  function calcularTaxaMensalReal(retornoRealAnual) {
    return Math.pow(1 + retornoRealAnual / 100, 1 / 12) - 1;
  }

  // ----------------------------------------------------------
  // CASHFLOW HELPERS
  // Retorna aporte e retirada extras para uma idade+mês dados
  // ----------------------------------------------------------

  function getCashflowParaIdadeMes(cashflows, idade, mesNoAno) {
    let aporteExtra = 0;
    let retiradaExtra = 0;

    for (const cf of cashflows) {
      if (idade < cf.idade_inicial || idade > cf.idade_final) continue;

      if (cf.tipo === 'mensal') {
        aporteExtra  += Number(cf.aporte  || 0);
        retiradaExtra += Number(cf.retirada || 0);
      } else if (cf.tipo === 'anual' && cf.mes === mesNoAno) {
        aporteExtra  += Number(cf.aporte  || 0);
        retiradaExtra += Number(cf.retirada || 0);
      }
    }

    return { aporteExtra, retiradaExtra };
  }

  // ----------------------------------------------------------
  // PROJEÇÃO ANO A ANO
  // Retorna array de registros anuais para a tabela e gráficos
  // ----------------------------------------------------------

  function calcularProjecao(params, cenario, cashflows = []) {
    const {
      cdiAnual      = 11,
      percentualCdi = 110,
      inflacaoAnual = 5.82,
    } = params;

    const {
      idade_inicial          = 30,
      vai_trabalhar_ate      = 65,
      expectativa_vida       = 90,
      reserva_inicial        = 0,
      aporte_mensal          = 0,
      retirada_mensal_apos   = 0,
      diferenciar_taxas_apos = false,
      cdi_apos               = null,
      retorno_cdi_apos       = null,
    } = cenario;

    // Taxa de acumulação
    const retornoRealAcum = calcularRetornoRealAnual(cdiAnual, percentualCdi, inflacaoAnual);
    const taxaMensalAcum  = calcularTaxaMensalReal(retornoRealAcum);

    // Taxa de retirada (pode ser diferente)
    const retornoRealRet  = diferenciar_taxas_apos && cdi_apos && retorno_cdi_apos
      ? calcularRetornoRealAnual(cdi_apos, retorno_cdi_apos, inflacaoAnual)
      : retornoRealAcum;
    const taxaMensalRet   = calcularTaxaMensalReal(retornoRealRet);

    const anoInicio = new Date().getFullYear() - (new Date().getFullYear() - (new Date().getFullYear() + (idade_inicial - idade_inicial)));
    // Calculamos baseado na idade e ano atual
    const anoAtual = new Date().getFullYear();
    const anoNascimento = anoAtual - idade_inicial;

    const resultado = [];
    let saldo = Number(reserva_inicial || 0);

    for (let idade = idade_inicial; idade <= expectativa_vida; idade++) {
      const ano         = anoNascimento + idade;
      const aposentado  = idade >= vai_trabalhar_ate;
      const taxaMensal  = aposentado ? taxaMensalRet : taxaMensalAcum;

      const recInicioAno = saldo;
      let aporteAnualTotal   = 0;
      let retiradaAnualTotal = 0;
      let rendimentoAnualTotal = 0;

      for (let mes = 1; mes <= 12; mes++) {
        const rendimentoMes = saldo * taxaMensal;
        const aportePadrao  = aposentado ? 0 : Number(aporte_mensal || 0);
        const retiradaPadrao = aposentado ? Number(retirada_mensal_apos || 0) : 0;

        const { aporteExtra, retiradaExtra } = getCashflowParaIdadeMes(cashflows, idade, mes);

        const aporteTotal   = aportePadrao  + aporteExtra;
        const retiradaTotal = retiradaPadrao + retiradaExtra;

        saldo = saldo + rendimentoMes + aporteTotal - retiradaTotal;
        if (saldo < 0) saldo = 0;

        aporteAnualTotal    += aporteTotal;
        retiradaAnualTotal  += retiradaTotal;
        rendimentoAnualTotal += rendimentoMes;
      }

      resultado.push({
        ano,
        idade,
        aposentado,
        recInicioAno,
        aporteAnual:      aporteAnualTotal,
        retiradaAnual:    retiradaAnualTotal,
        rendimentoAnual:  rendimentoAnualTotal,
        recFimAno:        saldo,
        // Para tabela mensal (simplificado — valores anuais / 12)
        aporteMensal:     aporteAnualTotal / 12,
        retiradaMensal:   retiradaAnualTotal / 12,
        rendimentoMensal: rendimentoAnualTotal / 12,
      });
    }

    return resultado;
  }

  // ----------------------------------------------------------
  // INDICADORES CHAVE
  // ----------------------------------------------------------

  function calcularIndicadores(params, cenario, cashflows = []) {
    const projecao = calcularProjecao(params, cenario, cashflows);

    const { vai_trabalhar_ate, expectativa_vida, retirada_mensal_apos } = cenario;
    const { inflacaoAnual, cdiAnual, percentualCdi } = params;

    // Reserva no início da aposentadoria
    const linhaAposentadoria = projecao.find(r => r.idade === vai_trabalhar_ate);
    const reservaAposentadoria = linhaAposentadoria ? linhaAposentadoria.recInicioAno : 0;

    // Reserva final (expectativa de vida)
    const linhaFinal = projecao[projecao.length - 1];
    const reservaFinal = linhaFinal ? linhaFinal.recFimAno : 0;

    // Taxa mensal na aposentadoria
    const retornoRealAnual = calcularRetornoRealAnual(
      cenario.diferenciar_taxas_apos && cenario.cdi_apos ? cenario.cdi_apos : cdiAnual,
      cenario.diferenciar_taxas_apos && cenario.retorno_cdi_apos ? cenario.retorno_cdi_apos : percentualCdi,
      inflacaoAnual
    );
    const taxaMensalRet = calcularTaxaMensalReal(retornoRealAnual);

    // Retirada máxima — preservar reserva (renda perpétua)
    const retiradaPreservar = reservaAposentadoria * taxaMensalRet;

    // Retirada máxima — consumir reserva até expectativa de vida
    const anosRetirada = expectativa_vida - vai_trabalhar_ate;
    const n = anosRetirada * 12;
    const retiradaConsumir = taxaMensalRet === 0
      ? reservaAposentadoria / n
      : reservaAposentadoria * taxaMensalRet / (1 - Math.pow(1 + taxaMensalRet, -n));

    // Retirada desejada (valor real)
    const retiradaDesejada = Number(retirada_mensal_apos || 0);

    // Independência Financeira %
    const independenciaFinanceira = retiradaDesejada > 0
      ? (retiradaPreservar / retiradaDesejada) * 100
      : 0;

    // Totais acumulados
    const totalAportado    = projecao.filter(r => !r.aposentado).reduce((s, r) => s + r.aporteAnual, 0);
    const totalRendimento  = projecao.reduce((s, r) => s + r.rendimentoAnual, 0);

    return {
      projecao,
      reservaAposentadoria,
      reservaFinal,
      retiradaPreservar,
      retiradaConsumir,
      independenciaFinanceira,
      totalAportado,
      totalRendimento,
      retornoRealAnual,
      anosRetirada,
    };
  }

  // ----------------------------------------------------------
  // SUGESTÃO DE APORTE
  // Quanto precisa aportar por mês para atingir a retirada desejada
  // ----------------------------------------------------------

  function calcularAporteSugerido(params, cenario, cashflows = [], retiradaAlvo = null) {
    const alvo = retiradaAlvo || Number(cenario.retirada_mensal_apos || 0);
    if (alvo <= 0) return 0;

    const { cdiAnual, percentualCdi, inflacaoAnual } = params;
    const { idade_inicial, vai_trabalhar_ate, expectativa_vida } = cenario;

    const retornoRealAnual = calcularRetornoRealAnual(cdiAnual, percentualCdi, inflacaoAnual);
    const taxaMensal = calcularTaxaMensalReal(retornoRealAnual);

    const nAcum = (vai_trabalhar_ate - idade_inicial) * 12;
    const nRet  = (expectativa_vida - vai_trabalhar_ate) * 12;

    // Reserva necessária para sustentar a retirada até a expectativa de vida
    const reservaNecessaria = taxaMensal === 0
      ? alvo * nRet
      : alvo * (1 - Math.pow(1 + taxaMensal, -nRet)) / taxaMensal;

    // Aporte mensal necessário para acumular essa reserva
    if (nAcum <= 0 || taxaMensal === 0) return reservaNecessaria / nAcum;
    const aporteNecessario = reservaNecessaria * taxaMensal / (Math.pow(1 + taxaMensal, nAcum) - 1);

    return Math.max(0, aporteNecessario);
  }

  // ----------------------------------------------------------
  // FORMATAÇÃO (helpers de UI)
  // ----------------------------------------------------------

  function formatBRL(valor) {
    if (valor === null || valor === undefined || isNaN(valor)) return 'R$ 0,00';
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL',
      minimumFractionDigits: 2,
    }).format(valor);
  }

  function formatBRLCompacto(valor) {
    if (valor === null || isNaN(valor)) return 'R$ 0';
    if (Math.abs(valor) >= 1e9) return `R$ ${(valor / 1e9).toFixed(1).replace('.', ',')} bi`;
    if (Math.abs(valor) >= 1e6) return `R$ ${(valor / 1e6).toFixed(1).replace('.', ',')} M`;
    if (Math.abs(valor) >= 1e3) return `R$ ${(valor / 1e3).toFixed(0)} K`;
    return formatBRL(valor);
  }

  function formatPerc(valor, decimais = 2) {
    if (valor === null || isNaN(valor)) return '0,00%';
    return `${Number(valor).toFixed(decimais).replace('.', ',')}%`;
  }

  // ----------------------------------------------------------
  // DADOS PARA GRÁFICOS
  // ----------------------------------------------------------

  function dadosGraficoDiagnostico(params, cenario, cashflows = []) {
    const { projecao } = calcularIndicadores(params, cenario, cashflows);

    return {
      labels: projecao.map(r => r.idade),
      datasets: [{
        label: 'Reserva',
        data: projecao.map(r => r.recFimAno),
        borderColor: '#008394',
        backgroundColor: 'rgba(0,131,148,0.08)',
        fill: true,
        tension: 0.4,
        pointRadius: 0,
        pointHoverRadius: 5,
      }],
      aposentadoriaIdx: projecao.findIndex(r => r.idade === cenario.vai_trabalhar_ate),
    };
  }

  function dadosGraficoComparacao(params, cenarios, cashflowsPorCenario = {}) {
    const cores = ['#008394', '#f59e0b', '#10b981', '#8b5cf6', '#ef4444', '#ec4899'];

    const primeiroProj = calcularProjecao(params, cenarios[0], cashflowsPorCenario[cenarios[0].id] || []);
    const labels = primeiroProj.map(r => r.idade);

    const datasets = cenarios.map((cenario, i) => {
      const projecao = calcularProjecao(params, cenario, cashflowsPorCenario[cenario.id] || []);
      return {
        label: cenario.nome || `Cenário ${i + 1}`,
        data: projecao.map(r => r.recFimAno),
        borderColor: cores[i % cores.length],
        backgroundColor: 'transparent',
        tension: 0.4,
        pointRadius: 0,
        pointHoverRadius: 5,
        borderWidth: 2,
      };
    });

    return { labels, datasets };
  }

  // ----------------------------------------------------------
  // API PÚBLICA
  // ----------------------------------------------------------

  return {
    calcularRetornoRealAnual,
    calcularTaxaMensalReal,
    calcularProjecao,
    calcularIndicadores,
    calcularAporteSugerido,
    dadosGraficoDiagnostico,
    dadosGraficoComparacao,
    formatBRL,
    formatBRLCompacto,
    formatPerc,
  };

})();
