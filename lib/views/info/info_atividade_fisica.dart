import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:artriapp/views/info/widget/info_template_page.dart';
import 'package:artriapp/views/widgets/session_title.dart';
import 'package:artriapp/views/widgets/hint_indicator_tooltip.dart';
import 'package:artriapp/views/widgets/bullet_list.dart';
import 'package:artriapp/views/widgets/reference_link_text.dart';

class AtividadeFisicaInfoPage extends StatelessWidget {
  const AtividadeFisicaInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return InfoTemplatePage(
      title: 'Atividade Física',
      videoUrl: 'https://www.youtube.com/watch?v=MdaHQJYjOdg',
      sections: [
        // ================= INTRODUÇÃO =================
        const SessionTitle(title: 'Atividade física'),

        const Gap(12),

        const Text(
          'É importante para sua saúde que você se mantenha ativo fisicamente. '
          'A Organização Mundial da Saúde (OMS) recomenda pelo menos 150 minutos '
          'de atividade física por semana.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),

        const Gap(24),

        // ================= O QUE É =================
        const SessionTitle(title: 'O que é atividade física?'),

        const Gap(12),

        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          runSpacing: 4,
          children: const [
            Text(
              'Atividade física é qualquer movimento voluntário do corpo que gera gasto de energia acima do repouso.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            HintIndicatorTooltip(
              tooltipMessage:
                  'Movimentos corporais realizados no dia a dia, lazer, trabalho ou deslocamento.',
            ),
          ],
        ),

        const Gap(16),

        const Text(
          'Ela promove benefícios para a saúde física, emocional e social.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),

        const Gap(24),

        // ================= DIFERENÇA =================
        const SessionTitle(
          title: 'Diferença entre atividade física e exercício físico',
        ),

        const Gap(12),

        const Text(
          'O exercício físico é um tipo específico de atividade física. '
          'Ele é planejado, estruturado e geralmente orientado por um profissional.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),

        const Gap(12),

        Row(
          children: const [
            Text(
              'Exercício físico',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 6),
            HintIndicatorTooltip(
              tooltipMessage:
                  'Atividade planejada e estruturada com objetivo definido.',
            ),
          ],
        ),

        const Gap(24),

        // ================= LAZER =================
        const SessionTitle(title: 'Momentos de lazer'),

        const Gap(12),

        const Text(
          'Você pode praticar atividade física no seu tempo livre por meio de atividades prazerosas.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),

        const Gap(12),

        const BulletList(
          items: [
            'Andar de bicicleta',
            'Caminhar',
            'Correr',
            'Dançar',
            'Praticar esportes',
            'Nadar',
            'Surfar',
            'Fazer trilha',
            'Pular corda',
          ],
        ),

        const Gap(24),

        // ================= CASA =================
        const SessionTitle(title: 'Tarefas domésticas'),

        const Gap(12),

        const Text(
          'As atividades do dia a dia também ajudam você a se manter ativo.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),

        const Gap(12),

        const BulletList(
          items: [
            'Cuidar das plantas',
            'Varrer ou esfregar',
            'Lavar roupas',
            'Cuidar de animais',
            'Dar banho em crianças ou idosos',
            'Fazer compras',
            'Cortar a grama',
            'Carregar objetos',
          ],
        ),

        const Gap(24),

        // ================= DESLOCAMENTO =================
        const SessionTitle(
          title: 'Deslocamento para trabalho ou escola',
        ),

        const Gap(12),

        const Text(
          'Você também pode praticar atividade física durante seus deslocamentos.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),

        const Gap(12),

        const BulletList(
          items: [
            'Caminhar',
            'Correr',
            'Pedalar',
            'Patinar',
            'Utilizar cadeira de rodas manualmente',
          ],
        ),

        const Gap(24),

        // ================= GUIA =================
        const SessionTitle(title: 'Saiba mais'),

        const Gap(12),

        const Text(
          'Leia mais no Guia de Atividade Física para a População Brasileira:',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),

        const Gap(12),

        const ReferenceLinkText(
          text: 'Guia de Atividade Física para a População Brasileira',
          url:
              'https://www.gov.br/saude/pt-br/assuntos/saude-brasil/eu-quero-me-exercitar/documentos/pdf/guia_atividade_fisica_populacao_brasileira.pdf',
        ),

        const Gap(32),
      ],
    );
  }
}