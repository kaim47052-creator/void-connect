import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/modules/module_descriptor.dart';
import '../../../core/theme/void_theme.dart';

class LauncherPage extends StatelessWidget {
  const LauncherPage({
    required this.locale,
    required this.onLocaleChanged,
    super.key,
  });

  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(locale);
    final modules = [
      ModuleDescriptor(
        id: 'launcher',
        title: strings.launcher,
        description: strings.launcherDetail,
        icon: Icons.apps_rounded,
      ),
      ModuleDescriptor(
        id: 'devices',
        title: strings.sync,
        description: strings.syncDetail,
        icon: Icons.devices_rounded,
      ),
      ModuleDescriptor(
        id: 'plugins',
        title: strings.plugins,
        description: strings.pluginsDetail,
        icon: Icons.extension_rounded,
      ),
      ModuleDescriptor(
        id: 'updates',
        title: strings.updates,
        description: strings.updatesDetail,
        icon: Icons.system_update_rounded,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 24,
                    runSpacing: 16,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'VOID / CONNECT',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3,
                          color: VoidTheme.accent,
                        ),
                      ),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'ru', label: Text('RU')),
                          ButtonSegment(value: 'en', label: Text('EN')),
                        ],
                        selected: {locale.languageCode},
                        onSelectionChanged: (selection) =>
                            onLocaleChanged(Locale(selection.single)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  Text(
                    'Void Connect',
                    style: Theme.of(context).textTheme.displaySmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    strings.tagline,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  Chip(
                    avatar: const Icon(Icons.science_outlined, size: 18),
                    label: Text(strings.early),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    strings.intro,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 36),
                  Text(
                    strings.modules,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth >= 680
                          ? (constraints.maxWidth - 16) / 2
                          : constraints.maxWidth;
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          for (final module in modules)
                            SizedBox(
                              width: width,
                              child: Card(
                                margin: EdgeInsets.zero,
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        module.icon,
                                        color: VoidTheme.accent,
                                        size: 30,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        module.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(module.description),
                                      const SizedBox(height: 16),
                                      Text(
                                        strings.planned,
                                        style: const TextStyle(
                                          color: VoidTheme.accent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  Text(
                    strings.footer,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
