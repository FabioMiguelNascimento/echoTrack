// Este é um DTO (Data Transfer Object).
// Ele NÃO é um model de domínio. É seguro para a View usar.
class PointCardData {
  final String id;
  final String name;

  PointCardData({required this.id, required this.name});
}
