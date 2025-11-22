class CollectPointModel {
  final String? id;
  final String name;
  final Address address;
  final bool isActive;
  final List<String> trashTypes;

  CollectPointModel({
    this.id,
    required this.name,
    required this.address,
    required this.isActive,
    required this.trashTypes,
  });

  factory CollectPointModel.fromJSON(Map<String, dynamic> json, {String? id}) {
    return CollectPointModel(
      id: id,
      name: json['name'],
      address: Address.fromJSON(json['address']),
      isActive: json['isActive'],
      trashTypes: List<String>.from(json['trashTypes'] ?? []),
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'name': name,
      'address': address.toJSON(),
      'isActive': isActive,
      'trashTypes': trashTypes,
    };
  }
}

class Cords {
  final String lat;
  final String lon;

  Cords({required this.lat, required this.lon});

  factory Cords.fromJSON(Map<String, dynamic> json) {
    return Cords(lat: json['lat'], lon: json['lon']);
  }

  Map<String, dynamic> toJSON() {
    return {'lat': lat, 'lon': lon};
  }
}

class Address {
  final String street;
  final String neighborhood;
  final String city;
  final String number;
  final String postal;
  final String country;
  final String state;
  final Cords? cords;

  Address({
    required this.street,
    required this.neighborhood,
    required this.city,
    required this.number,
    required this.postal,
    required this.country,
    required this.state,
    this.cords,
  });

  factory Address.fromJSON(Map<String, dynamic> json) {
    return Address(
      street: json['street'],
      neighborhood: json['neighborhood'],
      city: json['city'],
      number: json['number'],
      postal: json['postal'],
      country: json['country'],
      state: json['state'],
      cords: json['cords'] == null
          ? null
          : Cords.fromJSON(json['cords']), // Chama o fromJSON da classe cords
    );
  }

  // Método para converter a instancia de volta para um Map (JSON)
  Map<String, dynamic> toJSON() {
    return {
      'street': street,
      'neighborhood': neighborhood,
      'city': city,
      'number': number,
      'postal': postal,
      'country': country,
      'state': state,
      'cords': cords?.toJSON(),
    };
  }
}
