import 'package:bogoballers/core/state/app_state.dart';
import 'package:bogoballers/core/state/entity_state.dart';
import 'package:bogoballers/core/models/league_administrator.dart';
import 'package:bogoballers/core/models/player_model.dart';
import 'package:bogoballers/core/models/user.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerSingleton<EntityState<PlayerModel>>(EntityState<PlayerModel>());
  getIt.registerSingleton<EntityState<UserModel>>(EntityState<UserModel>());
  getIt.registerSingleton<EntityState<LeagueAdministratorModel>>(
    EntityState<LeagueAdministratorModel>(),
  );

  getIt.registerSingleton<AppState>(AppState());
}
