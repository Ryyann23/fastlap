import 'local_key_value_store.dart';
import 'local_key_value_store_stub.dart'
    if (dart.library.io) 'local_key_value_store_io.dart'
    if (dart.library.html) 'local_key_value_store_web.dart' as platform;

LocalKeyValueStore createLocalKeyValueStore() {
  return platform.createStore();
}
