import 'package:expense_tracker/services/expense_provider.dart';
import 'package:expense_tracker/utils/app_theme.dart';
import 'package:expense_tracker/widgets/slider.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );
  @override
  void initState() {
    _loadVersion();
    super.initState();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();

    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(child: Consumer<ExpenseProvider>(builder: (_, provider, __) {
      final accountInfo = provider.acccountInfo;
      double currentDiscreteSliderValue = 60;

      return Column(
        children: [
          // TOP HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 20,
            ),
            color: AppTheme.dark,
            child: Column(
              children: [
                // PROFILE IMAGE
                const CircleAvatar(
                  backgroundImage: NetworkImage(AppConstants.profile_pic),
                  radius: 70,
                ),

                const SizedBox(height: 10),

                // NAME
                Text(
                  "${accountInfo != null ? accountInfo.name : ''}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // EMAIL
              ],
            ),
          ),

          // MENU ITEMS
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  // child: Text(
                  //   "Budget",
                  //   style: TextStyle(
                  //       fontWeight: FontWeight.bold,
                  //       fontSize: 16,
                  //       color: AppTheme.dark),
                  // ),
                ),
                // SliderExample(),
                drawerItem(
                  icon: Icons.logout_sharp,
                  title: "Log Out",
                  isSelected: true,
                  ontap: () async {
                    await provider.signOut();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/', (r) => false);
                    }
                  },
                ),
              ],
            ),
          ),

          const Spacer(),
          Text(
            'Version: ${_packageInfo.version}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 20)
        ],
      );
    }));
  }

  // DRAWER ITEM WIDGET
  Widget drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback ontap,
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.black,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
      onTap: ontap,
    );
  }
}
