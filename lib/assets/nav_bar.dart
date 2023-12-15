part of asset_library;

class NavBar extends StatefulWidget {
  const NavBar({Key? key, required this.indexNumber }) : super(key: key);
  final int indexNumber;
  @override
  State<NavBar> createState() => _NavBar();
}

class _NavBar extends State<NavBar> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.indexNumber;
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
    selectedIndex: _currentIndex,
    destinations: const [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Home',
      ),
      NavigationDestination(
        icon: Icon(Icons.favorite_border),
        selectedIcon: Icon(Icons.favorite),
        label: 'Memories',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    ],
      onDestinationSelected: (index) {
        setState(() {
          _currentIndex = index;
        });

        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/');
            break;
          case 1:
            Navigator.pushNamed(context, 'memories');
            break;
          case 2:
            Navigator.pushNamed(context, 'profile');
            break;
        }    
      }
    );
  }
}