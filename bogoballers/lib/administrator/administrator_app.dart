import 'package:bogoballers/administrator/league_administrator.dart';
import 'package:bogoballers/administrator/screen/administrator_login_screen.dart';
import 'package:bogoballers/core/components/error.dart';
import 'package:bogoballers/core/components/loading.dart';
import 'package:bogoballers/core/hive/app_box.dart';
import 'package:bogoballers/core/providers/league_adminstrator_provider.dart';
import 'package:bogoballers/core/services/league_administrator_services.dart';
import 'package:bogoballers/core/theme/theme.dart';
import 'package:bogoballers/core/utils/error_handling.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

class AdministratorMaterialScreen extends StatefulWidget {
  const AdministratorMaterialScreen({super.key});

  @override
  State<AdministratorMaterialScreen> createState() =>
      _AdministratorMaterialScreenState();
}

class _AdministratorMaterialScreenState
    extends State<AdministratorMaterialScreen> {
  late Future<bool> _loginFuture;

  @override
  void initState() {
    super.initState();
    _loginFuture = checkIfUserIsLoggedInAsync();
  }

  Future<bool> checkIfUserIsLoggedInAsync() async {
    // await AppBox.clearAll();
    final token = AppBox.accessTokenBox.get('access_token');

    if (token == null || token.isExpired) {
      return false;
    }

    try {
      final service = LeagueAdministratorServices();
      final response = await service.fetchLeagueAdministrator(
        user_id: token.user_id,
      );

      if (response.payload != null) {
        debugPrint(response.message);

        Future.microtask(() {
          if (!mounted) return;
          final leagueAdministratorProvider =
              Provider.of<LeagueAdministratorProvider>(context, listen: false);
          leagueAdministratorProvider.setCurrentAdministrator(
            response.payload!,
          );
        });

        return true;
      }
      return false;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        throw ValidationException(
          "You are offline. Please check your connection.",
        );
      } else {
        return false;
      }
    } catch (_) {
      throw ValidationException("Something went wrong!");
    }
  }

  void retry() {
    setState(() {
      _loginFuture = checkIfUserIsLoggedInAsync();
    });
  }

  final Map<String, WidgetBuilder> appRoutes = {
    '/administrator/login': (context) => AdministratorLoginScreen(),
    '/administrator/main/screen': (context) => LeagueAdministratorMainScreen(),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BogoBallers',
      theme: lightTheme(context),
      routes: appRoutes,
      home: FutureBuilder<bool>(
        future: _loginFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return appFullScreenLoading(context);
          } else if (snapshot.hasError) {
            return fullScreenRetryError(context, snapshot.error, retry);
          }

          final isAuthenticated = snapshot.data ?? false;
          return isAuthenticated
              ? LeagueAdministratorMainScreen()
              : AdministratorLoginScreen();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
