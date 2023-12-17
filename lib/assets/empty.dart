part of asset_library;

class EmptyState extends StatelessWidget {
  const EmptyState({Key? key}) : super(key: key);
  

  @override
  Widget build(BuildContext context) {

    List<String> feeling = [":0", "._.;", ">_<", "O_o", "ಠ_ಠ", "( ༎ຶ o ༎ຶ )", "(>_<)", "(Ｔ▽Ｔ)", "(-_-)", "o.O"];


    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            feeling[Random().nextInt(feeling.length)],
            style: TextStyle(
              color: Theme.of(context).colorScheme.scrim,
              fontSize: Theme.of(context).textTheme.displayLarge?.fontSize,
              fontWeight: Theme.of(context).textTheme.displayLarge?.fontWeight,
            ),
          ),
          Text(
            'So empty',
            style: TextStyle(
              color: Theme.of(context).colorScheme.scrim,
              fontSize: Theme.of(context).textTheme.headlineSmall?.fontSize,
              fontWeight: Theme.of(context).textTheme.headlineSmall?.fontWeight,
            ),
          )
        ],
      ),
    );
  }
}