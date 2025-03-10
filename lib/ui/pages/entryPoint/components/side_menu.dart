import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../../../../domain/model/menu.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    super.key,
    required this.menu,
    required this.press,
    required this.riveOnInit,
    required this.selectedMenu
  });

  final Menu menu;
  final VoidCallback press;
  final ValueChanged<Artboard> riveOnInit;
  final Menu selectedMenu;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = selectedMenu == menu;
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Divider(
            color: theme.colorScheme.onSurface.withOpacity(0.2),
            height: 1
          ),
        ),
        Stack(
          children: [
            // Selection indicator
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              width: isSelected ? 5 : 0,
              height: 56,
              left: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark 
                    ? theme.colorScheme.primary
                    : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
              ),
            ),
            // Menu item
            Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected 
                  ? (theme.brightness == Brightness.dark 
                      ? theme.colorScheme.primaryContainer.withOpacity(0.35) 
                      : Colors.white.withOpacity(0.2))
                  : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                onTap: press,
                dense: true,
                leading: SizedBox(
                  height: 36,
                  width: 36,
                  child: RiveAnimation.asset(
                    menu.rive.src,
                    artboard: menu.rive.artboard,
                    onInit: riveOnInit,
                  ),
                ),
                title: Text(
                  menu.title,
                  style: TextStyle(
                    color: isSelected 
                      ? (theme.brightness == Brightness.dark 
                          ? theme.colorScheme.primary 
                          : Colors.white)
                      : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}