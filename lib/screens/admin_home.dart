import 'package:coms_app/screens/dashboard_tab.dart';
import 'package:flutter/material.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AdminHomeScreenState();

}

class _AdminHomeScreenState extends State<AdminHomeScreen>{

  int _selectedIndex = 0;

  /// The  3 Main TABS
  static const List<Widget> _pages = <Widget>[
    DashboardTab(),
    Center(child: Text('Order Management System (Coming Soon)')),
    Center(child: Text('Content Management System (Coming Soon)')),
  ];

  void _onItemTapped(int index) {
    setState((){
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: _pages.elementAt(_selectedIndex),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const <Widget>[

          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),

          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),

          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Inventory',
          ),
        ],
      ),
    );
  }
}
