import 'package:bogoballers/core/network/dio_client.dart';
import 'package:bogoballers/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(App());
}

class App extends StatelessWidget {
  final DioClient dioClient = DioClient();
  App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      home: Scaffold(
        appBar: AppBar(title: const Text('Flutter App with dotenv')),
        body: Center(child: Text('API Base URL: ${dotenv.env['API_KEY']}')),
      ),
    );
  }
}
