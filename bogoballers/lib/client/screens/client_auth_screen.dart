import 'package:bogoballers/core/components/app_button.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class ClientRegisterScreen extends StatefulWidget {
  const ClientRegisterScreen({super.key});

  @override
  State<ClientRegisterScreen> createState() => _ClientRegisterScreenState();
}

class _ClientRegisterScreenState extends State<ClientRegisterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isButtonClicked = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _goToPreviousTab() {
    if (_tabController.index > 0) {
      setState(() {
        _tabController.index = _tabController.index - 1;
      });
    }
  }

  void _onSubmit() {
    // Handle submit action here
    debugPrint('Submit button pressed!');
    // Add your submission logic, e.g., API call, form validation, etc.
  }

  void _navigateToLogin() {
    // Replace '/login' with your actual login screen route
    debugPrint("Login");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: context.appColors.primaryGradient),
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildSelectAccountType(context),
                  _buildTabTwoContent(context),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: GestureDetector(
                onTap: _navigateToLogin,
                child: Text(
                  'Already have an account? Login',
                  style: TextStyle(
                    fontSize: 11,
                    color: context.appColors.gray1100,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTypeItemCard(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onSelect,
  ) {
    final appColors = context.appColors;

    return InkWell(
      onTap: () {
        setState(() {
          _isButtonClicked = true;
          if (_tabController.index < 1) {
            _tabController.index = _tabController.index + 1;
          }
        });
        onSelect();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(12),
        width: 200,
        decoration: BoxDecoration(
          color: appColors.gray100,
          border: Border.all(width: 0.5, color: appColors.gray600),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: appColors.accent600),
            SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectAccountType(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Are you a?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              _buildAccountTypeItemCard(
                context,
                "Player",
                Icons.sports_basketball,
                () {},
              ),
              SizedBox(height: 16),
              _buildAccountTypeItemCard(
                context,
                "Team Creator",
                Icons.groups,
                () {},
              ),
              SizedBox(height: 16),
              _buildAccountTypeItemCard(
                context,
                "Gay",
                Icons.woman_2_rounded,
                () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabTwoContent(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: const Text('Tab 2 Content', style: TextStyle(fontSize: 24)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppButton(
                onPressed: _goToPreviousTab,
                label: 'Back',
                size: ButtonSize.sm,
                variant: ButtonVariant.ghost,
              ),
              AppButton(
                onPressed: _onSubmit,
                label: 'Submit',
                size: ButtonSize.sm,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
