import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'Blocs/place_bloc.dart';
import 'app_router.dart';
import 'Screen/SplashScreen/splash_screen.dart';
import 'theme/style.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PlaceBloc>(
      create: (context) => PlaceBloc(),
      child: MaterialApp(
        title: 'Sawaari',
        theme: appTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoute.splashScreen,
        onGenerateRoute: AppRoute.generateRoute,
      ),
    );
  }
}
