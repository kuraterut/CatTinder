import 'package:flutter/material.dart';
import '../../data/models/cat_breed.dart';
import '../../data/repositories/cat_repository.dart';
import '../../utils/error_handler.dart';

class BreedsProvider with ChangeNotifier {
  final CatRepository repository;

  BreedsProvider(this.repository);

  List<CatBreed> _breeds = [];
  bool _isLoading = false;
  String? _error;

  List<CatBreed> get breeds => _breeds;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAllBreeds() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _breeds = await repository.getAllBreeds();
    } catch (e) {
      _error = ErrorHandler.handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
