import 'dart:typed_data';

import 'package:flutter/services.dart';

class AssetsTool {
  AssetsTool._();
  static final AssetsTool _instance = AssetsTool._();
  factory AssetsTool() => _instance;

  /// Get assets with extension
  Future<Set<String>> assetsExtension(String extensions) async {
    return (await AssetManifest.loadFromAssetBundle(rootBundle))
        .listAssets()
        .where((element) => element.endsWith(extensions))
        .toSet();
  }

  Future<ByteBuffer> loadBytes(String asset) async {
    return (await rootBundle.load(asset)).buffer;
  }
}
