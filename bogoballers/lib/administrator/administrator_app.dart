import 'package:bogoballers/administrator/screen/administrator_auth.dart';
import 'package:bogoballers/core/components/error.dart';
import 'package:bogoballers/core/components/loading.dart';
import 'package:bogoballers/core/theme/theme.dart';
import 'package:bogoballers/core/utils/error_handling.dart';
import 'package:flutter/material.dart';

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
    await Future.delayed(const Duration(seconds: 5));
    // throw ValidationException("Test");
    // return true or false based on auth
    return false;
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
