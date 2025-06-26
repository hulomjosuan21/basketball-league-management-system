import 'package:bogoballers/client/screens/team_creator_player_screen.dart';
import 'package:bogoballers/core/constants/custom_icons.dart';
import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/extensions/extensions.dart';
import 'package:bogoballers/core/models/team_model.dart';
import 'package:bogoballers/core/service_locator.dart';
import 'package:bogoballers/core/state/team_provider.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/widgets/app_button.dart';
import 'package:bogoballers/core/widgets/flexible_network_image.dart';
import 'package:bogoballers/core/widgets/setting_menu_list.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class TeamCreatorTeamScreen extends StatefulWidget {
  const TeamCreatorTeamScreen({super.key, required this.team});

  final TeamModel team;

  @override
  State<TeamCreatorTeamScreen> createState() => _TeamCreatorTeamScreenState();
}

class _TeamCreatorTeamScreenState extends State<TeamCreatorTeamScreen> {
  late TeamModel team;
  late final TextEditingController _teamNameController;
  late final TextEditingController _teamMotoController;

  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    team = widget.team;
    _teamNameController = TextEditingController(text: team.team_name);
    _teamMotoController = TextEditingController(text: team.team_motto);

    _teamNameController.addListener(_checkForChanges);
    _teamMotoController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    final isNameChanged = _teamNameController.text != team.team_name;
    final isMotoChanged = _teamMotoController.text != team.team_motto;

    setState(() {
      _hasChanges = isNameChanged || isMotoChanged;
    });
  }

  Future<void> _handleEdit() async {}

  Future<void> _handleEditRecruit(bool value) async {
    final updatedTeam = team.copyWith(is_recruiting: value);
    getIt<TeamProvider>().editTeam(updatedTeam);

    setState(() {
      team = updatedTeam;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width * 0.8;
    final appColors = context.appColors;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          team.team_name.orNoData(),
          maxLines: 1,
          overflow: TextOverflow.fade,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: Sizes.fontSizeMd,
            color: appColors.gray1100,
          ),
        ),
        iconTheme: IconThemeData(color: appColors.gray1100),
        backgroundColor: appColors.gray200,
        flexibleSpace: Container(color: appColors.gray200),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: FlexibleNetworkImage(
                imageUrl: team.team_logo_url,
                isCircular: false,
                radius: Sizes.radiusMd,
                size: screenWidth,
                enableEdit: true,
                enableViewImageFull: true,
              ),
            ),

            _buildSettingMethod(),
          ],
        ),
      ),
    );
  }

  Padding _buildSettingMethod() {
    return Padding(
      padding: const EdgeInsets.all(Sizes.spaceSm),
      child: SettingsMenuList(
        items: [
          SettingsMenuItem(
            icon: CustomIcon.basketballTeam,
            label: 'Details',
            content: _buildDetailsSection(),
          ),
          SettingsMenuItem(
            icon: Icons.people,
            label: 'Players',
            onTap: _handleGotoPlayers,
          ),
          SettingsMenuItem(
            icon: Icons.analytics,
            label: 'Analytics',
            content: _buildAnalyticsSection(),
          ),
          SettingsMenuItem(
            icon: Icons.settings,
            label: 'Settings',
            content: _buildTeamSettingSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection() {
    return Text("Analytics Section");
  }

  Widget _buildDetailsSection() {
    return Column(
      children: [
        TextField(
          controller: _teamNameController,
          decoration: InputDecoration(label: Text("Team name")),
        ),
        SizedBox(height: Sizes.spaceMd),
        TextField(
          controller: _teamMotoController,
          decoration: InputDecoration(
            label: Text("Team moto"),
            alignLabelWithHint: true,
          ),
          maxLines: 2,
        ),
        SizedBox(height: Sizes.spaceMd),
        if (_hasChanges) AppButton(label: 'Save Changes', onPressed: () {}),
      ],
    );
  }

  Widget _buildTeamSettingSection() {
    final appColors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recruit Players',
              style: TextStyle(
                fontSize: Sizes.fontSizeMd,
                fontWeight: FontWeight.w600,
                color: appColors.gray1100,
              ),
            ),
            Switch(
              value: team.is_recruiting,
              onChanged: (value) => _handleEditRecruit(value),
              activeColor: appColors.accent900,
            ),
          ],
        ),
      ],
    );
  }

  void _handleGotoPlayers() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TeamCreatorTeamPlayerScreen()),
    );
  }
}
