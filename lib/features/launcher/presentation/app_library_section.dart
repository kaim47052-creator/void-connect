import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/motion/void_motion.dart';
import '../data/app_library_platform.dart';
import '../domain/launchable_app.dart';

class AppLibrarySection extends StatefulWidget {
  const AppLibrarySection({
    required this.platform,
    required this.searchFocusNode,
    super.key,
  });

  final AppLibraryPlatform platform;
  final FocusNode searchFocusNode;

  @override
  State<AppLibrarySection> createState() => _AppLibrarySectionState();
}

class _AppLibrarySectionState extends State<AppLibrarySection> {
  AppLocalizations get _strings => AppLocalizations.of(context)!;
  final _searchController = TextEditingController();
  final _addButtonFocus = FocusNode(debugLabel: 'Add app');
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
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    _addButtonFocus.dispose();
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
      animationStyle: VoidMotion.dialogStyle(context),
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
              height:
                  (MediaQuery.sizeOf(context).height -
                      MediaQuery.viewInsetsOf(context).vertical) *
                  0.5,
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
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(app.name),
                                          Text(
                                            app.id,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      tooltip: added
                                          ? _strings.addedNamed(app.name)
                                          : _strings.addNamed(app.name),
                                      onPressed: added
                                          ? null
                                          : () async {
                                              await _addApp(app);
                                              if (context.mounted) {
                                                setDialogState(() {});
                                              }
                                            },
                                      icon: Icon(
                                        added ? Icons.check : Icons.add,
                                      ),
                                    ),
                                  ],
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
    if (mounted) _addButtonFocus.requestFocus();
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
            final field = CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.escape):
                    _searchController.clear,
              },
              child: TextField(
                focusNode: widget.searchFocusNode,
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: _strings.searchApps,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            );
            final addButton = FilledButton.icon(
              focusNode: _addButtonFocus,
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
        MotionSwitcher(child: _buildContent(library)),
      ],
    );
  }

  Widget _buildContent(List<LaunchableApp> library) {
    if (_loading) {
      return Center(
        key: const ValueKey('loading'),
        child: LoadingIndicator(label: _strings.loading),
      );
    }
    if (_loadError != null) {
      return Card(
        key: const ValueKey('error'),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(liveRegion: true, child: Text(_loadError!)),
              const SizedBox(height: 8),
              TextButton(onPressed: _loadLibrary, child: Text(_strings.retry)),
            ],
          ),
        ),
      );
    }
    if (library.isEmpty) {
      return Card(
        key: ValueKey(_savedIds.isEmpty ? 'empty' : 'no-results'),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Icon(Icons.apps_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    _savedIds.isEmpty
                        ? _strings.libraryEmpty
                        : _strings.noSearchResults,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Card(
      key: const ValueKey('library'),
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          for (var index = 0; index < library.length; index++) ...[
            if (index > 0) const Divider(height: 1),
            _buildAppRow(library[index]),
          ],
        ],
      ),
    );
  }

  Widget _buildAppRow(LaunchableApp app) {
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(app.name),
        if (app.name == app.id) Text(_strings.appUnavailable),
      ],
    );
    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: _strings.launchNamed(app.name),
          onPressed: () => _launchApp(app),
          icon: const Icon(Icons.play_arrow_rounded),
        ),
        IconButton(
          tooltip: _strings.removeNamed(app.name),
          onPressed: () => _removeApp(app),
          icon: const Icon(Icons.remove_circle_outline),
        ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 520 ||
              MediaQuery.textScalerOf(context).scale(16) > 24) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                details,
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight, child: actions),
              ],
            );
          }
          return Row(
            children: [
              const Icon(Icons.apps_rounded),
              const SizedBox(width: 12),
              Expanded(child: details),
              const SizedBox(width: 12),
              actions,
            ],
          );
        },
      ),
    );
  }
}
