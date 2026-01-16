package xyz.zt.mindbox.ui.nav

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.ui.graphics.vector.ImageVector

sealed class BottomNavItem(
    val title: String,
    val icon: ImageVector,
    val route: String
) {
    // Agregamos el Inicio / Dashboard como primera opción
    object Dashboard : BottomNavItem("Inicio", Icons.Default.Home, "dashboard")

    object Notes : BottomNavItem("Notas", Icons.Default.Note, "notes")
    object Reminders : BottomNavItem("Recordatorios", Icons.Default.Alarm, "reminders")
    object Passwords : BottomNavItem("Contraseñas", Icons.Default.Lock, "passwords")
}