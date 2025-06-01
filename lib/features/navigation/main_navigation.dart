import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:survival/core/router/route_name.dart';
import 'package:survival/core/theme/theme.dart';

class MainNavigation extends StatefulWidget {
  final Widget child;

  const MainNavigation({super.key, required this.child});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final Map<String, int> _routeIndexMap = {
    RouteName.home: 0,
    RouteName.manage: 1,

    RouteName.notification: 3,
    RouteName.about: 4,
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final router = GoRouter.of(context);
    final currentRoute = router.routerDelegate.currentConfiguration.uri.path;
    setState(() {
      _selectedIndex = _routeIndexMap[currentRoute] ?? 0;
    });
  }

  void _onItemTapped(int index, String path) {
    if (index == 2) return;
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });

      context.go(path);
    }
  }

  void _onFabTapped() {
    context.push('/add_device');
    log("FAB Tapped! Navigating to /add_device");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabTapped,
        backgroundColor: primaryColor,
        foregroundColor: lightTextColor,
        elevation: 4.0,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 8.0,
        child: SizedBox(
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildNavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: 'Home',
                    index: 0,
                    path: RouteName.home,
                  ),
                  _buildNavItem(
                    icon: Icons.manage_search_outlined,
                    activeIcon: Icons.manage_search,
                    label: 'Manage',
                    index: 1,
                    path: RouteName.manage,
                  ),
                ],
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildNavItem(
                    icon: Icons.notifications_none_outlined,
                    activeIcon: Icons.notifications,
                    label: 'Notify',
                    index: 3,
                    path: RouteName.notification,
                  ),
                  _buildNavItem(
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings,
                    label: 'Settings',
                    index: 4,
                    path: RouteName.settings,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required String path,
  }) {
    bool isSelected = _selectedIndex == index;
    Color color = isSelected
        ? Theme.of(context).primaryColor
        : Colors.grey.shade600;

    return MaterialButton(
      minWidth: 40,
      onPressed: () {
        _onItemTapped(index, path);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(isSelected ? activeIcon : icon, color: color),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
