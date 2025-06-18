import 'package:bogoballers/core/helpers/helpers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  // await Future.wait([
  //   leagueCategories(),
  //   barangayList(),
  //   organizationTypeList(),
  // ]);

  final result = await termsAndConditionsContent(
    key: 'auth_terms_and_conditions',
  );

  print(result);
}
