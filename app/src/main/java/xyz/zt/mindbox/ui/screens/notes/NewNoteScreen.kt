package xyz.zt.mindbox.ui.dashboard.screens.notes

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NewNoteScreen(navController: NavController, viewModel: NotesViewModel) {
    // Estados separados para Título y Contenido
    var noteTitle by remember { mutableStateOf("") }
    var noteContent by remember { mutableStateOf("") }

    val colorScheme = MaterialTheme.colorScheme

    Scaffold(
        containerColor = colorScheme.surface,
        topBar = {
            CenterAlignedTopAppBar(
                title = {
                    Text(
                        "Nueva Nota",
                        style = MaterialTheme.typography.titleMedium.copy(
                            fontWeight = FontWeight.ExtraBold,
                            color = colorScheme.onSurface
                        )
                    )
                },
                navigationIcon = {
                    TextButton(onClick = { navController.popBackStack() }) {
                        Text("Cancelar", color = colorScheme.outline, fontSize = 16.sp)
                    }
                },
                actions = {
                    TextButton(onClick = {
                        if (noteContent.isNotBlank() || noteTitle.isNotBlank()) {
                            // Guardamos combinando título y contenido o como prefieras en tu ViewModel
                            val finalNote = if (noteTitle.isNotBlank()) "$noteTitle\n$noteContent" else noteContent
                            viewModel.addNote(finalNote)
                        }
                        navController.popBackStack()
                    }) {
                        Text(
                            "Listo",
                            color = colorScheme.primary,
                            fontWeight = FontWeight.ExtraBold,
                            fontSize = 18.sp
                        )
                    }
                },
                colors = TopAppBarDefaults.centerAlignedTopAppBarColors(containerColor = colorScheme.surface)
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
        ) {
            // --- PARTE DEL TÍTULO ---
            TextField(
                value = noteTitle,
                onValueChange = { noteTitle = it },
                placeholder = {
                    Text(
                        "Título de la nota",
                        style = MaterialTheme.typography.headlineSmall.copy(
                            fontWeight = FontWeight.Bold,
                            color = colorScheme.onSurface.copy(alpha = 0.4f)
                        )
                    )
                },
                modifier = Modifier.fillMaxWidth(),
                textStyle = MaterialTheme.typography.headlineSmall.copy(fontWeight = FontWeight.Bold),
                colors = TextFieldDefaults.colors(
                    focusedContainerColor = Color.Transparent,
                    unfocusedContainerColor = Color.Transparent,
                    focusedIndicatorColor = Color.Transparent,
                    unfocusedIndicatorColor = Color.Transparent,
                    cursorColor = colorScheme.primary
                ),
                maxLines = 1
            )

            // --- PARTE DEL TEXTO (CON LÍNEAS) ---
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .drawBehind {
                        val lineHeightPx = 38.sp.toPx()
                        var y = 0f // Empezamos desde arriba del Box
                        val lineStrokeColor = colorScheme.onSurface.copy(alpha = 0.1f)

                        while (y < size.height) {
                            drawLine(
                                color = lineStrokeColor,
                                start = Offset(0f, y),
                                end = Offset(size.width, y),
                                strokeWidth = 1.dp.toPx()
                            )
                            y += lineHeightPx
                        }
                    }
            ) {
                TextField(
                    value = noteContent,
                    onValueChange = { noteContent = it },
                    placeholder = {
                        Text(
                            "Empieza a escribir aquí...",
                            style = MaterialTheme.typography.bodyLarge.copy(
                                color = colorScheme.onSurface.copy(alpha = 0.4f)
                            )
                        )
                    },
                    modifier = Modifier.fillMaxSize(),
                    textStyle = MaterialTheme.typography.bodyLarge.copy(
                        fontSize = 19.sp,
                        lineHeight = 38.sp,
                        fontWeight = FontWeight.Medium,
                        color = colorScheme.onSurface
                    ),
                    colors = TextFieldDefaults.colors(
                        focusedContainerColor = Color.Transparent,
                        unfocusedContainerColor = Color.Transparent,
                        focusedIndicatorColor = Color.Transparent,
                        unfocusedIndicatorColor = Color.Transparent,
                        cursorColor = colorScheme.primary
                    )
                )
            }
        }
    }
}