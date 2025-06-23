import 'package:bogoballers/core/enums/user_enum.dart';
import 'package:bogoballers/core/models/user.dart';
import 'package:bogoballers/core/state/entity_state.dart';
import 'package:bogoballers/core/state/team_provider.dart';
import 'package:bogoballers/core/utils/error_handling.dart';
import 'package:bogoballers/core/widgets/index.dart';
import 'package:bogoballers/core/helpers/logout.dart';
import 'package:bogoballers/service_locator.dart';
import 'package:flutter/material.dart';

class TeamCreatorHomeScreen extends StatefulWidget {
  const TeamCreatorHomeScreen({super.key});

  @override
  State<TeamCreatorHomeScreen> createState() => _TeamCreatorHomeScreenState();
}

class _TeamCreatorHomeScreenState extends State<TeamCreatorHomeScreen> {
  @override
  void initState() {
    fetchTeams();
    super.initState();
  }

  Future<void> fetchTeams() async {
    try {
      final entity = getIt<EntityState<UserModel>>().entity;
      if (entity == null) throw EntityNotFound(AccountTypeEnum.TEAM_CREATOR);

      getIt<TeamProvider>().fetchTeams(entity.user_id);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AppButton(
          label: "Logut",
          onPressed: () =>
              handleLogout(context: context, route: '/client/login'),
        ),
      ),
    );
  }
}
