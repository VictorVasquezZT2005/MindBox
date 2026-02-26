package com.mindbox.app;

import android.os.Bundle;
import android.widget.EditText;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.firestore.FirebaseFirestore;
import java.util.HashMap;
import java.util.Map;

public class EditProfileActivity extends AppCompatActivity {

    private EditText etFullName, etEmail;
    private FirebaseFirestore db;
    private String userId;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_edit_profile);

        db = FirebaseFirestore.getInstance();
        userId = FirebaseAuth.getInstance().getUid();

        // Vinculamos solo los campos que quedaron en el XML
        etFullName = findViewById(R.id.etFullName);
        etEmail = findViewById(R.id.etEmail);

        // Configuración de botones
        findViewById(R.id.btnBack).setOnClickListener(v -> finish());
        findViewById(R.id.btnSaveChanges).setOnClickListener(v -> guardarDatos());

        cargarDatosActuales();
    }

    private void cargarDatosActuales() {
        if (userId == null) return;

        db.collection("users").document(userId).get().addOnSuccessListener(doc -> {
            if (doc.exists()) {
                // Recuperamos el nombre de Firestore
                etFullName.setText(doc.getString("name"));
                
                // El email lo tomamos directamente de Firebase Auth para mayor seguridad
                if (FirebaseAuth.getInstance().getCurrentUser() != null) {
                    etEmail.setText(FirebaseAuth.getInstance().getCurrentUser().getEmail());
                }
            }
        }).addOnFailureListener(e -> {
            Toast.makeText(this, "Error al cargar datos", Toast.LENGTH_SHORT).show();
        });
    }

    private void guardarDatos() {
        String name = etFullName.getText().toString().trim();

        // Validamos que el nombre no esté vacío
        if (name.isEmpty()) {
            Toast.makeText(this, "Por favor, ingresa tu nombre", Toast.LENGTH_SHORT).show();
            return;
        }

        // Preparamos los datos para actualizar en Firestore
        Map<String, Object> userUpdate = new HashMap<>();
        userUpdate.put("name", name);
        // Nota: El email generalmente no se cambia así en Firebase Auth, 
        // por ahora solo actualizamos el nombre en la base de datos.

        db.collection("users").document(userId).update(userUpdate)
            .addOnSuccessListener(aVoid -> {
                Toast.makeText(this, "Perfil actualizado correctamente", Toast.LENGTH_SHORT).show();
                // Cerramos la actividad para volver al ProfileFragment
                finish();
            })
            .addOnFailureListener(e -> {
                Toast.makeText(this, "Error al actualizar: " + e.getMessage(), Toast.LENGTH_SHORT).show();
            });
    }
}