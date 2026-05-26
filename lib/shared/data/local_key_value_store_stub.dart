import 'local_key_value_store.dart';
import 'local_key_value_store_memory.dart';

LocalKeyValueStore createStore() => MemoryLocalKeyValueStore();
