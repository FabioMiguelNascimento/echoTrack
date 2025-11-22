class FeedbackModel {
  final String id;
  final String userId;
  final String userName;
  final String comment;
  final DateTime date;

  FeedbackModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.comment,
    required this.date,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json, String id) {
    return FeedbackModel(
      id: id,
      userId: json['userId'],
      userName: json['userName'],
      comment: json['comment'],
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'comment': comment,
      'date': date.toIso8601String(),
    };
  }
}
