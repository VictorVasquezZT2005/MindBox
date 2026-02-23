package com.mindbox.app;

import android.os.Bundle;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.firestore.FirebaseFirestore;
import java.util.HashMap;
import java.util.Map;

public class RegisterActivity extends AppCompatActivity {
    private FirebaseAuth mAuth;
    private FirebaseFirestore db;
    private EditText etName, etEmail, etPassword;
    private Button btnRegister;
    private TextView tvToLogin; // 1. Declarar la variable para el texto de abajo

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_register);

        mAuth = FirebaseAuth.getInstance();
        db = FirebaseFirestore.getInstance();

        // 2. Vincular con el ID del XML
        etName = findViewById(R.id.etRegName);
        etEmail = findViewById(R.id.etRegEmail);
        etPassword = findViewById(R.id.etRegPassword);
        btnRegister = findViewById(R.id.btnRegister);
        tvToLogin = findViewById(R.id.tvToLogin); 

        // 3. Listener para el botón "Inicia sesión"
        tvToLogin.setOnClickListener(v -> {
            // Esto cierra la pantalla de registro y vuelve a la anterior (MainActivity/Login)
            finish();
        });

        // Listener para el botón de Registro
        btnRegister.setOnClickListener(v -> {
            String name = etName.getText().toString().trim();
            String email = etEmail.getText().toString().trim();
            String password = etPassword.getText().toString();

            if (name.isEmpty() || email.isEmpty() || password.length() < 6) {
                Toast.makeText(this, "Completa los datos (Password mín. 6 car.)", Toast.LENGTH_SHORT).show();
                return;
            }

            // Deshabilitar botón para evitar múltiples registros accidentales
            btnRegister.setEnabled(false);

            mAuth.createUserWithEmailAndPassword(email, password)
                .addOnSuccessListener(authResult -> {
                    String uid = authResult.getUser().getUid();
                    Map<String, Object> user = new HashMap<>();
                    user.put("name", name);
                    user.put("email", email);

                    db.collection("users").document(uid).set(user)
                        .addOnSuccessListener(aVoid -> {
                            Toast.makeText(this, "¡Registro exitoso!", Toast.LENGTH_SHORT).show();
                            finish(); // Regresa al login o podrías enviar al Dashboard
                        });
                })
                .addOnFailureListener(e -> {
                    btnRegister.setEnabled(true);
                    Toast.makeText(this, "Error: " + e.getMessage(), Toast.LENGTH_SHORT).show();
                });
        });
    }
}