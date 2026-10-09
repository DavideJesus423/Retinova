/// Classes de risco, na mesma ordem usada pelo modelo (ml/config.py).
enum Risk {
  ok('Ok', 'Sem sinais de alerta. Manter acompanhamento de rotina.'),
  acompanhar('Acompanhar', 'Agendar reavaliação.'),
  encaminharUrgente('Encaminhar urgente', 'Encaminhar ao oftalmologista.');

  const Risk(this.label, this.guidance);
  final String label;
  final String guidance;
}
