import 'dart:io';

import 'package:flutter/foundation.dart';

void main() async {
  if (kDebugMode) {
    print('Running launcher_name...');
  }
  await Process.run('dart', ['run', 'launcher_name:main'], runInShell: true, workingDirectory: Directory.current.path);

  if (kDebugMode) {
    print('Creating native splash screen...');
  }
  await Process.run('dart', ['run', 'flutter_native_splash:create'], runInShell: true, workingDirectory: Directory.current.path);

  if (kDebugMode) {
    print('Creating launcher icons...');
  }
  await Process.run('dart', ['run', 'flutter_launcher_icons:main'], runInShell: true, workingDirectory: Directory.current.path);

  if (kDebugMode) {
    print('Setting up successful!');
  }
}
