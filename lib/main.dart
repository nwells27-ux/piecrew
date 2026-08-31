import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'models/user_model.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PieCrewApp());
}

class PieCrewApp extends StatelessWidget {
  const PieCrewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'PieCrew',
        debugShowCheckedModeBanner: false,
        theme: buildPieCrewTheme(),
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    return StreamBuilder(
      stream: auth.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator(color: PieCrewColors.pie)));
        }
        if (!snapshot.hasData) {
          return const LoginScreen();
        }
        return FutureBuilder<PieCrewUser?>(
          future: auth.getUserProfile(snapshot.data!.uid),
          builder: (context, userSnap) {
            if (!userSnap.hasData) {
              return Scaffold(body: Center(child: CircularProgressIndicator(color: PieCrewColors.pie)));
            }
            final user = userSnap.data!;
            // Fire and forget: register this device for push notifications.
            NotificationService(auth).init(user.uid);
            return HomeScreen(user: user);
          },
        );
      },
    );
  }
}
