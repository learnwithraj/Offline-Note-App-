//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import quill_native_bridge_macos
import shared_preferences_foundation
import sqflite_darwin
import url_launcher_macos

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  QuillNativeBridgePlugin.register(with: registry.registrar(forPlugin: "QuillNativeBridgePlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  SqflitePlugin.register(with: registry.registrar(forPlugin: "SqflitePlugin"))
  UrlLauncherPlugin.register(with: registry.registrar(forPlugin: "UrlLauncherPlugin"))
}
