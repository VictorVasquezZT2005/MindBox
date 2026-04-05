class ResumeData {
  final PersonalInfo personalInfo;
  final List<Experience> experiences;
  final Education education;
  final List<Language> languages;
  final String skills;
  final String additionalInfo;
  final List<Reference> references;
  final String? photoPath;

  ResumeData({
    PersonalInfo? personalInfo,
    this.experiences = const [],
    Education? education,
    this.languages = const [],
    this.skills = "",
    this.additionalInfo = "",
    this.references = const [],
    this.photoPath,
  })  : personalInfo = personalInfo ?? PersonalInfo(),
        education = education ?? Education();

  ResumeData copyWith({
    PersonalInfo? personalInfo,
    List<Experience>? experiences,
    Education? education,
    List<Language>? languages,
    String? skills,
    String? additionalInfo,
    List<Reference>? references,
    String? photoPath,
  }) {
    return ResumeData(
      personalInfo: personalInfo ?? this.personalInfo,
      experiences: experiences ?? this.experiences,
      education: education ?? this.education,
      languages: languages ?? this.languages,
      skills: skills ?? this.skills,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      references: references ?? this.references,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}

class PersonalInfo {
  final String name;
  final String birthDate;
  final String gender;
  final String maritalStatus;
  final String professionalId;
  final String email;
  final String phone;
  final String address;

  PersonalInfo({
    this.name = "",
    this.birthDate = "",
    this.gender = "Masculino",
    this.maritalStatus = "Soltero",
    this.professionalId = "",
    this.email = "",
    this.phone = "",
    this.address = "",
  });

  PersonalInfo copyWith({
    String? name,
    String? birthDate,
    String? gender,
    String? maritalStatus,
    String? professionalId,
    String? email,
    String? phone,
    String? address,
  }) {
    return PersonalInfo(
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      professionalId: professionalId ?? this.professionalId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }
}

class Experience {
  final String company;
  final String position;
  final String period;
  final String description;

  Experience({
    this.company = "",
    this.position = "",
    this.period = "",
    this.description = "",
  });

  Experience copyWith({
    String? company,
    String? position,
    String? period,
    String? description,
  }) {
    return Experience(
      company: company ?? this.company,
      position: position ?? this.position,
      period: period ?? this.period,
      description: description ?? this.description,
    );
  }
}

class Education {
  final String university;
  final String postgraduate;
  final String secondary;

  Education({
    this.university = "",
    this.postgraduate = "",
    this.secondary = "",
  });

  Education copyWith({
    String? university,
    String? postgraduate,
    String? secondary,
  }) {
    return Education(
      university: university ?? this.university,
      postgraduate: postgraduate ?? this.postgraduate,
      secondary: secondary ?? this.secondary,
    );
  }
}

class Language {
  final String name;
  final String level;

  Language({
    this.name = "",
    this.level = "Básico",
  });

  Language copyWith({
    String? name,
    String? level,
  }) {
    return Language(
      name: name ?? this.name,
      level: level ?? this.level,
    );
  }
}

class Reference {
  final String name;
  final String email;
  final String company;
  final String phone;

  Reference({
    this.name = "",
    this.email = "",
    this.company = "",
    this.phone = "",
  });

  Reference copyWith({
    String? name,
    String? email,
    String? company,
    String? phone,
  }) {
    return Reference(
      name: name ?? this.name,
      email: email ?? this.email,
      company: company ?? this.company,
      phone: phone ?? this.phone,
    );
  }
}
