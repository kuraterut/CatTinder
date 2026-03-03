import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/models/cat_breed.dart';

class BreedListItem extends StatelessWidget {
  final CatBreed breed;
  final VoidCallback onTap;

  const BreedListItem({
    super.key,
    required this.breed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: breed.image?['url'] != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: breed.image!['url']!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[300],
                    child: const Icon(Icons.pets, color: Colors.grey),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[300],
                    child: const Icon(Icons.pets, color: Colors.grey),
                  ),
                ),
              )
            : Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.pets, color: Colors.orange),
              ),
        title: Text(
          breed.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: breed.description != null
            ? Text(
                breed.description!.length > 100
                    ? '${breed.description!.substring(0, 100)}...'
                    : breed.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : const Text('Описание отсутствует'),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}
