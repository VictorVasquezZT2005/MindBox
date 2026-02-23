package com.mindbox.app;

import android.os.Bundle;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import com.google.firebase.auth.FirebaseAuth;

public class ForgotPasswordActivity extends AppCompatActivity {
    private FirebaseAuth mAuth;
    private EditText etEmail;
    private Button btnSend;
    private ImageButton btnBack;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // Asegúrate de que el nombre del layout coincida con el que creamos
        setContentView(R.layout.activity_forgot_password);

        // 1. Inicializar Firebase
        mAuth = FirebaseAuth.getInstance();

        // 2. Vincular vistas del nuevo diseño
        etEmail = findViewById(R.id.etForgotEmail);
        btnSend = findViewById(R.id.btnSendEmail);
        btnBack = findViewById(R.id.btnBack);

        // 3. Lógica del botón de retroceder (Ajuste para navegación fluida)
        if (btnBack != null) {
            btnBack.setOnClickListener(v -> finish());
        }

        // 4. Lógica de envío de correo
        btnSend.setOnClickListener(v -> {
            String email = etEmail.getText().toString().trim();

            if (email.isEmpty()) {
                Toast.makeText(this, "Por favor, ingresa tu correo", Toast.LENGTH_SHORT).show();
                return;
            }

            // Deshabilitar botón para evitar múltiples clics
            btnSend.setEnabled(false);

            mAuth.sendPasswordResetEmail(email)
                .addOnCompleteListener(task -> {
                    btnSend.setEnabled(true); // Re-habilitar
                    if (task.isSuccessful()) {
                        Toast.makeText(this, "📧 Enlace enviado. Revisa tu bandeja de entrada", Toast.LENGTH_LONG).show();
                        finish(); // Regresar al Login automáticamente
                    } else {
                        String error = task.getException() != null ? task.getException().getMessage() : "Error desconocido";
                        Toast.makeText(this, "Error: " + error, Toast.LENGTH_LONG).show();
                    }
                });
        });
    }
}