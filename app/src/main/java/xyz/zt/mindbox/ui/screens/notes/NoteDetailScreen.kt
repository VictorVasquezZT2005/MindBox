package xyz.zt.mindbox.ui.dashboard.screens.notes

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Done
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
fun NoteDetailScreen(navController: NavController, viewModel: NotesViewModel, noteId: String) {
    val note = viewModel.notes.find { it.id == noteId } ?: return
    val colorScheme = MaterialTheme.colorScheme

    val lines = note.content.lines()
    var title by remember { mutableStateOf(lines.firstOrNull() ?: "") }
    var content by remember { mutableStateOf(if (lines.size > 1) lines.drop(1).joinToString("\n") else "") }
    var type by remember { mutableStateOf(note.type) }
    val types = listOf("Personal", "Trabajo", "Idea", "Urgente")

    Scaffold(
        topBar = {
            CenterAlignedTopAppBar(
                title = { Text("Editar Nota", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.Default.Close, contentDescription = "Cerrar")
                    }
                },
                actions = {
                    IconButton(onClick = {
                        val fullText = if (title.isNotBlank()) "$title\n$content" else content
                        viewModel.updateNote(noteId, fullText, type) { success ->
                            if (success) navController.popBackStack()
                        }
                    }) {
                        Icon(Icons.Default.Done, contentDescription = "Guardar", tint = colorScheme.primary)
                    }
                }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .background(colorScheme.surface)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth().padding(8.dp),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                types.forEach { t ->
                    val selectedChipColor = when (t) {
                        "Trabajo" -> Color(0xFF2196F3)
                        "Idea" -> Color(0xFF8BC34A)
                        "Urgente" -> Color(0xFFF44336)
                        "Personal" -> Color(0xFFFF9800)
                        else -> colorScheme.primary
                    }

                    FilterChip(
                        selected = type == t,
                        onClick = { type = t },
                        label = { Text(t) },
                        colors = FilterChipDefaults.filterChipColors(
                            selectedContainerColor = selectedChipColor,
                            selectedLabelColor = Color.White
                        )
                    )
                }
            }

            TextField(
                value = title,
                onValueChange = { title = it },
                placeholder = { Text("Título") },
                modifier = Modifier.fillMaxWidth(),
                textStyle = MaterialTheme.typography.headlineSmall.copy(fontWeight = FontWeight.Bold),
                colors = TextFieldDefaults.colors(
                    focusedContainerColor = Color.Transparent,
                    unfocusedContainerColor = Color.Transparent,
                    focusedIndicatorColor = Color.Transparent,
                    unfocusedIndicatorColor = Color.Transparent
                )
            )

            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .drawBehind {
                        val step = 38.sp.toPx()
                        val lineColor = colorScheme.onSurface.copy(alpha = 0.1f)
                        var y = 0f
                        while (y < size.height) {
                            drawLine(lineColor, Offset(0f, y), Offset(size.width, y), 1.dp.toPx())
                            y += step
                        }
                    }
            ) {
                TextField(
                    value = content,
                    onValueChange = { content = it },
                    modifier = Modifier.fillMaxSize(),
                    textStyle = MaterialTheme.typography.bodyLarge.copy(lineHeight = 38.sp),
                    colors = TextFieldDefaults.colors(
                        focusedContainerColor = Color.Transparent,
                        unfocusedContainerColor = Color.Transparent,
                        focusedIndicatorColor = Color.Transparent,
                        unfocusedIndicatorColor = Color.Transparent
                    )
                )
            }
        }
    }
}