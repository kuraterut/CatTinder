import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/error_handler.dart';
import '../providers/auth_provider.dart';
import '../providers/cat_provider.dart';
import '../widgets/cat_card.dart';
import '../widgets/like_dislike_buttons.dart';
import 'auth_page.dart';
import 'cat_detail_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = Provider.of<CatProvider>(context, listen: false);
        if (provider.currentCat == null) {
          provider.loadRandomCat();
        }
      }
    });
  }

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выход из аккаунта'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      if (!context.mounted) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthPage()),
              (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CatProvider, AuthProvider>(
      builder: (context, catProvider, authProvider, child) {
        if (catProvider.error != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ErrorHandler.showErrorDialog(context, catProvider.error!);
            catProvider.clearError();
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Кототиндер'),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              if (authProvider.currentUser != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Center(
                    child: Text(
                      'Привет, ${authProvider.currentUser!.displayName ?? 'Котовод'}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _logout(context),
                tooltip: 'Выйти из аккаунта',
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: catProvider.isLoading
                      ? _buildLoadingState()
                      : catProvider.currentCat != null
                      ? CatCard(
                    catImage: catProvider.currentCat!,
                    onSwipeLeft: catProvider.dislikeCat,
                    onSwipeRight: catProvider.likeCat,
                    onTap: () {
                      if (catProvider.currentCat != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CatDetailPage(
                              catImage: catProvider.currentCat!,
                            ),
                          ),
                        );
                      }
                    },
                  )
                      : _buildEmptyState(),
                ),
              ),
              LikeDislikeButtons(
                onLike: catProvider.likeCat,
                onDislike: catProvider.dislikeCat,
                likesCount: catProvider.likesCount,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'Ищем котика для вас...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pets, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Кошки закончились!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Provider.of<CatProvider>(context, listen: false)
                    .loadRandomCat();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Попробовать снова'),
            ),
          ],
        ),
      ),
    );
  }
}