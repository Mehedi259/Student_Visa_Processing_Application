// lib/global/model/settings/student_profile_update_model.dart

class StudentProfileUpdateModel {
  final String? preferredName;
  final String? dateOfBirth;
  final String? gender;
  final String? parentLegalGuardianOneName;
  final String? parentLegalGuardianTwoName;
  final String? pronouns;
  final String? profilePhotoUrl;

  StudentProfileUpdateModel({
    this.preferredName,
    this.dateOfBirth,
    this.gender,
    this.parentLegalGuardianOneName,
    this.parentLegalGuardianTwoName,
    this.pronouns,
    this.profilePhotoUrl,
  });


  factory StudentProfileUpdateModel.fromJson(Map<String, dynamic> json) {
    return StudentProfileUpdateModel(
      preferredName: json['preferredName'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      gender: json['gender'] as String?,
      parentLegalGuardianOneName: json['parentLegalGuardianOneName'] as String?,
      parentLegalGuardianTwoName: json['parentLegalGuardianTwoName'] as String?,
      pronouns: json['pronouns'] as String?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
    );
  }


  Map<String, String> toFormFields() {
    final fields = <String, String>{};

    if (preferredName != null && preferredName!.isNotEmpty) {
      fields['preferredName'] = preferredName!;
    }
    if (dateOfBirth != null && dateOfBirth!.isNotEmpty) {
      fields['dateOfBirth'] = dateOfBirth!;
    }
    if (gender != null && gender!.isNotEmpty) {
      fields['gender'] = gender!;
    }
    if (parentLegalGuardianOneName != null &&
        parentLegalGuardianOneName!.isNotEmpty) {
      fields['parentLegalGuardianOneName'] = parentLegalGuardianOneName!;
    }
    if (parentLegalGuardianTwoName != null &&
        parentLegalGuardianTwoName!.isNotEmpty) {
      fields['parentLegalGuardianTwoName'] = parentLegalGuardianTwoName!;
    }
    if (pronouns != null && pronouns!.isNotEmpty) {
      fields['pronouns'] = pronouns!;
    }

    return fields;
  }

  StudentProfileUpdateModel copyWith({
    String? preferredName,
    String? dateOfBirth,
    String? gender,
    String? parentLegalGuardianOneName,
    String? parentLegalGuardianTwoName,
    String? pronouns,
    String? profilePhotoUrl,
  }) {
    return StudentProfileUpdateModel(
      preferredName: preferredName ?? this.preferredName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      parentLegalGuardianOneName:
      parentLegalGuardianOneName ?? this.parentLegalGuardianOneName,
      parentLegalGuardianTwoName:
      parentLegalGuardianTwoName ?? this.parentLegalGuardianTwoName,
      pronouns: pronouns ?? this.pronouns,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
    );
  }
}