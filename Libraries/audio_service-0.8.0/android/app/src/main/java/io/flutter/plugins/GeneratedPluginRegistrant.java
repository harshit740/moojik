package io.flutter.plugins;

import io.flutter.plugin.common.PluginRegistry;
import com.rmawatson.flutterisolate.FlutterIsolatePlugin;
import io.flutter.plugins.pathprovider.PathProviderPlugin;
import com.tekartik.sqflite.SqflitePlugin;
import com.ryanheise.audioservice.AudioServicePlugin;

/**
 * Generated file. Do not edit.
 */
public final class GeneratedPluginRegistrant {
  public static void registerWith(PluginRegistry registry) {
    if (alreadyRegisteredWith(registry)) {
      return;
    }
    FlutterIsolatePlugin.registerWith(registry.registrarFor("com.rmawatson.flutterisolate.FlutterIsolatePlugin"));
    PathProviderPlugin.registerWith(registry.registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"));
    SqflitePlugin.registerWith(registry.registrarFor("com.tekartik.sqflite.SqflitePlugin"));
    AudioServicePlugin.registerWith(registry.registrarFor("com.ryanheise.audioservice.AudioServicePlugin"));
  }

  private static boolean alreadyRegisteredWith(PluginRegistry registry) {
    final String key = GeneratedPluginRegistrant.class.getCanonicalName();
    if (registry.hasPlugin(key)) {
      return true;
    }
    registry.registrarFor(key);
    return false;
  }
}
