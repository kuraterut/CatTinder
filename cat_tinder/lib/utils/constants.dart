class AppConstants {
  static const String appName = 'Кототиндер';

  static const String baseUrl = 'https://api.thecatapi.com/v1';
  static const String apiKey =
      'live_ctVfedtLCnUITuNeUYoee5ATCZW8pcZubhlhX3D5KzuwIHoWcUCWgpFo4l2pJlNk';

  static const String breedsEndpoint = '$baseUrl/breeds';
  static const String imagesEndpoint = '$baseUrl/images/search';

  static const String appIcon = 'assets/icons/cattinder.png';

  static const String errorTitle = 'Ошибка';
  static const String tryAgain = 'Попробовать снова';
  static const String noConnection = 'Нет соединения с интернетом';
  static const String unknownError = 'Неизвестная ошибка';
}
