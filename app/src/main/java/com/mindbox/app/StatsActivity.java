package com.mindbox.app;

import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.firestore.FirebaseFirestore;

public class StatsActivity extends AppCompatActivity {

    private FirebaseFirestore db;
    private String userId;
    private int nNotes = 0, nPass = 0, nCerts = 0;
    private TextView tvStatusTitle;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_stats); // Usaremos el mismo XML que tenías

        db = FirebaseFirestore.getInstance();
        userId = FirebaseAuth.getInstance().getUid();

        tvStatusTitle = findViewById(R.id.tvStatusTitle);

        // Configuración de las filas con tus iconos
        setupStatRow(findViewById(R.id.statNotes), "Notas", "Ver mis notas guardadas", R.drawable.notes_24);
        setupStatRow(findViewById(R.id.statCerts), "Certificados", "Acceso a credenciales", R.drawable.school_24);
        setupStatRow(findViewById(R.id.statPasswords), "Contraseñas", "Gestión segura de llaves", R.drawable.lock_24);
        setupStatRow(findViewById(R.id.statReminders), "Recordatorios", "Alertas programadas", R.drawable.reminder_24);

        // Botón opcional para volver atrás (puedes añadir un ID btnBack al XML si quieres)
        View btnBack = findViewById(R.id.btnBack);
        if (btnBack != null) btnBack.setOnClickListener(v -> finish());

        if (userId != null) fetchCounts();
    }

    private void setupStatRow(View row, String label, String desc, int iconRes) {
        if (row == null) return;
        ((TextView) row.findViewById(R.id.tvStatLabel)).setText(label);
        ((TextView) row.findViewById(R.id.tvStatDescription)).setText(desc);
        ImageView iv = row.findViewById(R.id.ivStatIcon);
        iv.setImageResource(iconRes);
    }

    private void fetchCounts() {
        // Conteo de Notas
        db.collection("users").document(userId).collection("notes").get().addOnSuccessListener(s -> {
            nNotes = s.size();
            updateUI(R.id.statNotes, nNotes);
            actualizarResumen();
        });

        // Conteo de Contraseñas
        db.collection("users").document(userId).collection("passwords").get().addOnSuccessListener(s -> {
            nPass = s.size();
            updateUI(R.id.statPasswords, nPass);
            actualizarResumen();
        });

        // Conteo de Certificados (Añadido para completar tu red)
        db.collection("users").document(userId).collection("certificates").get().addOnSuccessListener(s -> {
            nCerts = s.size();
            updateUI(R.id.statCerts, nCerts);
            actualizarResumen();
        });
    }

    private void updateUI(int rowId, int value) {
        View row = findViewById(rowId);
        if (row != null) {
            ((TextView) row.findViewById(R.id.tvStatValue)).setText(String.valueOf(value));
        }
    }

    private void actualizarResumen() {
        int total = nNotes + nPass + nCerts;
        if (tvStatusTitle != null) {
            tvStatusTitle.setText("Red Sincronizada: " + total + " nodos");
        }
    }
}