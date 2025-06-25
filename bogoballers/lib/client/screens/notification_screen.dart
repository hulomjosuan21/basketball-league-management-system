import 'dart:convert';

import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/enums/user_enum.dart';
import 'package:bogoballers/core/models/notification_model.dart';
import 'package:bogoballers/core/socket_controller.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/widgets/flexible_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({this.enableBack = false, super.key});
  final bool enableBack;

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<NotificationModel> notifList = [];
  bool isRead = false;

  @override
  void initState() {
    super.initState();
    isRead = true;
    debugPrint("🔌 Subscribing to notification socket event");
    SocketService().on(SocketEvent.notification, _handleNotification);
  }

  void _handleNotification(dynamic payload) {
    if (!mounted) return;
    debugPrint("📦 Payload received: ${jsonEncode(payload)}");

    final accountType = AccountTypeEnum.fromValue(payload['account_type']);
    final notif =
        (accountType == AccountTypeEnum.TEAM_CREATOR &&
            payload.containsKey('team_id'))
        ? TeamNotificationModel.fromJson(payload)
        : NotificationModel.fromJson(payload);

    setState(() {
      notifList.insert(0, notif);
    });
  }

  @override
  void dispose() {
    SocketService().off(SocketEvent.notification);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appColors.gray200,
        centerTitle: true,
        iconTheme: IconThemeData(color: appColors.accent1100),
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

  Widget _buildNotificationCard({
    required NotificationModel n,
    bool read = false,
  }) {
    final appColors = context.appColors;
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
      child: Stack(
        children: [
          if (!isRead || !read)
            const Positioned(
              right: 0,
              top: 0,
              child: CircleAvatar(radius: 6, backgroundColor: Colors.red),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FlexibleNetworkImage(
                imageUrl: n.image ?? null,
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
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
