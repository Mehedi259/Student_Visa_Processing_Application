// lib/global/model/home/home_model.dart

class DashboardModel {
  final String id;
  final String firstName;
  final String lastName;
  final String? nickname;
  final GaugeModel legalEntryGauge;
  final GaugeModel ticketingGauge;
  final String documentDeadline;
  final int unreadMessages;

  DashboardModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.nickname,
    required this.legalEntryGauge,
    required this.ticketingGauge,
    required this.documentDeadline,
    required this.unreadMessages,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      nickname: json['nickName'],
      legalEntryGauge: GaugeModel.fromJson(json['legalEntryGauge'] ?? {}),
      ticketingGauge: GaugeModel.fromJson(json['ticketingGauge'] ?? {}),
      documentDeadline: json['documentDeadline'] ?? '',
      unreadMessages: json['unreadMessages'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'nickName': nickname,
      'legalEntryGauge': legalEntryGauge.toJson(),
      'ticketingGauge': ticketingGauge.toJson(),
      'documentDeadline': documentDeadline,
      'unreadMessages': unreadMessages,
    };
  }

  String get fullName => '$firstName $lastName';
  
  String get displayName => firstName;
}

class GaugeModel {
  final String title;
  final String color;
  final int percentage;

  GaugeModel({
    required this.title,
    required this.color,
    required this.percentage,
  });

  factory GaugeModel.fromJson(Map<String, dynamic> json) {
    return GaugeModel(
      title: json['title'] ?? '',
      color: json['color'] ?? '#000000',
      percentage: json['percentage'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'color': color,
      'percentage': percentage,
    };
  }

  // Convert hex color to Flutter Color
  int get colorValue {
    final hexColor = color.replaceAll('#', '');
    return int.parse('FF$hexColor', radix: 16);
  }
}
