import 'dart:async';

import 'package:bogoballers/core/constants/sizes.dart';
import 'package:bogoballers/core/enums/user_enum.dart';
import 'package:bogoballers/core/helpers/formatNotificationTime.dart';
import 'package:bogoballers/core/models/notification_model.dart';
import 'package:bogoballers/core/models/team_model.dart';
import 'package:bogoballers/core/network/api_response.dart';
import 'package:bogoballers/core/services/notification_model_serices.dart';
import 'package:bogoballers/core/services/team_service.dart';
import 'package:bogoballers/core/socket_controller.dart';
import 'package:bogoballers/core/state/app_state.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/utils/error_handling.dart';
import 'package:bogoballers/core/widgets/app_button.dart';
import 'package:bogoballers/core/widgets/error.dart';
import 'package:bogoballers/core/widgets/flexible_network_image.dart';
import 'package:bogoballers/core/widgets/snackbars.dart';
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
  late Future<void> _futureFetchNotifications;
  String? loadingNotificationId;

  @override
  void initState() {
    super.initState();
    SocketService().on(SocketEvent.notification, _handleNotification);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _futureFetchNotifications = fetchNotifications();
      setState(() {});
    });
  }

  Future<void> fetchNotifications({bool refresh = false}) async {
    final appState = context.read<AppState>();
    try {
      if (appState.user_id == null) EntityNotFound(AccountTypeEnum.PLAYER);
      if (refresh) {
        appState.resetFetchedFlag();
      }
      await appState.fetchNotificationsOnce(appState.user_id!);
    } on EntityNotFound catch (e) {
      if (context.mounted) {
        showAppSnackbar(
          context,
          message: e.toString(),
          title: "Error",
          variant: SnackbarVariant.error,
        );

        Navigator.pushReplacementNamed(context, '/client/login/sreen');
      }
    } catch (e) {
      if (context.mounted) {
        handleErrorCallBack(e, (message) {
          showAppSnackbar(
            context,
            message: message,
            title: "Error",
            variant: SnackbarVariant.error,
          );
        });
      }
    }
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
      body: RefreshIndicator(
        color: appColors.accent900,
        onRefresh: () => fetchNotifications(refresh: true),
        child: FutureBuilder(
          future: _futureFetchNotifications,
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: appColors.accent900),
              );
            } else if (asyncSnapshot.hasError) {
              final error = asyncSnapshot.error;
              return retryError(context, error, _retry);
            } else {
              return Padding(
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
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> handleInviteAction(
    NotificationModel notification,
    bool isAccepted,
    String? player_team_id,
  ) async {
    setState(() => loadingNotificationId = notification.author);
    try {
      final notification_service = NotificationModelSerices();
      final team_service = TeamService();
      if (player_team_id == null) {
        return;
      }

      ApiResponse response;

      if (!isAccepted) {
        await notification_service.nullifyAction(notification.notification_id);
        response = await team_service.updatePlayerIsAccepted(
          player_team_id: player_team_id,
          is_accepted: TeamInviteStatus.rejected,
        );
      } else {
        response = await team_service.acceptInvite(
          player_team_id: player_team_id,
        );
      }

      await notification_service.nullifyAction(notification.notification_id);
      notification.action = null;

      if (response.status) {
        if (context.mounted) {
          showAppSnackbar(
            context,
            message: response.message,
            title: "Success",
            variant: SnackbarVariant.success,
          );
        }
      } else {
        throw Exception(response.message);
      }
    } on EntityNotFound catch (e) {
      if (context.mounted) {
        showAppSnackbar(
          context,
          message: e.toString(),
          title: "Error",
          variant: SnackbarVariant.error,
        );

        Navigator.pushReplacementNamed(context, '/client/login/sreen');
      }
    } catch (e) {
      if (context.mounted) {
        handleErrorCallBack(e, (message) {
          showAppSnackbar(
            context,
            message: message,
            title: "Error",
            variant: SnackbarVariant.error,
          );
        });
      }
    } finally {
      if (context.mounted) {
        scheduleMicrotask(() => setState(() => loadingNotificationId = null));
      }
    }
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
                    onPressed: () => handleInviteAction(
                      n,
                      true,
                      n.action?['player_team_id'],
                    ),
                    label: 'Accept',
                    size: ButtonSize.sm,
                    isDisabled: isLoading,
                  ),
                  const SizedBox(width: 8),
                  AppButton(
                    onPressed: () => handleInviteAction(
                      n,
                      false,
                      n.action?['player_team_id'],
                    ),
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

  void _retry() {
    setState(() => _futureFetchNotifications = fetchNotifications());
  }
}
