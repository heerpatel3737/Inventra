import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simple global theme mode.
/// `ref.watch(themeModeProvider)` in MaterialApp rebuilds theme instantly.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
