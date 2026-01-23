package xyz.zt.mindbox.data.model

import java.util.UUID

data class Reminder(
    val id: String = UUID.randomUUID().toString(),
    val title: String = "",
    val notes: String = "",
    val url: String = "",
    val date: String = "",
    val time: String = "",
    val isUrgent: Boolean = false,
    val listCategory: String = "Imbox"
)