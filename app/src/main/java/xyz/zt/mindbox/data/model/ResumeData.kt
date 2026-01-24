package xyz.zt.mindbox.data.model

import android.net.Uri

data class ResumeData(
    val personalInfo: PersonalInfo = PersonalInfo(),
    val experiences: List<Experience> = emptyList(),
    val education: Education = Education(),
    val languages: List<Language> = emptyList(),
    val skills: String = "",
    val additionalInfo: String = "",
    val references: List<Reference> = emptyList(),
    val photoUri: Uri? = null
)

data class PersonalInfo(
    val name: String = "",
    val birthDate: String = "",
    val gender: String = "Masculino",
    val maritalStatus: String = "Soltero",
    val professionalId: String = "",
    val email: String = "",
    val phone: String = "",
    val address: String = ""
)

data class Experience(
    val company: String = "",
    val position: String = "",
    val period: String = "",
    val description: String = ""
)

data class Education(
    val university: String = "",
    val postgraduate: String = "",
    val secondary: String = ""
)

data class Language(
    val name: String = "",
    val level: String = "Básico"
)

data class Reference(
    val name: String = "",
    val email: String = "",
    val company: String = "",
    val phone: String = ""
)