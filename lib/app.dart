// import 'package:flutter/material.dart';
// import 'package:notes_app/providers/notes_provider.dart';
// import 'package:notes_app/providers/theme_providers.dart';
// import 'package:notes_app/screens/home.dart';
// import 'package:provider/provider.dart';

// class App extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => ThemeProvider()),
//         ChangeNotifierProvider(create: (_) => NotesProvider()),
//       ],
//       child: Consumer<ThemeProvider>(
//         builder: (context, themeProvider, _) {
//           return MaterialApp(
//             title: 'Offline Notes',
//             debugShowCheckedModeBanner: false,
//             themeMode: ThemeMode.system,
//             theme:
//                 themeProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
//             home: HomeScreen(),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:notes_app/providers/notes_provider.dart';
import 'package:notes_app/providers/theme_providers.dart';
import 'package:notes_app/screens/home.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          // Detect system brightness
          final systemBrightness = MediaQuery.of(context).platformBrightness;

          // Schedule the theme update after the first frame is drawn
          WidgetsBinding.instance.addPostFrameCallback((_) {
            themeProvider.setSystemTheme(systemBrightness);
          });

          return MaterialApp(
            title: 'Offline Notes',
            debugShowCheckedModeBanner: false,
            theme:
                themeProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
            home: HomeScreen(),
          );
        },
      ),
    );
  }
}
