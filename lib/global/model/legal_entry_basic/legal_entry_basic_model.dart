
// lib/global/model/legal_entry_basic/legal_entry_basic_model.dart

class LegalEntryBasicModel {
  final String countryCode;
  final String countryName;
  final String countryFlagUrl;
  final String countrySummary;
  final String? importantDates;
  final String? documentDeadline;
  final String instructionsForDocumentSubmission;
  final String consulateOrOtherVisits;
  final String importantNotes;
  final String postArrivalInstructions;

  LegalEntryBasicModel({
    required this.countryCode,
    required this.countryName,
    required this.countryFlagUrl,
    required this.countrySummary,
    this.importantDates,
    this.documentDeadline,
    required this.instructionsForDocumentSubmission,
    required this.consulateOrOtherVisits,
    required this.importantNotes,
    required this.postArrivalInstructions,
  });

  factory LegalEntryBasicModel.fromJson(Map<String, dynamic> json) {
    return LegalEntryBasicModel(
      countryCode: json['countryCode'] ?? '',
      countryName: json['countryName'] ?? '',
      countryFlagUrl: json['countryFlagUrl'] ?? '',
      countrySummary: json['countrySummary'] ?? '',
      importantDates: json['importantDates'],
      documentDeadline: json['documentDeadline'],
      instructionsForDocumentSubmission: json['instructionsForDocumentSubmission'] ?? '',
      consulateOrOtherVisits: json['consulateOrOtherVisits'] ?? '',
      importantNotes: json['importantNotes'] ?? '',
      postArrivalInstructions: json['postArrivalInstructions'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'countryCode': countryCode,
      'countryName': countryName,
      'countryFlagUrl': countryFlagUrl,
      'countrySummary': countrySummary,
      'importantDates': importantDates,
      'documentDeadline': documentDeadline,
      'instructionsForDocumentSubmission': instructionsForDocumentSubmission,
      'consulateOrOtherVisits': consulateOrOtherVisits,
      'importantNotes': importantNotes,
      'postArrivalInstructions': postArrivalInstructions,
    };
  }
  
  String get formattedImportantDates {
    final List<String> dates = [];
    
    if (documentDeadline != null && documentDeadline!.isNotEmpty) {
      dates.add('• Document Due by: $documentDeadline');
    }
    
    if (importantDates != null && importantDates!.isNotEmpty) {
      dates.add('• Typical Travel Dates: $importantDates');
    }
    
    return dates.isEmpty ? 'No important dates available' : dates.join('\n');
  }
}