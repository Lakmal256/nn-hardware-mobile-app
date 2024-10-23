import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../localizations.dart';
import 'widgets/app_bar.dart';

class AppPage extends StatelessWidget {
  const AppPage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppBarWithNotifications(canGoBack: false),
      body: child,
      bottomNavigationBar: const BottomNavigation(),
    );
  }
}

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          color: Colors.grey,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: BottomNavigationItem(
                  title: AppLocalizations.of(context)!.nN_066,
                  // title: "Home",
                  onTap: () => GoRouter.of(context).go("/orders"),
                  isActive: GoRouter.of(context).location == "/orders",
                  icon: Icons.home_outlined,
                ),
              ),
              Expanded(
                child: BottomNavigationItem(
                  title: AppLocalizations.of(context)!.nN_067,
                  // title: "Reports",
                  // disabled: true,
                  onTap: () => GoRouter.of(context).go("/reports"),
                  isActive: GoRouter.of(context).location == "/reports",
                  icon: Icons.text_snippet_outlined,
                ),
              ),
              Expanded(
                child: BottomNavigationItem(
                  title: AppLocalizations.of(context)!.nN_068,
                  // title: "Profile",
                  // disabled: true,
                  onTap: () => GoRouter.of(context).go("/profile"),
                  isActive: GoRouter.of(context).location == "/profile",
                  icon: Icons.person_outline_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomNavigationItem extends StatelessWidget {
  const BottomNavigationItem({
    Key? key,
    required this.icon,
    required this.onTap,
    this.isActive = false,
    this.disabled = false,
    required this.title,
  }) : super(key: key);

  final IconData icon;
  final Function() onTap;
  final bool isActive;
  final bool disabled;
  final String title;

  @override
  Widget build(BuildContext context) {
    // Color color = isActive
    //     ? Theme.of(context).colorScheme.primary
    //     : Theme.of(context).colorScheme.secondary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              // dimension: 35,
              dimension: 35,
              child: FittedBox(
                fit: BoxFit.fill,
                child:
                    Icon(icon, color: isActive ? Colors.black : Colors.white),
              ),
            ),
            const SizedBox(height: 5),
            Visibility(
              visible: isActive,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: isActive ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
