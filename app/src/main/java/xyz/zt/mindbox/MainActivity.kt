package xyz.zt.mindbox

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.google.firebase.auth.FirebaseAuth
import xyz.zt.mindbox.ui.login.LoginScreen
import xyz.zt.mindbox.ui.theme.MindBoxTheme
import xyz.zt.mindbox.ui.nav.BottomNavItem
import xyz.zt.mindbox.ui.dashboard.screens.notes.*
import xyz.zt.mindbox.ui.dashboard.screens.passwords.PasswordsScreen
import xyz.zt.mindbox.ui.dashboard.screens.reminders.RemindersScreen
import xyz.zt.mindbox.ui.dashboard.screens.dashboard.DashboardScreen

class MainActivity : ComponentActivity() {
    private val auth by lazy { FirebaseAuth.getInstance() }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MindBoxTheme {
                val navController = rememberNavController()
                val notesViewModel: NotesViewModel = viewModel()
                var isLoggedIn by remember { mutableStateOf(auth.currentUser != null) }

                val navBackStackEntry by navController.currentBackStackEntryAsState()
                val currentRoute = navBackStackEntry?.destination?.route

                if (!isLoggedIn) {
                    LoginScreen(onLoginSuccess = { isLoggedIn = true })
                } else {
                    Scaffold(
                        bottomBar = {
                            val mainRoutes = listOf(
                                BottomNavItem.Dashboard.route,
                                BottomNavItem.Notes.route,
                                BottomNavItem.Reminders.route,
                                BottomNavItem.Passwords.route
                            )
                            if (currentRoute in mainRoutes) {
                                NavigationBar {
                                    val tabs = listOf(
                                        BottomNavItem.Dashboard,
                                        BottomNavItem.Notes,
                                        BottomNavItem.Reminders,
                                        BottomNavItem.Passwords
                                    )
                                    tabs.forEach { tab ->
                                        NavigationBarItem(
                                            icon = { Icon(tab.icon, contentDescription = tab.title) },
                                            label = { Text(tab.title) },
                                            selected = currentRoute == tab.route,
                                            onClick = {
                                                navController.navigate(tab.route) {
                                                    popUpTo(navController.graph.findStartDestination().id) {
                                                        saveState = true
                                                    }
                                                    launchSingleTop = true
                                                    restoreState = true
                                                }
                                            }
                                        )
                                    }
                                }
                            }
                        }
                    ) { padding ->
                        NavHost(
                            navController = navController,
                            startDestination = BottomNavItem.Dashboard.route,
                            modifier = Modifier.padding(padding)
                        ) {
                            composable(BottomNavItem.Dashboard.route) {
                                DashboardScreen(navController, notesViewModel) {
                                    auth.signOut()
                                    isLoggedIn = false
                                }
                            }
                            composable(BottomNavItem.Notes.route) {
                                NotesScreen(navController, notesViewModel)
                            }
                            composable(BottomNavItem.Reminders.route) {
                                RemindersScreen()
                            }
                            composable(BottomNavItem.Passwords.route) {
                                PasswordsScreen()
                            }
                            composable("new_note") {
                                NewNoteScreen(navController, notesViewModel)
                            }
                        }
                    }
                }
            }
        }
    }
}