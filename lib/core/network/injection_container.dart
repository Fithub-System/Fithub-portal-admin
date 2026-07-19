import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'api_provider.dart';
import 'locale_code_holder.dart';
import 'network_config.dart';
import 'supabase_config.dart';

/// Core network registrations (Dio [ApiProvider]).
void registerNetworkDependencies(GetIt getIt) {
  if (getIt.isRegistered<ApiProvider>()) return;

  getIt.registerLazySingleton<ApiProvider>(
    () => ApiProvider.create(
      baseUrl: NetworkConfig.baseUrl,
      languageCode: () => LocaleCodeHolder.code,
      accessToken: () {
        if (!SupabaseConfig.isConfigured) return null;
        try {
          if (!Supabase.instance.isInitialized) return null;
          return Supabase.instance.client.auth.currentSession?.accessToken;
        } catch (_) {
          return null;
        }
      },
    ),
  );
}
