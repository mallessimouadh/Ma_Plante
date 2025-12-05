import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ma_plante/screens/auth/login.dart';
import 'package:ma_plante/screens/auth/signup.dart';
import 'package:ma_plante/screens/auth/verif.dart';
import 'package:ma_plante/screens/community_chat_screen.dart';
import 'package:ma_plante/screens/fonctionnalités/diagnostic.dart';
import 'package:ma_plante/screens/fonctionnalités/homepage.dart';
import 'package:ma_plante/screens/humidity.dart';
import 'package:ma_plante/screens/identifier.dart';
import 'package:ma_plante/screens/luminosity.dart';
import 'package:ma_plante/screens/paramétres/parametre.dart';
import 'package:ma_plante/screens/reminder.dart';
import 'package:ma_plante/screens/temperature.dart';
import 'package:ma_plante/screens/weather.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ma_plante/screens/paramétres/change_name.dart';
import 'package:ma_plante/screens/paramétres/change_password_page.dart';
import 'package:ma_plante/screens/paramétres/terms_of_use.dart';
import 'package:ma_plante/screens/paramétres/help_page.dart';
import 'package:ma_plante/screens/paramétres/share_page.dart';
import 'package:ma_plante/screens/paramétres/delete_account.dart';
import 'package:provider/provider.dart';
import 'package:ma_plante/providers/auth_provider.dart' as custom_auth_provider;
import 'package:ma_plante/providers/reclamation_provider.dart';
import 'package:ma_plante/providers/post_provider.dart';
import 'package:ma_plante/widgets/disease_logs.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ma_plante/screens/dashboard_screen.dart';
import 'package:ma_plante/screens/profile.dart';
import 'package:ma_plante/screens/catégories.dart';
import 'package:ma_plante/screens/fonctionnalités/saved_item_page.dart';
import 'package:ma_plante/screens/welcome/splash.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title Screen')),
    );
  }
}

Future<void> addIsBlockedField() async {
  final users = await FirebaseFirestore.instance.collection('users').get();
  for (var user in users.docs) {
    if (user.data()['isBlocked'] == null) {
      await FirebaseFirestore.instance.collection('users').doc(user.id).update({
        'isBlocked': false,
      });
      print('Added isBlocked field to ${user.id}');
    }
  }
  print('Migration completed');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PaintingBinding.instance.imageCache.maximumSize = 100;
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => custom_auth_provider.AuthProvider(),
        ),
        ChangeNotifierProvider(create: (_) => ReclamationProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<String> _getInitialRoute() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return '/login';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('user_role');

    if (role == null) {
      try {
        DocumentSnapshot adminDoc = await FirebaseFirestore.instance
            .collection('admins')
            .doc(user.email)
            .get();
        if (adminDoc.exists) {
          role = 'admin';
        } else {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.email)
              .get();
          role =
              (userDoc.exists && userDoc['isAdmin'] == true) ? 'admin' : 'user';
        }
        await prefs.setString('user_role', role);
      } catch (e) {
        print('Error fetching role: $e');
        role = 'user';
        await prefs.setString('user_role', role);
      }
    }

    return '/homepage';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Care',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/verif': (context) => const VerificationScreen(),
        '/homepage': (context) => const HomePage(),
        '/diagnostic': (context) => const DiagnosticPage(),
        '/identifier': (context) => const IdentifierPage(),
        '/rappel': (context) => const ReminderPage(),
        '/luminosité': (context) => const LuminosityPage(),
        '/temperature': (context) => const TemperaturePage(),
        '/weather': (context) => const WeatherScreen(),
        '/humidité': (context) => const Humidity(),
        '/camera': (context) => const PlaceholderScreen(title: 'Camera'),
        '/profile': (context) => const ProfilePage(),
        '/settings': (context) => const SettingsPage(),
        '/categories': (context) => CategoryPage(),
        '/community_chat': (context) => const CommunityChatScreen(),
        '/change_name': (context) => const ChangeNamePage(),
        '/change_password': (context) => const ChangePasswordPage(),
        '/terms_of_use': (context) => const TermsOfUsePage(),
        '/help': (context) => const HelpPage(),
        '/share': (context) => const SharePage(),
        '/delete_account': (context) => const DeleteAccountPage(),
        '/disease_logs': (context) => const DiseaseLogs(),
        '/admin_dashboard': (context) => const DashboardScreen(),
        '/saved_items': (context) => const SavedItemsPage(),
      },
    );
  }
}
