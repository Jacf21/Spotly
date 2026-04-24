import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/router/app_router.dart';
import 'package:provider/provider.dart';
import 'core/context/auth_context.dart';
import 'core/context/theme_context.dart';
import 'package:timeago/timeago.dart' as timeago;

// Imports para BLoC y Perfil
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/profile/data/datasources/profile_remote_data_source.dart'; // IMPORTANTE
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/usecases/get_profile_usecase.dart';
import 'features/profile/domain/usecases/update_profile_usecase.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce, // ← agregar esto
    ),
  );
  timeago.setLocaleMessages('es', timeago.EsMessages());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        // Inyección del ProfileBloc usando Clean Architecture
        BlocProvider(
          create: (context) {
            // 1. Instanciamos el cliente de Supabase
            final supabaseClient = Supabase.instance.client;

            // 2. Instanciamos el Data Source pasándole el cliente
            final remoteDataSource =
                ProfileRemoteDataSourceImpl(supabaseClient);

            // 3. Instanciamos el Repositorio pasándole el Data Source
            final repository = ProfileRepositoryImpl(remoteDataSource);

            // 4. Retornamos el BLoC con sus casos de uso
            return ProfileBloc(
              getProfileUseCase: GetProfileUseCase(repository),
              updateProfileUseCase: UpdateProfileUseCase(repository),
            );
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      // Aplicamos el tema desde el context si es necesario
      themeMode: ThemeMode.system,
    );
  }
}
