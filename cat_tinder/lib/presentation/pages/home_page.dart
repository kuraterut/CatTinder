import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cat_provider.dart';
import '../widgets/cat_card.dart';
import '../widgets/like_dislike_buttons.dart';
import 'cat_detail_page.dart';
import '../../utils/error_handler.dart';

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
      final provider = Provider.of<CatProvider>(context, listen: false);
      if (provider.currentCat == null) {
        provider.loadRandomCat();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CatProvider>(
      builder: (context, provider, child) {
        if (provider.error != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ErrorHandler.showErrorDialog(context, provider.error!);
            provider.clearError();
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Кототиндер'),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Column(
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: provider.isLoading
                      ? _buildLoadingState()
                      : provider.currentCat != null
                          ? CatCard(
                              catImage: provider.currentCat!,
                              onSwipeLeft: provider.dislikeCat,
                              onSwipeRight: provider.likeCat,
                              onTap: () {
                                if (provider.currentCat != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CatDetailPage(
                                        catImage: provider.currentCat!,
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
                onLike: provider.likeCat,
                onDislike: provider.dislikeCat,
                likesCount: provider.likesCount,
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
