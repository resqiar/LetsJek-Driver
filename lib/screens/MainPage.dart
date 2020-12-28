import 'package:flutter/material.dart';
import 'package:letsjek_driver/screens/tabs/BalanceTab.dart';
import 'package:letsjek_driver/screens/tabs/HomeTab.dart';
import 'package:letsjek_driver/screens/tabs/ProfileTab.dart';
import 'package:letsjek_driver/screens/tabs/RatingTab.dart';

class MainPage extends StatefulWidget {
  static const id = 'mainpage';

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  // TAB CONTROLLER
  TabController tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    tabController.dispose();
    super.dispose();
  }

  // UPDATE EVERY USER CLICK BOTTOM NAV
  int bottomNavIndex = 0;
  void updateBottomNavIndex(int index) {
    setState(() {
      bottomNavIndex = index;
      tabController.index = bottomNavIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          HomeTab(),
          BalanceTab(),
          RatingTab(),
          ProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontSize: 14),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        elevation: 10,
        currentIndex: bottomNavIndex,
        onTap: (value) => updateBottomNavIndex(value),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card_outlined),
            label: 'Balance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_rate_outlined),
            label: 'Ratings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
