import 'package:flutter/material.dart';
import 'package:mobile/core/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajuda'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: const [
          _Section(
            icon: Icons.home_outlined,
            title: 'Início',
            items: [
              _HelpItem(
                question: 'O que aparece na tela inicial?',
                answer:
                    'A tela inicial exibe suas turmas ativas com o status de cada uma — '
                    'se há uma chamada aberta no momento ou não.',
              ),
              _HelpItem(
                question: 'Como abro uma chamada?',
                answer:
                    'Toque em uma turma na tela inicial ou na aba "Turma" e selecione '
                    '"Iniciar Chamada". O sistema abre uma sessão e fica pronto para escanear.',
              ),
            ],
          ),
          _Section(
            icon: Icons.school_outlined,
            title: 'Chamada (Scanner)',
            items: [
              _HelpItem(
                question: 'Como registro a presença de um aluno?',
                answer:
                    'Com a chamada aberta, aponte a câmera para a carteirinha do aluno. '
                    'O código QR é lido automaticamente e a presença é registrada em tempo real.',
              ),
              _HelpItem(
                question: 'O que significa cada cor de feedback?',
                answer:
                    'Verde: presença registrada com sucesso.\n'
                    'Laranja: aluno já estava registrado nesta sessão.\n'
                    'Vermelho: aluno não encontrado ou erro de comunicação.',
              ),
              _HelpItem(
                question: 'Posso pausar e retomar a chamada?',
                answer:
                    'Sim. Enquanto a sessão estiver aberta, você pode sair da tela e '
                    'voltar — a sessão permanece ativa até você encerrá-la manualmente.',
              ),
              _HelpItem(
                question: 'O que acontece ao encerrar a chamada?',
                answer:
                    'A sessão é fechada e os registros ficam disponíveis no relatório do mês. '
                    'Alunos sem registro na sessão são contabilizados como ausentes.',
              ),
            ],
          ),
          _Section(
            icon: Icons.bar_chart_outlined,
            title: 'Relatórios',
            items: [
              _HelpItem(
                question: 'Como gero um relatório?',
                answer:
                    'Acesse a aba "Relatórios", escolha o mês, o ano e, opcionalmente, '
                    'filtre por turma ou professor. Toque em "Gerar relatório".',
              ),
              _HelpItem(
                question: 'O que o relatório mostra?',
                answer:
                    'Resumo do mês (total de aulas, presenças, faltas e taxa de presença), '
                    'lista de sessões realizadas e os alunos com mais faltas no período.',
              ),
              _HelpItem(
                question: 'Como exporto o relatório?',
                answer:
                    '"Emitir Relatório (PDF)" gera um PDF formatado para impressão ou envio.\n'
                    '"Exportar (CSV)" compartilha um arquivo de planilha compatível com '
                    'Excel e Google Sheets.',
              ),
            ],
          ),
          _Section(
            icon: Icons.admin_panel_settings_outlined,
            title: 'Administração',
            items: [
              _HelpItem(
                question: 'Como cadastro uma turma?',
                answer:
                    'Em Admin → Gestão de Turmas, toque no botão "+" e preencha o nome '
                    'da turma. A turma ficará disponível imediatamente para chamadas.',
              ),
              _HelpItem(
                question: 'Como adiciono alunos a uma turma?',
                answer:
                    'Em Admin → Gestão de Alunos, cadastre o aluno e depois vincule-o '
                    'a uma ou mais turmas. Cada aluno pode pertencer a várias turmas.',
              ),
              _HelpItem(
                question: 'O que é uma carteirinha?',
                answer:
                    'Carteirinhas são códigos QR únicos gerados para cada aluno. '
                    'São usadas pelo scanner para identificar o aluno na chamada. '
                    'Em Admin → Gerenciar Carteirinhas você pode emitir ou reimprimir.',
              ),
            ],
          ),
          _Section(
            icon: Icons.lock_outline,
            title: 'Conta e Segurança',
            items: [
              _HelpItem(
                question: 'Como troco minha senha?',
                answer:
                    'Em Configurações → Trocar senha, informe a senha atual e a nova senha. '
                    'A senha deve ter no mínimo 6 caracteres.',
              ),
              _HelpItem(
                question: 'Meus dados ficam salvos no celular?',
                answer:
                    'Token de acesso e dados de sessão são armazenados no cofre seguro '
                    'do sistema operacional (Android Keystore / iOS Keychain) e nunca '
                    'em texto claro.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<_HelpItem> items;

  const _Section({
    required this.icon,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        ...items,
        const Divider(height: 1),
      ],
    );
  }
}

class _HelpItem extends StatelessWidget {
  final String question;
  final String answer;

  const _HelpItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      title: Text(
        question,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      children: [
        Text(
          answer,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
