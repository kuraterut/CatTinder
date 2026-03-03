import 'package:cat_tinder/presentation/pages/breeds_list_page.dart';
import 'package:cat_tinder/presentation/pages/home_page.dart';
import 'package:cat_tinder/presentation/providers/breeds_provider.dart';
import 'package:cat_tinder/presentation/providers/cat_provider.dart';
import 'package:cat_tinder/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'data/datasources/cat_api.dart';
import 'data/repositories/cat_repository.dart';

class CatTinderApp extends StatelessWidget {
  const CatTinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<CatApi>(
          create: (_) => CatApi(http.Client()),
        ),
        Provider<CatRepository>(
          create: (context) => CatRepository(
            context.read<CatApi>(),
          ),
        ),
        ChangeNotifierProvider<CatProvider>(
          create: (context) => CatProvider(
            context.read<CatRepository>(),
          )..loadRandomCat(),
        ),
        ChangeNotifierProvider<BreedsProvider>(
          create: (context) => BreedsProvider(
            context.read<CatRepository>(),
          )..loadAllBreeds(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: ThemeData(
          primarySwatch: Colors.orange,
          fontFamily: 'Inter',
          useMaterial3: true,
        ),
        home: const MainNavigationPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const BreedsListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Породы',
          ),
        ],
      ),
    );
  }
}
