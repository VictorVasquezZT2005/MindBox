package com.mindbox.app;

import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.firestore.FirebaseFirestore;

public class CertificateDetailActivity extends AppCompatActivity {

    private String certId;
    private Certificate currentCert;
    private FirebaseFirestore db;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_certificate_detail);

        db = FirebaseFirestore.getInstance();
        certId = getIntent().getStringExtra("CERT_ID");
        String userId = FirebaseAuth.getInstance().getUid();

        // Botón ATRÁS
        findViewById(R.id.btnBack).setOnClickListener(v -> finish());

        // BOTÓN EDITAR (Añadido para coincidir con el estilo Premium)
        findViewById(R.id.btnEditCert).setOnClickListener(v -> {
            if (certId != null) {
                // Aquí podrías abrir una nueva actividad: AddCertificateActivity enviando el ID
                // Intent i = new Intent(this, AddCertificateActivity.class);
                // i.putExtra("CERT_ID", certId);
                // startActivity(i);
                Toast.makeText(this, "Función de edición próximamente", Toast.LENGTH_SHORT).show();
            }
        });

        if (certId != null && userId != null) {
            db.collection("users").document(userId)
              .collection("certificates").document(certId)
              .get().addOnSuccessListener(doc -> {
                  if (doc.exists()) {
                      currentCert = doc.toObject(Certificate.class);
                      updateUI();
                  }
              }).addOnFailureListener(e -> {
                  Toast.makeText(this, "Error al cargar el detalle", Toast.LENGTH_SHORT).show();
              });
        }
    }

    private void updateUI() {
        if (currentCert == null) return;

        TextView tvTitle = findViewById(R.id.tvDetailTitle);
        TextView tvPlatform = findViewById(R.id.tvDetailPlatform);
        TextView tvFolio = findViewById(R.id.tvDetailFolio);
        TextView tvDate = findViewById(R.id.tvDetailDate);
        ImageView ivBadge = findViewById(R.id.ivDetailBadgeIcon);
        View badgeContainer = findViewById(R.id.badgeDetailContainer);
        View badgeGlow = findViewById(R.id.vBadgeGlow);

        tvTitle.setText(currentCert.getTitle());
        tvPlatform.setText(currentCert.getPlatform());
        tvFolio.setText(currentCert.getFolio() != null ? currentCert.getFolio() : "Sin folio registrado");
        tvDate.setText(currentCert.getIssueDate());

        // Lógica Premium de Colores (Estilo Mi Red Digital)
        int platformColor = Color.parseColor("#1e94f6");
        String p = currentCert.getPlatform() != null ? currentCert.getPlatform() : "";
        
        if (p.equalsIgnoreCase("Credly")) {
            platformColor = Color.parseColor("#2196F3");
        } else if (p.equalsIgnoreCase("Carlos Slim")) {
            platformColor = Color.parseColor("#4CAF50");
        } else if (p.equalsIgnoreCase("Udemy")) {
            platformColor = Color.parseColor("#A435F0");
        }

        // Aplicamos colores a los textos e iconos
        tvPlatform.setTextColor(platformColor);
        ivBadge.setColorFilter(platformColor);
        
        // Efecto GLOW dinámico (Brillo de fondo)
        if (badgeContainer.getBackground() != null) {
            badgeContainer.getBackground().setTint(platformColor);
            badgeContainer.getBackground().setAlpha(30); 
        }
        
        if (badgeGlow.getBackground() != null) {
            badgeGlow.getBackground().setTint(platformColor);
            badgeGlow.getBackground().setAlpha(50); // El brillo exterior es un poco más intenso
        }

        // Acción de ver PDF (Abrir en Navegador/Lector)
        findViewById(R.id.btnOpenPdf).setOnClickListener(v -> {
            if (currentCert.getPdfUrl() != null && !currentCert.getPdfUrl().isEmpty()) {
                try {
                    Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(currentCert.getPdfUrl()));
                    startActivity(intent);
                } catch (Exception e) {
                    Toast.makeText(this, "No se pudo abrir el enlace", Toast.LENGTH_SHORT).show();
                }
            } else {
                Toast.makeText(this, "No hay PDF adjunto a este logro", Toast.LENGTH_SHORT).show();
            }
        });
    }
}