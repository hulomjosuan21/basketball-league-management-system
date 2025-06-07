import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bogoballers/administrator/screen/administrator_auth.dart';
import 'package:bogoballers/core/components/app_button.dart';
import 'package:bogoballers/core/components/error.dart';
import 'package:bogoballers/core/components/image_picker.dart';
import 'package:bogoballers/core/components/loading.dart';
import 'package:bogoballers/core/hive/app_box.dart';
import 'package:bogoballers/core/network/api_response.dart';
import 'package:bogoballers/core/providers/league_adminstrator_provider.dart';
import 'package:bogoballers/core/services/league_administrator_service.dart';
import 'package:bogoballers/core/theme/theme.dart';
import 'package:bogoballers/core/utils/error_handling.dart';
import 'package:flutter/material.dart';
import 'package:bogoballers/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:bogoballers/core/models/access_token.dart';
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
    final token = AppBox.accessTokenBox.get('access_token');

    if (token == null || token.isExpired) {
      return false;
    }

    try {
      final service = LeagueAdministratorService();
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
    } on DioException {
      return false;
    } catch (_) {
      throw ValidationException("Something went wrong!");
    }
  }

  void retry() {
    setState(() {
      _loginFuture = checkIfUserIsLoggedInAsync();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BogoBallers',
      theme: lightTheme(context),
      home: FutureBuilder<bool>(
        future: _loginFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return appFullScreenLoading(context);
          } else if (snapshot.hasError) {
            return fullScreenRetryError(context, snapshot.error, retry);
          }

          final isAuthenticated = snapshot.data ?? false;
          return AdministratorLoginScreen();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
