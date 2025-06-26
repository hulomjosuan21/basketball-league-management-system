import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/helpers/formatNotificationTime.dart';
import 'package:bogoballers/core/models/notification_model.dart';
import 'package:bogoballers/core/socket_controller.dart';
import 'package:bogoballers/core/state/app_state.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/widgets/app_button.dart';
import 'package:bogoballers/core/widgets/flexible_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({this.enableBack = false, super.key});
  final bool enableBack;

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String? loadingNotificationId;

  @override
  void initState() {
    super.initState();
    SocketService().on(SocketEvent.notification, _handleNotification);
  }

  void _handleNotification(dynamic payload) {
    if (!mounted) return;

    final notif = NotificationModel.fromDynamicJson(payload);
    context.read<AppState>().addNotification(notif);
  }

  @override
  void dispose() {
    SocketService().off(SocketEvent.notification);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final notifList = context.watch<AppState>().notifications;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appColors.gray200,
        centerTitle: true,
        iconTheme: IconThemeData(color: appColors.gray1100),
        leading: widget.enableBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Sizes.spaceXs),
            child: Icon(Iconsax.setting_4),
          ),
        ],
        title: Text(
          "Notifications",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: Sizes.fontSizeMd,
            color: appColors.gray1100,
          ),
        ),
      ),
      backgroundColor: appColors.gray200,
      body: Padding(
        padding: const EdgeInsets.all(Sizes.spaceSm),
        child: notifList.isEmpty
            ? Center(
                child: Text(
                  'No notifications yet',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            : ListView.builder(
                itemCount: notifList.length,
                itemBuilder: (context, index) {
                  final notif = notifList[index];
                  return _buildNotificationCard(n: notif);
                },
              ),
      ),
    );
  }

  Future<void> handleInviteAction(
    NotificationModel notification,
    bool accepted,
  ) async {
    setState(() => loadingNotificationId = notification.author);

    await Future.delayed(const Duration(seconds: 1));

    debugPrint('Notification id: ${notification.notification_id}');

    notification.action = null;

    setState(() => loadingNotificationId = null);
  }

  Widget _buildNotificationCard({required NotificationModel n}) {
    final isLoading = loadingNotificationId == n.author;
    final appColors = context.appColors;
    final isActionable =
        n.action?['type'] == NotificationAction.PLAYER_INVITATION.value;

    return Container(
      padding: const EdgeInsets.all(Sizes.spaceSm),
      margin: const EdgeInsets.only(bottom: Sizes.spaceSm),
      decoration: BoxDecoration(
        color: appColors.gray100,
        borderRadius: BorderRadius.circular(Sizes.radiusMd),
        border: Border.all(
          width: Sizes.borderWidthSm,
          color: appColors.gray600,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FlexibleNetworkImage(
                imageUrl: n.image,
                isCircular: true,
                size: 40,
                enableEdit: false,
              ),
              const SizedBox(width: Sizes.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.author,
                      style: TextStyle(
                        fontSize: Sizes.fontSizeMd,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      n.detail,
                      style: TextStyle(
                        fontSize: Sizes.fontSizeSm,
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 4,
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatNotificationTime(n.timestamp.toLocal()),
                      style: TextStyle(
                        fontSize: Sizes.fontSizeSm,
                        color: appColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isActionable) ...[
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: appColors.gray600,
                    width: Sizes.borderWidthSm,
                  ),
                ),
              ),
              padding: const EdgeInsets.only(top: Sizes.spaceSm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    onPressed: () => handleInviteAction(n, true),
                    label: 'Accept',
                    size: ButtonSize.sm,
                    isDisabled: isLoading,
                  ),
                  const SizedBox(width: 8),
                  AppButton(
                    onPressed: () => handleInviteAction(n, false),
                    label: 'Reject',
                    size: ButtonSize.sm,
                    variant: ButtonVariant.outline,
                    isDisabled: isLoading,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
