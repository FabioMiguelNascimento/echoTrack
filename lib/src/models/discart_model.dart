class DiscartModel {
  final String? uid;
  final String ownerUid;
  final String status;
  final String trashType;
  final String aproxQuantity;
  final String observations;
  final String collectPointId;
  final String collectPointName;

  DiscartModel({
    required this.uid,
    required this.ownerUid,
    required this.status,
    required this.trashType,
    required this.aproxQuantity,
    required this.observations,
    required this.collectPointId,
    required this.collectPointName,
  });

  factory DiscartModel.fromJson(Map<String, dynamic> json, {String? uid}) {
    return DiscartModel(
      uid: uid,
      ownerUid: json['ownerUid'],
      status: json['status'],
      trashType: json['trashType'],
      aproxQuantity: json['aproxQuantity'],
      observations: json['observations'],
      collectPointId: json['collectPointId'] ?? '',
      collectPointName: json['collectPointName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownerUid': ownerUid,
      'status': status,
      'trashType': trashType,
      'aproxQuantity': aproxQuantity,
      'observations': observations,
      'collectPointId': collectPointId,
      'collectPointName': collectPointName,
    };
  }
}
