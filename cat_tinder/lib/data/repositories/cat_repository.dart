import '../datasources/cat_api.dart';
import '../models/cat_breed.dart';
import '../models/cat_image.dart';

class CatRepository {
  final CatApi api;

  CatRepository(this.api);

  Future<List<CatImage>> getRandomCatImages({int limit = 1}) async {
    return await api.getRandomCatImages(limit: limit);
  }

  Future<List<CatBreed>> getAllBreeds() async {
    return await api.getAllBreeds();
  }

  Future<CatBreed> getBreedById(String breedId) async {
    return await api.getBreedById(breedId);
  }
}
