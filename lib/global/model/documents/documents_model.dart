
// lib/global/model/documents/documents_model.dart

class DocumentsDashboard {
  final String countryCode;
  final String countryName;
  final String countryFlagUrl;
  final DocumentCategory preliminaryDocuments;
  final DocumentCategory studentDocuments;
  final DocumentCategory countryDocuments;

  DocumentsDashboard({
    required this.countryCode,
    required this.countryName,
    required this.countryFlagUrl,
    required this.preliminaryDocuments,
    required this.studentDocuments,
    required this.countryDocuments,
  });

  factory DocumentsDashboard.fromJson(Map<String, dynamic> json) {
    return DocumentsDashboard(
      countryCode: json['countryCode'] ?? '',
      countryName: json['countryName'] ?? '',
      countryFlagUrl: json['countryFlagUrl'] ?? '',
      preliminaryDocuments: DocumentCategory.fromJson(json['preliminaryDocuments'] ?? {}),
      studentDocuments: DocumentCategory.fromJson(json['studentDocuments'] ?? {}),
      countryDocuments: DocumentCategory.fromJson(json['countryDocuments'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'countryCode': countryCode,
      'countryName': countryName,
      'countryFlagUrl': countryFlagUrl,
      'preliminaryDocuments': preliminaryDocuments.toJson(),
      'studentDocuments': studentDocuments.toJson(),
      'countryDocuments': countryDocuments.toJson(),
    };
  }
}

class DocumentCategory {
  final int total;
  final int completed;
  final String status;
  final bool isReadOnly;

  DocumentCategory({
    required this.total,
    required this.completed,
    required this.status,
    required this.isReadOnly,
  });

  factory DocumentCategory.fromJson(Map<String, dynamic> json) {
    return DocumentCategory(
      total: json['total'] ?? 0,
      completed: json['completed'] ?? 0,
      status: json['status'] ?? 'Pending',
      isReadOnly: json['isReadOnly'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'completed': completed,
      'status': status,
      'isReadOnly': isReadOnly,
    };
  }
}

class DocumentTypeList {
  final String documentType;
  final int total;
  final int completed;
  final String status;
  final List<DocumentItem> documents;

  DocumentTypeList({
    required this.documentType,
    required this.total,
    required this.completed,
    required this.status,
    required this.documents,
  });

  factory DocumentTypeList.fromJson(Map<String, dynamic> json) {
    return DocumentTypeList(
      documentType: json['documentType'] ?? '',
      total: json['total'] ?? 0,
      completed: json['completed'] ?? 0,
      status: json['status'] ?? 'Pending',
      documents: (json['documents'] as List?)
          ?.map((e) => DocumentItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'documentType': documentType,
      'total': total,
      'completed': completed,
      'status': status,
      'documents': documents.map((e) => e.toJson()).toList(),
    };
  }
}

class DocumentItem {
  final String studentDocumentId;
  final String title;
  final String? shortDescription;
  final String status;
  final bool mobileScanningDisabled;
  final double displayOrder;

  DocumentItem({
    required this.studentDocumentId,
    required this.title,
    this.shortDescription,
    required this.status,
    required this.mobileScanningDisabled,
    required this.displayOrder,
  });

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    return DocumentItem(
      studentDocumentId: json['studentDocumentId'] ?? '',
      title: json['title'] ?? '',
      shortDescription: json['shortDescription'],
      status: json['status'] ?? 'Initial',
      mobileScanningDisabled: json['mobileScanningDisabled'] ?? false,
      displayOrder: (json['displayOrder'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentDocumentId': studentDocumentId,
      'title': title,
      'shortDescription': shortDescription,
      'status': status,
      'mobileScanningDisabled': mobileScanningDisabled,
      'displayOrder': displayOrder,
    };
  }
}

class DocumentDetail {
  final String title;
  final String description;
  final String instructions;
  final String keyTips;
  final String? sampleUrl;
  final List<String> requirements;
  final List<DocumentUpdate> documentUpdates;
  final List<DocumentUpload> documentUploads;

  DocumentDetail({
    required this.title,
    required this.description,
    required this.instructions,
    required this.keyTips,
    this.sampleUrl,
    required this.requirements,
    required this.documentUpdates,
    required this.documentUploads,
  });

  factory DocumentDetail.fromJson(Map<String, dynamic> json) {
    return DocumentDetail(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      instructions: json['instructions'] ?? '',
      keyTips: json['keyTips'] ?? '',
      sampleUrl: json['sampleUrl'],
      requirements: (json['requirements'] as List?)?.cast<String>() ?? [],
      documentUpdates: (json['documentUpdates'] as List?)
          ?.map((e) => DocumentUpdate.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      documentUploads: (json['documentUploads'] as List?)
          ?.map((e) => DocumentUpload.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'instructions': instructions,
      'keyTips': keyTips,
      'sampleUrl': sampleUrl,
      'requirements': requirements,
      'documentUpdates': documentUpdates.map((e) => e.toJson()).toList(),
      'documentUploads': documentUploads.map((e) => e.toJson()).toList(),
    };
  }
}

class DocumentUpdate {
  final String status;
  final String? exception;
  final String? solution;
  final String createdOn;
  final String createdBy;

  DocumentUpdate({
    required this.status,
    this.exception,
    this.solution,
    required this.createdOn,
    required this.createdBy,
  });

  factory DocumentUpdate.fromJson(Map<String, dynamic> json) {
    return DocumentUpdate(
      status: json['status'] ?? '',
      exception: json['exception'],
      solution: json['solution'],
      createdOn: json['createdOn'] ?? '',
      createdBy: json['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'exception': exception,
      'solution': solution,
      'createdOn': createdOn,
      'createdBy': createdBy,
    };
  }
}

class DocumentUpload {
  final String url;
  final String description;
  final String createdOn;
  final String createdBy;

  DocumentUpload({
    required this.url,
    required this.description,
    required this.createdOn,
    required this.createdBy,
  });

  factory DocumentUpload.fromJson(Map<String, dynamic> json) {
    return DocumentUpload(
      url: json['url'] ?? '',
      description: json['description'] ?? '',
      createdOn: json['createdOn'] ?? '',
      createdBy: json['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'description': description,
      'createdOn': createdOn,
      'createdBy': createdBy,
    };
  }
}