import 'package:asongan_app/core/theme/app_colors.dart';
import 'package:asongan_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Reusable AppBar widget used across Explore, Order, and other main screens.
///
/// Renders the Asongan logo, a title, and optional action icons
/// (theme toggle, notifications, drawer menu) in a uniform layout.
class AsonganAppBar extends StatelessWidget {
  final String title;
  final bool isDark;
  final bool showThemeToggle;
  final bool showNotification;
  final double logoSize;
  final List<Widget>? extraActions;

  const AsonganAppBar({
    super.key,
    required this.title,
    required this.isDark,
    this.showThemeToggle = false,
    this.showNotification = false,
    this.logoSize = 24,
    this.extraActions,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = AppColors.scaffoldBgPure(isDark);
    final Color iconColor = AppColors.icon(isDark);
    final Color textColor = AppColors.textPrimary(isDark);

    return Container(
      color: bgColor,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 12,
        right: 12,
        bottom: 12,
      ),
      child: Row(
        children: [
          // SVG Logo
          SvgPicture.asset(
            "assets/images/logo_asongan.svg",
            width: logoSize,
            height: logoSize,
            semanticsLabel: "logo asongan",
          ),
          const SizedBox(width: 10),
          // Title
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 17,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
          const Spacer(),
          // Optional: theme toggle
          if (showThemeToggle)
            IconButton(
              onPressed: () {
                isDarkModeNotifier.value = !isDarkModeNotifier.value;
              },
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: iconColor,
                size: 22,
              ),
            ),
          // Optional: notification bell
          if (showNotification)
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.notifications_none_rounded,
                color: iconColor,
                size: 22,
              ),
            ),
          // Extra custom actions
          if (extraActions != null) ...extraActions!,
          // Drawer menu button (uses Builder to get inner Scaffold context)
          Builder(
            builder: (innerContext) {
              return IconButton(
                onPressed: () => Scaffold.of(innerContext).openEndDrawer(),
                icon: Icon(Icons.menu_rounded, color: iconColor, size: 22),
              );
            },
          ),
        ],
      ),
    );
  }
}
