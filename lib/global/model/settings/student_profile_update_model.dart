// lib/global/model/settings/student_profile_update_model.dart

class StudentProfileUpdateModel {
  // ── GET response fields ──────────────────────────────────────────────────
  final String? profilePhotoUrl;   // read from GET, never sent to PATCH

  // ── Shared editable fields ───────────────────────────────────────────────
  final String? preferredName;
  final String? dateOfBirth;
  final String? gender;
  final String? parentLegalGuardianOneName;
  final String? parentLegalGuardianTwoName;
  final String? pronouns;

  const StudentProfileUpdateModel({
    this.profilePhotoUrl,
    this.preferredName,
    this.dateOfBirth,
    this.gender,
    this.parentLegalGuardianOneName,
    this.parentLegalGuardianTwoName,
    this.pronouns,
  });

  // ── GET: JSON → Model ────────────────────────────────────────────────────
  // Maps "profilePhotoUrl" from the GET response body.
  factory StudentProfileUpdateModel.fromJson(Map<String, dynamic> json) {
    return StudentProfileUpdateModel(
      profilePhotoUrl:            json['profilePhotoUrl']            as String?,
      preferredName:              json['preferredName']              as String?,
      dateOfBirth:                json['dateOfBirth']                as String?,
      gender:                     json['gender']                     as String?,
      parentLegalGuardianOneName: json['parentLegalGuardianOneName'] as String?,
      parentLegalGuardianTwoName: json['parentLegalGuardianTwoName'] as String?,
      pronouns:                   json['pronouns']                   as String?,
    );
  }

  // ── PATCH: Model → multipart form fields ─────────────────────────────────
  // NOTE: profilePhotoUrl is intentionally excluded.
  //       The actual image file is passed separately as "profilePhoto"
  //       via MultipartFile in the service layer.
  Map<String, String> toFormFields() {
    return {
      if (preferredName?.isNotEmpty == true)
        'preferredName': preferredName!,
      if (dateOfBirth?.isNotEmpty == true)
        'dateOfBirth': dateOfBirth!,
      if (gender?.isNotEmpty == true)
        'gender': gender!,
      if (parentLegalGuardianOneName?.isNotEmpty == true)
        'parentLegalGuardianOneName': parentLegalGuardianOneName!,
      if (parentLegalGuardianTwoName?.isNotEmpty == true)
        'parentLegalGuardianTwoName': parentLegalGuardianTwoName!,
      if (pronouns?.isNotEmpty == true)
        'pronouns': pronouns!,

    };
  }

  StudentProfileUpdateModel copyWith({
    String? profilePhotoUrl,
    String? preferredName,
    String? dateOfBirth,
    String? gender,
    String? parentLegalGuardianOneName,
    String? parentLegalGuardianTwoName,
    String? pronouns,
  }) {
    return StudentProfileUpdateModel(
      profilePhotoUrl:            profilePhotoUrl            ?? this.profilePhotoUrl,
      preferredName:              preferredName              ?? this.preferredName,
      dateOfBirth:                dateOfBirth                ?? this.dateOfBirth,
      gender:                     gender                     ?? this.gender,
      parentLegalGuardianOneName: parentLegalGuardianOneName ?? this.parentLegalGuardianOneName,
      parentLegalGuardianTwoName: parentLegalGuardianTwoName ?? this.parentLegalGuardianTwoName,
      pronouns:                   pronouns                   ?? this.pronouns,
    );
  }
}