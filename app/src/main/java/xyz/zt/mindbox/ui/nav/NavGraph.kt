package xyz.zt.mindbox.ui.nav

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.navArgument
import xyz.zt.mindbox.ui.dashboard.screens.dashboard.DashboardScreen
import xyz.zt.mindbox.ui.dashboard.screens.notes.*
import xyz.zt.mindbox.ui.dashboard.screens.reminders.*
import xyz.zt.mindbox.ui.login.ForgotPasswordScreen
import xyz.zt.mindbox.ui.login.LoginScreen
import xyz.zt.mindbox.ui.login.RegisterScreen
import xyz.zt.mindbox.ui.screens.passwords.PasswordsScreen
import xyz.zt.mindbox.ui.screens.profile.ProfileScreen

@Composable
fun MindBoxNavGraph(
    navController: NavHostController,
    isLoggedIn: Boolean,
    notesViewModel: NotesViewModel,
    remindersViewModel: RemindersViewModel,
    onLoginSuccess: () -> Unit,
    onLogout: () -> Unit,
    modifier: Modifier = Modifier
) {
    NavHost(
        navController = navController,
        startDestination = if (!isLoggedIn) "login" else BottomNavItem.Dashboard.route,
        modifier = modifier
    ) {
        // --- AUTENTICACIÓN ---
        composable("login") {
            LoginScreen(
                onLoginSuccess = onLoginSuccess,
                onNavigateToRegister = { navController.navigate("register") },
                onNavigateToForgotPassword = { navController.navigate("forgot_password") }
            )
        }

        composable("register") {
            RegisterScreen(
                onRegisterSuccess = onLoginSuccess,
                onBack = { navController.popBackStack() }
            )
        }

        composable("forgot_password") {
            ForgotPasswordScreen(onBack = { navController.popBackStack() })
        }

        // --- PANTALLAS PRINCIPALES ---
        composable(BottomNavItem.Dashboard.route) {
            DashboardScreen(navController, notesViewModel, onLogout)
        }

        composable(BottomNavItem.Notes.route) {
            NotesScreen(navController, notesViewModel)
        }

        composable(BottomNavItem.Reminders.route) {
            RemindersScreen(navController, remindersViewModel)
        }

        composable(BottomNavItem.Passwords.route) {
            PasswordsScreen()
        }

        composable(BottomNavItem.Profile.route) {
            ProfileScreen(onLogout = onLogout)
        }

        // --- FLUJO DE NOTAS ---
        composable("new_note") {
            NewNoteScreen(navController, notesViewModel)
        }

        composable(
            route = "note_detail/{noteId}",
            arguments = listOf(navArgument("noteId") { type = NavType.StringType })
        ) { backStackEntry ->
            val noteId = backStackEntry.arguments?.getString("noteId") ?: ""
            NoteDetailScreen(navController, notesViewModel, noteId)
        }

        // --- FLUJO DE RECORDATORIOS ---
        composable("add_reminder") {
            AddReminderScreen(onBack = { navController.popBackStack() }, viewModel = remindersViewModel)
        }

        composable(
            route = "reminder_detail/{reminderId}",
            arguments = listOf(navArgument("reminderId") { type = NavType.StringType })
        ) { backStackEntry ->
            val reminderId = backStackEntry.arguments?.getString("reminderId") ?: ""
            ReminderDetailScreen(navController, remindersViewModel, reminderId)
        }

        composable(
            route = "edit_reminder/{reminderId}",
            arguments = listOf(navArgument("reminderId") { type = NavType.StringType })
        ) { backStackEntry ->
            val reminderId = backStackEntry.arguments?.getString("reminderId") ?: ""
            EditReminderScreen(onBack = { navController.popBackStack() }, viewModel = remindersViewModel, reminderId = reminderId)
        }
    }
}