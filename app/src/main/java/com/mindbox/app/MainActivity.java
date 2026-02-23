package com.mindbox.app;

import android.content.Intent;
import android.os.Bundle;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;

public class MainActivity extends AppCompatActivity {

    private FirebaseAuth mAuth;
    private EditText etEmail, etPassword;
    private Button btnLogin;
    private TextView tvRegister, tvForgot;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // 1. Inicializar Firebase
        try {
            mAuth = FirebaseAuth.getInstance();
        } catch (Exception e) {
            Toast.makeText(this, "Error al conectar con Firebase", Toast.LENGTH_LONG).show();
        }

        // 2. Auto-login si ya existe sesión
        if (mAuth != null && mAuth.getCurrentUser() != null) {
            irAlDashboard();
            return;
        }

        setContentView(R.layout.activity_login);

        // 3. Vincular Vistas
        etEmail = findViewById(R.id.etEmail);
        etPassword = findViewById(R.id.etPassword);
        btnLogin = findViewById(R.id.btnLogin);
        tvRegister = findViewById(R.id.tvRegister);
        tvForgot = findViewById(R.id.tvForgot);

        // 4. Listeners
        btnLogin.setOnClickListener(v -> loginUser());

        tvRegister.setOnClickListener(v -> {
            startActivity(new Intent(MainActivity.this, RegisterActivity.class));
        });

        if (tvForgot != null) {
            tvForgot.setOnClickListener(v -> {
                startActivity(new Intent(MainActivity.this, ForgotPasswordActivity.class));
            });
        }
    }

    private void loginUser() {
        String email = etEmail.getText().toString().trim();
        String password = etPassword.getText().toString();

        if (email.isEmpty() || password.isEmpty()) {
            Toast.makeText(this, "Campos obligatorios", Toast.LENGTH_SHORT).show();
            return;
        }

        mAuth.signInWithEmailAndPassword(email, password)
            .addOnCompleteListener(this, task -> {
                if (task.isSuccessful()) {
                    Toast.makeText(MainActivity.this, "Bienvenido 🚀", Toast.LENGTH_SHORT).show();
                    irAlDashboard();
                } else {
                    Toast.makeText(MainActivity.this, "Fallo: " + task.getException().getMessage(), Toast.LENGTH_LONG).show();
                }
            });
    }

    private void irAlDashboard() {
        Intent intent = new Intent(MainActivity.this, DashboardActivity.class);
        startActivity(intent);
        finish();
    }
}