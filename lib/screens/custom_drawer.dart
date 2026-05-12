
import 'dart:ui';

import 'package:expense_tracker/services/expense_provider.dart';
import 'package:expense_tracker/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child:Consumer<ExpenseProvider>(builder: (_, provider, __){
      
      final accountInfo=provider.acccountInfo;
   return    Column(
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
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                    "https://i.pravatar.cc/150?img=3",
                  ),
                ),

                const SizedBox(height: 10),

                // NAME
                Text(
                  "${accountInfo!=null?accountInfo.name:''}",
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

                drawerItem(
                  icon: Icons.logout_sharp,
                  title: "Log Out",
                  isSelected: true,
                  ontap:() async {
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
        ],
      );}
    ));
  }

  // DRAWER ITEM WIDGET
  Widget drawerItem({
    required IconData icon,
    required String title,required VoidCallback ontap,
    bool isSelected = false,
  }) {
    return Container(
      color: isSelected ? Colors.grey.shade200 : Colors.transparent,
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.grey,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        onTap: ontap,
      ),
    );
  }
}