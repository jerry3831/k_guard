import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'core/constants/api_constants.dart';
import 'core/theme/app_colors.dart';

import 'features/scanner/data/datasources/scan_remote_datasource.dart';
import 'features/scanner/data/datasources/scan_history_remote_datasource.dart';

import 'features/scanner/data/repositories/scan_repository_impl.dart';
import 'features/scanner/domain/usecases/perform_scan_usecase.dart';
import 'features/scanner/presentation/providers/scanner_bloc.dart';
import 'features/scanner/presentation/screens/scan_screen.dart';
import 'features/scanner/presentation/screens/scan_result_screen.dart';
// import 'features/scanner/domain/entities/currency_note.dart';

import 'features/home/data/repositories/history_repository_impl.dart';
import 'features/home/domain/usecases/get_dashboard_stats_usecase.dart';
import 'features/home/domain/usecases/get_recent_scans_usecase.dart';
import 'features/home/presentation/providers/home_bloc.dart';
import 'features/home/presentation/screens/home_screen.dart';

import 'features/history/data/repositories/scan_history_repository_impl.dart';
import 'features/history/domain/usecases/get_scan_history_usecase.dart';
import 'features/history/domain/usecases/delete_scan_usecase.dart';
import 'features/history/presentation/providers/history_bloc.dart';
import 'features/history/presentation/screens/history_screen.dart';

import 'features/learn/presentation/screens/learn_screen.dart';

import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/auth_usecases.dart';
import 'features/auth/presentation/providers/auth_bloc.dart';
import 'features/auth/presentation/providers/auth_event.dart';
import 'features/auth/presentation/providers/auth_state.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/registration_success_screen.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/auth/presentation/screens/landing_screen.dart';

import 'features/settings/data/datasources/settings_local_datasource.dart';
import 'features/settings/data/repositories/settings_repository_impl.dart';
import 'features/settings/domain/usecases/settings_usecases.dart';
import 'features/settings/presentation/providers/settings_bloc.dart';
import 'features/settings/presentation/providers/settings_event.dart';
import 'features/settings/presentation/providers/settings_state.dart';
import 'features/settings/presentation/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const CurrencyDetectorApp());
}


class CurrencyDetectorApp extends StatefulWidget {
  const CurrencyDetectorApp({super.key});

  @override
  State<CurrencyDetectorApp> createState() => _CurrencyDetectorAppState();
}

class _CurrencyDetectorAppState extends State<CurrencyDetectorApp> {
  late final Dio _dio;

  late final ScanRemoteDataSourceImpl _scanRemoteDataSource;
  late final ScanHistoryRemoteDataSourceImpl _scanHistoryRemoteDataSource;
  late final ScanRepositoryImpl _scanRepository;
  late final HistoryRepositoryImpl _historyRepository;
  late final ScanHistoryRepositoryImpl _scanHistoryRepository;
  late final PerformScanUseCase _performScan;
  late final GetDashboardStatsUseCase _getDashboardStats;
  late final GetRecentScansUseCase _getRecentScans;
  late final GetScanHistoryUseCase _getScanHistory;
  late final DeleteScanUseCase _deleteScan;

  late final AuthRemoteDataSourceImpl _authRemote;
  late final AuthLocalDataSourceImpl _authLocal;
  late final AuthRepositoryImpl _authRepository;
  late final SignInUseCase _signIn;
  late final RegisterUseCase _register;
  late final ForgotPasswordUseCase _forgotPassword;
  late final SignOutUseCase _signOut;
  late final DeleteAccountUseCase _deleteAccount;
  late final GetCurrentUserUseCase _getCurrentUser;
  late final ChangePasswordUseCase _changePassword;
  late final SignInAsGuestUseCase _signInAsGuest;

  late final SettingsLocalDataSourceImpl _settingsLocal;
  late final SettingsRepositoryImpl _settingsRepository;
  late final GetPreferencesUseCase _getPreferences;
  late final SavePreferencesUseCase _savePreferences;

  @override
  void initState() {
    super.initState();
    _buildDependencyGraph();
  }

