part of asset_library;

class NavBar extends StatefulWidget {
  const NavBar({Key? key, required this.indexNumber }) : super(key: key);
  final int indexNumber;
  @override
  _NavBar createState() => _NavBar();
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
    return BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const <BottomNavigationBarItem> [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Memories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
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