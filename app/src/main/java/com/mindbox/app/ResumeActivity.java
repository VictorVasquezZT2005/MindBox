package com.mindbox.app;

import android.os.Bundle;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;

public class ResumeActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_resume);

        // Aquí conectarías todos los campos (Nombre, Universidad, Experiencia)
        // basándote en tu lógica de Compose.
        
        findViewById(R.id.btnGeneratePdf).setOnClickListener(v -> {
            Toast.makeText(this, "Generando PDF en Descargas...", Toast.LENGTH_LONG).show();
            // Aquí llamarías a una clase "ResumeHelper" para crear el PDF
        });
        
        findViewById(R.id.btnBackResume).setOnClickListener(v -> finish());
    }
}