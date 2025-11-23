import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cat_image.dart';
import '../models/cat_breed.dart';
import '../../utils/constants.dart';
import '../../utils/error_handler.dart';

class CatApi {
  final http.Client client;

  CatApi(this.client);

  Future<List<CatImage>> getRandomCatImages({int limit = 1}) async {
    try {
      final response = await client.get(
        Uri.parse('${AppConstants.imagesEndpoint}?limit=$limit'),
        headers: {'x-api-key': AppConstants.apiKey},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => CatImage.fromJson(json)).toList();
      } else {
        throw NetworkError('Failed to load cat images: ${response.statusCode}');
      }
    } catch (e) {
      throw NetworkError('Network error: $e');
    }
  }

  Future<List<CatBreed>> getAllBreeds() async {
    try {
      final response = await client.get(
        Uri.parse(AppConstants.breedsEndpoint),
        headers: {'x-api-key': AppConstants.apiKey},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => CatBreed.fromJson(json)).toList();
      } else {
        throw NetworkError('Failed to load breeds: ${response.statusCode}');
      }
    } catch (e) {
      throw NetworkError('Network error: $e');
    }
  }

  Future<CatBreed> getBreedById(String breedId) async {
    try {
      final response = await client.get(
        Uri.parse('${AppConstants.breedsEndpoint}/$breedId'),
        headers: {'x-api-key': AppConstants.apiKey},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return CatBreed.fromJson(data);
      } else {
        throw NetworkError('Failed to load breed: ${response.statusCode}');
      }
    } catch (e) {
      throw NetworkError('Network error: $e');
    }
  }
}
