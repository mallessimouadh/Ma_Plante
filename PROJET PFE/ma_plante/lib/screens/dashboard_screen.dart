import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as custom_auth;
import '../widgets/sidebar.dart';
import '../widgets/user_management.dart';
import '../widgets/reclamation_management.dart';
import '../screens/auth/login.dart';
import '../providers/dashboard_state_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  final List<Widget> _screens = [
    UserManagement(),
    ReclamationManagement(),
  ];

  final List<String> _titles = ['User Management', 'Reclamations'];

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<custom_auth.AuthProvider>(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
        ),
      );
    }

    if (!authProvider.isLoggedIn || authProvider.role != 'Super Admin') {
      return const LoginScreen();
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardStateProvider()),
      ],
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (!didPop) {
            final dashboardState = Provider.of<DashboardStateProvider>(
              context,
              listen: false,
            );
            if (dashboardState.selectedIndex != 0) {
              dashboardState.setSelectedIndex(0);
            } else {
              Navigator.pop(context);
            }
          }
        },
        child: Consumer<DashboardStateProvider>(
          builder: (context, dashboardState, child) {
            return Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                title: Text(
                  _titles[dashboardState.selectedIndex],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                elevation: 0,
                backgroundColor: const Color(0xFF2E7D32),
                leading: isSmallScreen
                    ? IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () =>
                            _scaffoldKey.currentState!.openDrawer(),
                      )
                    : null,
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notifications feature coming soon'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'logout') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Logout'),
                            content: const Text(
                              'Are you sure you want to logout?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Color(0xFF4CAF50),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(
                                    color: Color(0xFF4CAF50),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          try {
                            await authProvider.logout();
                            Navigator.pushReplacementNamed(context, '/login');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Déconnecté avec succès'),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Erreur lors de la déconnexion : $e',
                                ),
                              ),
                            );
                          }
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'profile',
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              color: Color(0xFF4CAF50),
                            ),
                            SizedBox(width: 8),
                            Text('Profile'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Color(0xFF4CAF50)),
                            SizedBox(width: 8),
                            Text('Logout'),
                          ],
                        ),
                      ),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: const Color(0xFF81C784),
                            child: Text(
                              authProvider.adminName.isNotEmpty
                                  ? authProvider.adminName[0].toUpperCase()
                                  : 'A',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!isSmallScreen) ...[
                            const SizedBox(width: 8),
                            Text(
                              authProvider.adminName.isNotEmpty
                                  ? authProvider.adminName
                                  : 'Admin',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              drawer: isSmallScreen
                  ? Drawer(
                      child: Sidebar(
                        selectedIndex: dashboardState.selectedIndex,
                        onItemSelected: (index) {
                          dashboardState.setSelectedIndex(index);
                          Navigator.pop(context);
                        },
                      ),
                    )
                  : null,
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                  ),
                ),
                child: Row(
                  children: [
                    if (!isSmallScreen)
                      SizedBox(
                        width: 250,
                        child: Sidebar(
                          selectedIndex: dashboardState.selectedIndex,
                          onItemSelected: (index) {
                            dashboardState.setSelectedIndex(index);
                          },
                        ),
                      ),
                    Expanded(
                      child: RefreshIndicator(
                        key: _refreshKey,
                        color: const Color(0xFF4CAF50),
                        onRefresh: _onRefresh,
                        child: _screens[dashboardState.selectedIndex],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
