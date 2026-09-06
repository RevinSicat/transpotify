import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/local/database.dart';
import '../../../core/local/providers.dart';

final schedulesStreamProvider = StreamProvider<List<Schedule>>((ref) {
    final repository = ref.watch(scheduleRepositoryProvider);
    return repository.watchAll();
});
