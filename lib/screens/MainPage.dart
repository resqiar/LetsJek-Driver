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
        selectedItemColor: Theme.of(context).accentColor,
        unselectedItemColor: Theme.of(context).textSelectionColor,
        showUnselectedLabels: true,
        selectedLabelStyle:
            TextStyle(fontSize: 12, fontFamily: 'Bolt-Semibold'),
        unselectedLabelStyle:
            TextStyle(fontSize: 12, fontFamily: 'Bolt-Semibold'),
        elevation: 10,
        currentIndex: bottomNavIndex,
        onTap: (value) => updateBottomNavIndex(value),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: (Theme.of(context).brightness == Brightness.dark)
                ? Theme.of(context).primaryColor
                : Colors.white,
            activeIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.bubble_chart),
            icon: Icon(Icons.bubble_chart_outlined),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.star_rate),
            icon: Icon(Icons.star_rate_outlined),
            label: 'Ratings',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
