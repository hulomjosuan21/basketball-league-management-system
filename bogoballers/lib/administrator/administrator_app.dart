import 'package:bogoballers/administrator/administrator_main_screen.dart';
import 'package:bogoballers/administrator/screen/administrator_login_screen.dart';
import 'package:bogoballers/core/components/error.dart';
import 'package:bogoballers/core/enums/user_enum.dart';
import 'package:bogoballers/core/routes.dart';
import 'package:bogoballers/core/services/entity_services.dart';
import 'package:bogoballers/core/theme/theme.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/utils/error_handling.dart';
import 'package:bogoballers/main.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class AdministratorMaterialScreen extends StatefulWidget {
  const AdministratorMaterialScreen({
    super.key,
    required this.user_id,
    required this.accountType,
  });

  final String? user_id;
  final AccountTypeEnum? accountType;

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
    _loginFuture = _checkIfUserIsLoggedInAsync();
  }

  Future<bool> _checkIfUserIsLoggedInAsync() async {
    final userId = widget.user_id;
    final accountType = widget.accountType;

    if (userId == null || accountType == null) return false;

    try {
      final service = EntityServices();
      await service.fetch(context, userId);
      return true;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        throw ValidationException(
          "You are offline. Please check your connection.",
        );
      }
      return false;
    } catch (_) {
      throw ValidationException("Something went wrong!");
    }
  }

  void _retry() {
    setState(() {
      _loginFuture = _checkIfUserIsLoggedInAsync();
    });
  }

  Widget _buildHomeScreen() {
    final userId = widget.user_id;
    final accountType = widget.accountType;

    if (userId != null && accountType != null) {
      switch (accountType) {
        case AccountTypeEnum.LGU_ADMINISTRATOR:
        case AccountTypeEnum.LOCAL_ADMINISTRATOR:
          return const LeagueAdministratorMainScreen();
        default:
          return fullScreenRetryError(
            context,
            "Unsupported administrator type: ${accountType.value}",
            _retry,
          );
      }
    } else {
      return const AdministratorLoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Admin User ID: ${widget.user_id ?? "None"}");
    debugPrint("Account Type: ${widget.accountType?.value ?? "None"}");

    return MaterialApp(
      title: 'BogoBallers',
      theme: lightTheme(context),
      navigatorKey: navigatorKey,
      routes: appRoutes,
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: _loginFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              extendBodyBehindAppBar: true,
              body: Center(
                child: CircularProgressIndicator(
                  color: context.appColors.accent900,
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return fullScreenRetryError(context, snapshot.error, _retry);
          } else if (snapshot.data == true) {
            return _buildHomeScreen();
          } else {
            return const AdministratorLoginScreen();
          }
        },
      ),
    );
  }
}
