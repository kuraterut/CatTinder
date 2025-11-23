import 'package:flutter/material.dart';
import '../../data/models/cat_image.dart';
import '../../data/repositories/cat_repository.dart';
import '../../utils/error_handler.dart';

class CatProvider with ChangeNotifier {
  final CatRepository repository;

  CatProvider(this.repository);

  final List<CatImage> _catImages = [];
  CatImage? _currentCat;
  int _likesCount = 0;
  bool _isLoading = false;
  String? _error;

  List<CatImage> get catImages => _catImages;
  CatImage? get currentCat => _currentCat;
  int get likesCount => _likesCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRandomCat() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final cats = await repository.getRandomCatImages(limit: 1);
      if (cats.isNotEmpty) {
        _currentCat = cats.first;
        _catImages.add(cats.first);
      }
    } catch (e) {
      _error = ErrorHandler.handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void likeCat() {
    _likesCount++;
    _loadNextCat();
  }

  void dislikeCat() {
    _loadNextCat();
  }

  void _loadNextCat() {
    _currentCat = null;
    notifyListeners();
    loadRandomCat();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
