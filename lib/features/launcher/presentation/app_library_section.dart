import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/l10n/app_strings.dart';
import '../data/app_library_platform.dart';
import '../domain/launchable_app.dart';

class AppLibrarySection extends StatefulWidget {
  const AppLibrarySection({
    required this.locale,
    required this.platform,
    super.key,
  });

  final Locale locale;
  final AppLibraryPlatform platform;

  @override
  State<AppLibrarySection> createState() => _AppLibrarySectionState();
}

class _AppLibrarySectionState extends State<AppLibrarySection> {
  late AppStrings _strings = AppStrings(widget.locale);
  final _searchController = TextEditingController();
  List<LaunchableApp> _availableApps = const [];
  List<String> _savedIds = const [];
  bool _loading = true;
  String? _loadError;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadLibrary();
  }

  @override
  void didUpdateWidget(covariant AppLibrarySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.locale != widget.locale) {
      _strings = AppStrings(widget.locale);
    }
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() => _query = _searchController.text.trim().toLowerCase());
  }

  Future<void> _loadLibrary() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final results = await Future.wait([
        widget.platform.getSavedAppIds(),
        widget.platform.listAvailableApps(),
      ]);
      if (!mounted) return;
      setState(() {
        _savedIds = (results[0] as List<String>).toSet().toList()..sort();
        _availableApps = results[1] as List<LaunchableApp>;
        _loading = false;
      });
    } on PlatformException {
      if (!mounted) return;
      setState(() {
        _loadError = _strings.libraryLoadFailed;
        _loading = false;
      });
    } on MissingPluginException {
      if (!mounted) return;
      setState(() {
        _loadError = _strings.libraryUnavailable;
        _loading = false;
      });
    }
  }

  Future<void> _addApp(LaunchableApp app) async {
    if (_savedIds.contains(app.id)) return;
    try {
      await widget.platform.addApp(app.id);
      if (!mounted) return;
      setState(() => _savedIds = [..._savedIds, app.id]..sort());
    } on PlatformException {
      if (mounted) _showMessage(_strings.librarySaveFailed);
    }
  }

  Future<void> _removeApp(LaunchableApp app) async {
    try {
      await widget.platform.removeApp(app.id);
      if (!mounted) return;
      setState(
        () => _savedIds = _savedIds.where((id) => id != app.id).toList(),
      );
    } on PlatformException {
      if (mounted) _showMessage(_strings.librarySaveFailed);
    }
  }

  Future<void> _launchApp(LaunchableApp app) async {
    try {
      final launched = await widget.platform.launchApp(app.id);
      if (!mounted || launched) return;
      _showMessage(_strings.appUnavailable);
    } on PlatformException catch (error) {
      if (!mounted) return;
      _showMessage(
        error.code == 'app_not_found'
            ? _strings.appUnavailable
            : _strings.appLaunchFailed,
      );
    } on MissingPluginException {
      if (mounted) _showMessage(_strings.libraryUnavailable);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showAppPicker() async {
    var query = '';
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final apps = _availableApps.where((app) {
            final value = query.toLowerCase();
            return app.name.toLowerCase().contains(value) ||
                app.id.toLowerCase().contains(value);
          }).toList();
          return AlertDialog(
            title: Text(_strings.addApp),
            content: SizedBox(
              width: 480,
              height: 520,
              child: Column(
                children: [
                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: _strings.searchApps,
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (value) => setDialogState(() => query = value),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: apps.isEmpty
                        ? Center(child: Text(_strings.noAppsAvailable))
                        : ListView.builder(
                            itemCount: apps.length,
                            itemBuilder: (context, index) {
                              final app = apps[index];
                              final added = _savedIds.contains(app.id);
                              return ListTile(
                                title: Text(app.name),
                                subtitle: Text(
                                  app.id,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: IconButton(
                                  tooltip: added
                                      ? _strings.added
                                      : _strings.add,
                                  onPressed: added
                                      ? null
                                      : () async {
                                          await _addApp(app);
                                          if (context.mounted) {
                                            setDialogState(() {});
                                          }
                                        },
                                  icon: Icon(added ? Icons.check : Icons.add),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(_strings.done),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final knownById = {for (final app in _availableApps) app.id: app};
    final library = _savedIds
        .map((id) => knownById[id] ?? LaunchableApp(id: id, name: id))
        .where(
          (app) =>
              app.name.toLowerCase().contains(_query) ||
              app.id.toLowerCase().contains(_query),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final field = TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: _strings.searchApps,
                prefixIcon: const Icon(Icons.search),
              ),
            );
            final addButton = FilledButton.icon(
              onPressed: _loading || _loadError != null ? null : _showAppPicker,
              icon: const Icon(Icons.add),
              label: Text(_strings.addApp),
            );
            if (constraints.maxWidth < 520) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  field,
                  const SizedBox(height: 8),
                  Align(alignment: Alignment.centerRight, child: addButton),
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: field),
                const SizedBox(width: 12),
                addButton,
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else if (_loadError != null)
          Card(
            child: ListTile(
              leading: const Icon(Icons.error_outline),
              title: Text(_loadError!),
              trailing: TextButton(
                onPressed: _loadLibrary,
                child: Text(_strings.retry),
              ),
            ),
          )
        else if (library.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.apps_rounded),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _savedIds.isEmpty
                          ? _strings.libraryEmpty
                          : _strings.noSearchResults,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                for (var index = 0; index < library.length; index++) ...[
                  if (index > 0) const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.apps_rounded),
                    title: Text(library[index].name),
                    subtitle: library[index].name == library[index].id
                        ? Text(_strings.appUnavailable)
                        : null,
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        IconButton(
                          tooltip: _strings.launch,
                          onPressed: () => _launchApp(library[index]),
                          icon: const Icon(Icons.play_arrow_rounded),
                        ),
                        IconButton(
                          tooltip: _strings.removeApp,
                          onPressed: () => _removeApp(library[index]),
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
