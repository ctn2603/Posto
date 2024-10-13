class ResourceChecker {
  static bool isImage(String url) {
    final List<String> imageExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.bmp'
    ];
    final String lowerCaseUrl = url.toLowerCase();
    return imageExtensions.any((extension) => lowerCaseUrl.contains(extension));
  }
}
