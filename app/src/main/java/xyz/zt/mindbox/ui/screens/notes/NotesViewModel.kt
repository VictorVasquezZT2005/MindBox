package xyz.zt.mindbox.ui.dashboard.screens.notes

import androidx.compose.runtime.mutableStateListOf
import androidx.lifecycle.ViewModel

class NotesViewModel : ViewModel() {
    // Lista de notas observable
    private val _notes = mutableStateListOf<String>()
    val notes: List<String> get() = _notes

    fun addNote(content: String) {
        if (content.isNotBlank()) {
            _notes.add(0, content) // Nueva nota arriba
        }
    }
}
