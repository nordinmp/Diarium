part of asset_library;


class LoadingAnimation extends StatelessWidget {
  const LoadingAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.prograssiveDots(
        color: Theme.of(context).colorScheme.primary,
        size: 50,
      ),
    );
  }
}