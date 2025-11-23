import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/breeds_provider.dart';
import '../widgets/breed_list_item.dart';
import 'breed_detail_page.dart';
import '../../utils/error_handler.dart';

class BreedsListPage extends StatefulWidget {
  const BreedsListPage({super.key});

  @override
  State<BreedsListPage> createState() => _BreedsListPageState();
}

class _BreedsListPageState extends State<BreedsListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BreedsProvider>(context, listen: false);
      if (provider.breeds.isEmpty) {
        provider.loadAllBreeds();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BreedsProvider>(
      builder: (context, provider, child) {
        if (provider.error != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ErrorHandler.showErrorDialog(context, provider.error!);
            provider.clearError();
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Породы кошек'),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          body: provider.isLoading
              ? _buildLoadingState()
              : provider.breeds.isNotEmpty
                  ? _buildBreedsList(provider)
                  : _buildEmptyState(),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.orange),
          SizedBox(height: 16),
          Text(
            'Загружаем породы кошек...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreedsList(BreedsProvider provider) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.orange.withValues(alpha: 0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                value: provider.breeds.length.toString(),
                label: 'Всего пород',
                icon: Icons.pets,
              ),
              _buildStatItem(
                value: _countBreedsWithImages(provider.breeds).toString(),
                label: 'С фото',
                icon: Icons.photo,
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            itemCount: provider.breeds.length,
            itemBuilder: (context, index) {
              final breed = provider.breeds[index];
              return BreedListItem(
                breed: breed,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BreedDetailPage(breed: breed),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.orange, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.pets, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Породы не найдены',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Provider.of<BreedsProvider>(context, listen: false)
                  .loadAllBreeds();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Попробовать снова'),
          ),
        ],
      ),
    );
  }

  int _countBreedsWithImages(List<dynamic> breeds) {
    return breeds.where((breed) => breed.image?['url'] != null).length;
  }
}