  void _buildDependencyGraph() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json'},
      ),
    );

    _authRemote     = AuthRemoteDataSourceImpl(_dio);
    _authLocal      = AuthLocalDataSourceImpl();

    _scanRemoteDataSource = ScanRemoteDataSourceImpl(_dio);
    _scanHistoryRemoteDataSource = ScanHistoryRemoteDataSourceImpl(_dio, _authLocal);
    

    final connectivity = Connectivity();

    _scanRepository = ScanRepositoryImpl(
      remoteDataSource: _scanRemoteDataSource,
      historyDataSource: _scanHistoryRemoteDataSource,

      connectivity: connectivity,
    );
    _historyRepository =
        HistoryRepositoryImpl(scanRepo: _scanRepository);
    _scanHistoryRepository = ScanHistoryRepositoryImpl(
      scanRepo: _scanRepository,
      historyRemote: _scanHistoryRemoteDataSource,
    );
    _performScan       = PerformScanUseCase(_scanRepository);
    _getDashboardStats = GetDashboardStatsUseCase(_historyRepository);
    _getRecentScans    = GetRecentScansUseCase(_historyRepository);
    _getScanHistory    = GetScanHistoryUseCase(_scanHistoryRepository);
    _deleteScan        = DeleteScanUseCase(_scanHistoryRepository);


    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final user = await _authLocal.getCachedUser();
          if (user?.sessionToken != null) {
            options.headers['Authorization'] = 'Bearer ${user!.sessionToken}';
          }
        } catch (_) {}
        return handler.next(options);
      },
    ));

    _authRepository = AuthRepositoryImpl(
      remote: _authRemote,
      local:  _authLocal,
    );
    _signIn        = SignInUseCase(_authRepository);
    _register      = RegisterUseCase(_authRepository);
    _forgotPassword = ForgotPasswordUseCase(_authRepository);
    _signOut        = SignOutUseCase(_authRepository);
    _deleteAccount  = DeleteAccountUseCase(_authRepository);
    _getCurrentUser = GetCurrentUserUseCase(_authRepository);
    _changePassword = ChangePasswordUseCase(_authRepository);
    _signInAsGuest  = SignInAsGuestUseCase(_authRepository);

    _settingsLocal      = SettingsLocalDataSourceImpl();
    _settingsRepository = SettingsRepositoryImpl(local: _settingsLocal);
    _getPreferences     = GetPreferencesUseCase(_settingsRepository);
    _savePreferences    = SavePreferencesUseCase(_settingsRepository);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            signIn:         _signIn,
            register:       _register,
            forgotPassword: _forgotPassword,
            signOut: _signOut,
            deleteAccount: _deleteAccount,
            getCurrentUser: _getCurrentUser,
            changePassword: _changePassword,
            signInAsGuest:  _signInAsGuest,
          )..add(const AuthAppStarted()),
        ),
        BlocProvider<ScannerBloc>(
          create: (_) => ScannerBloc(
            performScan: _performScan,
            repository:  _scanRepository,
          ),
        ),
        BlocProvider<HomeBloc>(
          create: (_) => HomeBloc(
            getStats:      _getDashboardStats,
            getRecentScans: _getRecentScans,
          ),
        ),
        BlocProvider<HistoryBloc>(
          create: (_) => HistoryBloc(
            getHistory: _getScanHistory,
            deleteScan: _deleteScan,
          ),
        ),
        BlocProvider<SettingsBloc>(
          create: (_) => SettingsBloc(
            getPreferences:  _getPreferences,
            savePreferences: _savePreferences,
          )..add(const SettingsLoaded()),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          final isDark = state is SettingsLoadSuccess && state.preferences.darkModeEnabled;
          return MaterialApp(
            title: 'KwachaGuard',
            debugShowCheckedModeBanner: false,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            theme: _buildTheme(),
            darkTheme: _buildDarkTheme(),
            onGenerateRoute: _onGenerateRoute,
          );
        },
      ),
    );
  }


  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: AppColors.homeBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
        secondary: AppColors.primaryBlueLight,
        surface: Colors.white,
        error: AppColors.counterfeit,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: const DividerThemeData(
          color: AppColors.divider, thickness: 1, space: 1),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBlueBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.goldAccent,
        brightness: Brightness.dark,
        primary: AppColors.goldAccent,
        secondary: AppColors.goldAccent,
        surface: AppColors.darkBlueSurface,
        error: AppColors.counterfeit,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      cardColor: AppColors.darkBlueSurface,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldAccent,
          foregroundColor: AppColors.darkBlueBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkBlueSurface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: const DividerThemeData(
          color: Colors.white24, thickness: 1, space: 1),
    );
  }


  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _fadeRoute(const _AuthGate(), settings);
      case '/landing':
        return _fadeRoute(const LandingScreen(), settings);
      case '/home':
        return _fadeRoute(const HomeScreen(), settings);
      case '/scan':
        return _slideUpRoute(const ScanScreen(), settings);
      case '/scan-result':
        return _slideRoute(const ScanResultScreen(), settings);
      case '/history':
        return _fadeRoute(const HistoryScreen(), settings);
      case '/settings':
        return _fadeRoute(const SettingsScreen(), settings);
      case '/login':
        return _fadeRoute(const LoginScreen(), settings);
      case '/register':
        return _fadeRoute(const RegisterScreen(), settings);
      case '/registration-success':
        return _fadeRoute(const RegistrationSuccessScreen(), settings);
      case '/forgot-password':
        return _slideRoute(const ForgotPasswordScreen(), settings);
      case '/learn':
        return _fadeRoute(const LearnScreen(), settings);
      default:
        return _fadeRoute(const _NotFoundScreen(), settings);
    }
  }

  static PageRoute<T> _fadeRoute<T>(Widget page, RouteSettings s) =>
      PageRouteBuilder<T>(
        settings: s,
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 220),
        transitionsBuilder: (_, a, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: Curves.easeIn),
          child: child,
        ),
      );

  static PageRoute<T> _slideRoute<T>(Widget page, RouteSettings s) =>
      PageRouteBuilder<T>(
        settings: s,
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 280),
        transitionsBuilder: (_, a, __, child) => SlideTransition(
          position: Tween<Offset>(
              begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(
              parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
      );

  static PageRoute<T> _slideUpRoute<T>(Widget page, RouteSettings s) =>
      PageRouteBuilder<T>(
        settings: s,
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 320),
        transitionsBuilder: (_, a, __, child) => SlideTransition(
          position: Tween<Offset>(
              begin: const Offset(0, 1), end: Offset.zero)
              .animate(CurvedAnimation(
              parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
      );
}


class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          current is AuthAuthenticated || current is AuthUnauthenticated,
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
            (route) => false,
          );
        } else if (state is AuthUnauthenticated) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/landing',
            (route) => false,
          );
        }
      },
      child: const Scaffold(
        backgroundColor: AppColors.dashboardBlue,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield_outlined, color: Colors.white, size: 52),
              SizedBox(height: 20),
              CircularProgressIndicator(
                valueColor:
                AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2.5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            const Text('Page not found',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed('/home'),
              child: const Text('Go home'),
            ),
          ],
        ),
      ),
    );
  }
}