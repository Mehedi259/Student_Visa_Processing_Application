// lib/global/model/massage/massage_model.dart

class MessageResponse {
  final List<MessageItem> items;
  final int pageNumber;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  MessageResponse({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(
      items: (json['items'] as List?)
              ?.map((item) => MessageItem.fromJson(item))
              .toList() ??
          [],
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalCount: json['totalCount'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
    );
  }
}

class MessageItem {
  final String messageId;
  final DateTime messageDate;
  final String posterName;
  final String posterType;
  final String subject;
  final String? bodyS3Path;
  final String? attachment;
  final bool studentRead;
  final DateTime? studentReadDate;
  final bool coachRead;
  final DateTime? coachReadDate;
  final bool hideReadDate;
  final String body;

  MessageItem({
    required this.messageId,
    required this.messageDate,
    required this.posterName,
    required this.posterType,
    required this.subject,
    this.bodyS3Path,
    this.attachment,
    required this.studentRead,
    this.studentReadDate,
    required this.coachRead,
    this.coachReadDate,
    required this.hideReadDate,
    required this.body,
  });

  bool get isFromStudent => posterType.toLowerCase() == 'student';
  bool get hasAttachment => attachment != null && attachment!.isNotEmpty;

  factory MessageItem.fromJson(Map<String, dynamic> json) {
    return MessageItem(
      messageId: json['messageId'] ?? '',
      messageDate: DateTime.parse(json['messageDate']),
      posterName: json['posterName'] ?? 'Unknown',
      posterType: json['posterType'] ?? 'Student',
      subject: json['subject'] ?? '',
      bodyS3Path: json['bodyS3Path'],
      attachment: json['attachment'],
      studentRead: json['studentRead'] ?? false,
      studentReadDate: json['studentReadDate'] != null
          ? DateTime.parse(json['studentReadDate'])
          : null,
      coachRead: json['coachRead'] ?? false,
      coachReadDate: json['coachReadDate'] != null
          ? DateTime.parse(json['coachReadDate'])
          : null,
      hideReadDate: json['hideReadDate'] ?? false,
      body: json['body'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'messageDate': messageDate.toIso8601String(),
      'posterName': posterName,
      'posterType': posterType,
      'subject': subject,
      'bodyS3Path': bodyS3Path,
      'attachment': attachment,
      'studentRead': studentRead,
      'studentReadDate': studentReadDate?.toIso8601String(),
      'coachRead': coachRead,
      'coachReadDate': coachReadDate?.toIso8601String(),
      'hideReadDate': hideReadDate,
      'body': body,
    };
  }
}

class SendMessageRequest {
  final String subject;
  final String body;
  final String? attachmentFilePath;

  SendMessageRequest({
    required this.subject,
    required this.body,
    this.attachmentFilePath,
  });
}
