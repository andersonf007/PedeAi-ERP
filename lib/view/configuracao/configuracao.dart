import 'package:flutter/material.dart';
import 'package:pedeai/theme/app_theme.dart';
import 'package:pedeai/theme/theme_controller.dart';
import 'package:pedeai/view/home/drawer.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key, required this.controller});
  final ThemeController controller;

  @override
  Widget build(BuildContext context) {
    // Reage às mudanças do ThemeController sem depender de rebuild global
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final cs = Theme.of(context).colorScheme;
        return Scaffold(
          appBar: AppBar(
            leading: Builder(
              builder: (ctx) => IconButton(
                icon: Icon(Icons.menu, color: cs.onSurface),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            title: const Text('Configurações'),
          ),
          drawer: DrawerPage(currentRoute: ModalRoute.of(context)?.settings.name),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              _SectionTitle('Aparência'),
              _GroupCard(
                child: Column(
                  children: [
                    _ThemeRadioTile(
                      label: 'Seguir o sistema',
                      value: ThemeMode.system,
                      group: controller.mode,
                      onChanged: (m) => controller.setMode(m),
                    ),
                    const Divider(height: 1),
                    _ThemeRadioTile(
                      label: 'Claro',
                      value: ThemeMode.light,
                      group: controller.mode,
                      onChanged: (m) => controller.setMode(m),
                      trailing: const _ThemePreview(isDark: false),
                    ),
                    const Divider(height: 1),
                    _ThemeRadioTile(
                      label: 'Escuro',
                      value: ThemeMode.dark,
                      group: controller.mode,
                      onChanged: (m) => controller.setMode(m),
                      trailing: const _ThemePreview(isDark: true),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              _SectionTitle('Pré-visualização'),
              const _PreviewCard(),

              // ==========================================================
              // Espaço pra futuras configurações (organizado por seções):
              // ==========================================================
              const SizedBox(height: 24),
              _SectionTitle('Notificações (em breve)'),
              _GroupCard(
                child: Column(
                  children: const [
                    _DisabledTile(
                      icon: Icons.notifications_active_outlined,
                      title: 'Notificações push',
                      subtitle: 'Receba alertas de vendas e estoque',
                    ),
                    Divider(height: 1),
                    _DisabledTile(
                      icon: Icons.vibration,
                      title: 'Feedback tátil',
                      subtitle: 'Vibração ao executar ações',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              _SectionTitle('PDV (em breve)'),
              _GroupCard(
                child: Column(
                  children: const [
                    _DisabledTile(
                      icon: Icons.print_outlined,
                      title: 'Impressora',
                      subtitle: 'Modelo, largura de papel e margens',
                    ),
                    Divider(height: 1),
                    _DisabledTile(
                      icon: Icons.payments_outlined,
                      title: 'Pagamentos',
                      subtitle: 'Preferências de formas de pagamento',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------- UI helpers (reutilizáveis/limpos) ----------

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: cs.onSurface.withValues(alpha: .7),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: child,
    );
  }
}

class _ThemeRadioTile extends StatelessWidget {
  const _ThemeRadioTile({
    required this.label,
    required this.value,
    required this.group,
    required this.onChanged,
    this.trailing,
  });

  final String label;
  final ThemeMode value;
  final ThemeMode group;
  final ValueChanged<ThemeMode> onChanged;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return RadioListTile<ThemeMode>(
      value: value,
      groupValue: group,
      onChanged: (m) => onChanged(m ?? group),
      title: Text(
        label,
        style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600),
      ),
      controlAffinity: ListTileControlAffinity.trailing,
      secondary: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      visualDensity: VisualDensity.compact,
    );
  }
}

/// Bolinhas de cor para preview rápido ao lado das opções
class _ThemePreview extends StatelessWidget {
  const _ThemePreview({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = isDark ? buildDarkTheme() : buildLightTheme();
    final cs = theme.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dot(cs.primary),
        const SizedBox(width: 4),
        _dot(cs.surface),
        const SizedBox(width: 4),
        _dot(cs.onSurface.withValues(alpha: .8)),
      ],
    );
  }

  Widget _dot(Color c) => Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: c,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black12),
        ),
      );
}

/// Cartão de preview maior — acompanha o modo selecionado no controller
class _PreviewCard extends StatelessWidget {
  const _PreviewCard();

  @override
  Widget build(BuildContext context) {
    // Usa o tema atual da própria árvore do app,
    // assim o preview reflete exatamente as cores ativas.
    final cs = Theme.of(context).colorScheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Exemplo', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Veja como ficam os componentes com o tema atual.',
              style: TextStyle(color: cs.onSurface.withValues(alpha: .7)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Primário'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Secundário'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Tiles desabilitadas (placeholders) para futuras seções
class _DisabledTile extends StatelessWidget {
  const _DisabledTile({
    required this.icon,
    required this.title,
    this.subtitle,
  });
  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final on = cs.onSurface.withValues(alpha: .45);
    return ListTile(
      enabled: false,
      leading: Icon(icon, color: on),
      title: Text(title, style: TextStyle(color: on, fontWeight: FontWeight.w600)),
      subtitle: subtitle == null ? null : Text(subtitle!, style: TextStyle(color: on)),
      trailing: Icon(Icons.chevron_right, color: on),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
    );
  }
}
