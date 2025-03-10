import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_ai/routes/router.gr.dart';
import '../../../../domain/bloc/auth_bloc/auth_bloc.dart';
import '../../../../domain/model/menu.dart';
import '../../../../utils/rive_utils.dart';
import 'info_card.dart';
import 'side_menu.dart';

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  Menu selectedSideMenu = sidebarMenus.first;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine text color based on theme brightness for better contrast
    final textColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.onSurface
        : Colors.white;

    return SafeArea(
      child: Container(
        width: 288,
        height: double.infinity,
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? theme.colorScheme.surface
              : const Color(
                  0xFF6C63FF), // Use a solid purple color instead of primaryContainer
          borderRadius: const BorderRadius.all(
            Radius.circular(30),
          ),
        ),
        child: DefaultTextStyle(
          style: TextStyle(color: textColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthAuthenticatedState) {
                    return InkWell(
                      onTap: () {
                        context.navigateTo(ProfileRoute());
                      },
                      child: InfoCard(
                        name: state.displayName,
                        bio: state.email,
                      ),
                    );
                  }
                  return const InfoCard(
                    name: "Unknown User",
                    bio: ".....",
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 32, bottom: 16),
                child: Text(
                  "Browse".toUpperCase(),
                  style: theme.textTheme.titleMedium!.copyWith(
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ),
              ...sidebarMenus.map((menu) => SideMenu(
                    menu: menu,
                    selectedMenu: selectedSideMenu,
                    press: () {
                      if (menu.title.contains('My Todos')) {
                        // context.navigateTo(TodoRouteRoute());
                        return;
                      } else if (menu.title.contains('Settings')) {
                        context.navigateTo(SettingsRoute());
                        return;
                      }
                      RiveUtils.chnageSMIBoolState(menu.rive.status!);
                      setState(() {
                        selectedSideMenu = menu;
                      });
                    },
                    riveOnInit: (artboard) {
                      menu.rive.status = RiveUtils.getRiveInput(artboard,
                          stateMachineName: menu.rive.stateMachineName);
                    },
                  )),
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 40, bottom: 16),
                child: Text(
                  "History".toUpperCase(),
                  style: theme.textTheme.titleMedium!.copyWith(
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ),
              ...sidebarMenus2.map(
                (menu) => SideMenu(
                  menu: menu,
                  selectedMenu: selectedSideMenu,
                  press: () {
                    if (menu.title.contains('Log')) {
                      BlocProvider.of<AuthBloc>(context).add(LogOut());
                      Navigator.of(context).pop();
                    } else {
                      RiveUtils.chnageSMIBoolState(menu.rive.status!);
                      setState(() {
                        selectedSideMenu = menu;
                      });
                    }
                  },
                  riveOnInit: (artboard) {
                    menu.rive.status = RiveUtils.getRiveInput(artboard,
                        stateMachineName: menu.rive.stateMachineName);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
