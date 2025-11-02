// src/viewmodels/admin/dtos/point_edit_data.dart
class PointEditData {
  final String name;
  final String postal;
  final String city;
  final String street;
  final String number;
  final List<String> trashTypes;

  PointEditData({
    required this.name,
    required this.postal,
    required this.city,
    required this.street,
    required this.number,
    required this.trashTypes,
  });
}
