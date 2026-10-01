import 'package:flutter/material.dart';

/// Presentation metadata only. No external apps, plugins or services are run.
class ModuleDescriptor {
  const ModuleDescriptor({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
}
