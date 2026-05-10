// lib/plugins/host/storage_host.dart
import '../../data/local/daos/plugin_kv_dao.dart';

class StorageHost {
  StorageHost(this._dao);
  final PluginKvDao _dao;

  Future<String?> get(String pluginShortName, String key) {
    return _dao.get(pluginShortName, key);
  }

  Future<void> set(String pluginShortName, String key, String value) {
    return _dao.set(pluginShortName, key, value);
  }

  Future<void> delete(String pluginShortName, String key) {
    return _dao.remove(pluginShortName, key);
  }
}
