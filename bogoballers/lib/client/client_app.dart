import 'package:bogoballers/client/player/player_main_screen.dart';
import 'package:bogoballers/client/screens/client_login_screen.dart';
import 'package:bogoballers/client/team_creator/team_creator_main_screen.dart';
import 'package:bogoballers/core/components/error.dart';
import 'package:bogoballers/core/enums/user_enum.dart';
import 'package:bogoballers/core/routes.dart';
import 'package:bogoballers/core/services/entity_services.dart';
import 'package:bogoballers/core/theme/theme.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/utils/error_handling.dart';
import 'package:bogoballers/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ClientMaterialScreen extends StatefulWidget {
  const ClientMaterialScreen({
    super.key,
    required this.user_id,
    required this.accountType,
  });

  final String? user_id;
  final AccountTypeEnum? accountType;

  @override
  State<ClientMaterialScreen> createState() => _ClientMaterialScreenState();
}

class _ClientMaterialScreenState extends State<ClientMaterialScreen> {
  late Future<bool> _checkLoginFuture;

  @override
  void initState() {
    super.initState();
    _checkLoginFuture = checkIfUserIsLoggedInAsync();
  }

  Future<bool> checkIfUserIsLoggedInAsync() async {
    if (widget.user_id == null || widget.accountType == null) return false;

    try {
      final service = EntityServices();
      await service.fetch(context, widget.user_id!);
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

  Widget _buildHomeScreen() {
    final userId = widget.user_id;
    final accountType = widget.accountType;

    if (userId != null && accountType != null) {
      switch (accountType) {
        case AccountTypeEnum.PLAYER:
          return const PlayerMainScreen();
        case AccountTypeEnum.TEAM_CREATOR:
          return const TeamCreatorMainScreen();
        default:
          return fullScreenRetryError(
            context,
            "Unsupported account type: ${accountType.value}",
            _retry,
          );
      }
    } else {
      return const ClientLoginScreen();
    }
  }

  void _retry() {
    setState(() {
      _checkLoginFuture = checkIfUserIsLoggedInAsync();
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("User ID: ${widget.user_id ?? "None"}");
    debugPrint("Account Type: ${widget.accountType?.value ?? "None"}");

    return MaterialApp(
      title: 'BogoBallers',
      navigatorKey: navigatorKey,
      theme: lightTheme(context),
      routes: appRoutes,
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: _checkLoginFuture,
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
            return const ClientLoginScreen();
          }
        },
      ),
    );
  }
}
