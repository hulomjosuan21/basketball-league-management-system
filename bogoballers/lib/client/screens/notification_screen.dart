import 'package:bogoballers/core/constants/sizes.dart';
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
  final List<Map<String, dynamic>> notifList = [];
  bool isRead = false;

  @override
  void initState() {
    super.initState();
    isRead = true;
    SocketService().on(SocketEvent.notification, _handleNotification);
  }

  void _handleNotification(dynamic payload) {
    if (!mounted) return;
    debugPrint("✅ Notification received");
    setState(() {
      notifList.insert(0, {
        'title': payload['title'],
        'detail': payload['detail'],
      });
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
        flexibleSpace: Container(color: appColors.gray200),
        centerTitle: true,
        iconTheme: IconThemeData(color: appColors.accent1100),
        leading: widget.enableBack
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.spaceXs),
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
        child: ListView.builder(
          itemCount: notifList.length,
          itemBuilder: (context, index) {
            final notif = notifList[index];
            return _buildNotificationCard(
              title: notif['title'],
              detail: notif['detail'],
            );
          },
        ),
      ),
    );
  }

  Container _buildNotificationCard({
    required title,
    required String detail,
    bool read = false,
  }) {
    final appColors = context.appColors;
    return Container(
      padding: EdgeInsets.all(Sizes.spaceSm),
      margin: EdgeInsets.only(bottom: Sizes.spaceSm),
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
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FlexibleNetworkImage(
                imageUrl: null,
                isCircular: true,
                size: 40,
                enableEdit: false,
              ),
              SizedBox(width: Sizes.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: Sizes.fontSizeMd,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                    ),
                    Text(
                      detail,
                      style: TextStyle(
                        fontSize: Sizes.fontSizeSm,
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.fade,
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
