import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/remote_ai_service.dart';

final remoteAiServiceProvider = Provider<RemoteAiService>((ref) {
  return RemoteAiService();
});
