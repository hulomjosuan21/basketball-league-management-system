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
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ClientMaterialScreen extends StatefulWidget {
  ClientMaterialScreen({
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
    if (widget.user_id == null) return false;
    if (widget.accountType == null) return false;

    try {
      final service = EntityServices();
      final user_id = widget.user_id;
      if (user_id == null) {
        return false;
      }
      await service.fetch(context, user_id);
      return true;
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

  @override
  Widget build(BuildContext context) {
    debugPrint(
      "User id: ${widget.user_id != null ? widget.user_id : "No user id"}",
    );
    debugPrint(
      "Account type: ${widget.accountType != null ? widget.accountType!.value : "No user"}",
    );

    Widget home() {
      if (widget.user_id != null) {
        if (widget.accountType == AccountTypeEnum.PLAYER) {
          return PlayerMainScreen();
        } else if (widget.accountType == AccountTypeEnum.TEAM_CREATOR) {
          return TeamCreatorMainScreen();
        }
      }
      return ClientLoginScreen();
    }

    return MaterialApp(
      title: 'BogoBallers',
      theme: lightTheme(context),
      routes: clientRoutes,
      home: FutureBuilder(
        future: _checkLoginFuture,
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              extendBodyBehindAppBar: true,
              body: Center(
                child: CircularProgressIndicator(
                  color: context.appColors.accent900,
                ),
              ),
            );
          } else if (asyncSnapshot.hasError) {
            return fullScreenRetryError(context, asyncSnapshot.error, _retry);
          } else {
            return home();
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  void _retry() {
    setState(() {
      _checkLoginFuture = checkIfUserIsLoggedInAsync();
    });
  }
}
