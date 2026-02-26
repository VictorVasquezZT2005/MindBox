package com.mindbox.app;

import android.app.DatePickerDialog;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.StorageReference;

import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class AddCertificateActivity extends AppCompatActivity {

    private EditText etTitle, etFolio, etNotes;
    private TextView tvPdfName, tvSelectedDate;
    private Button btnSlim, btnCredly, btnOther;
    private Uri pdfUri;
    private String selectedPlatform = "Carlos Slim";
    private FirebaseFirestore db;
    private FirebaseStorage storage;
    private String userId;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_add_certificate);

        db = FirebaseFirestore.getInstance();
        storage = FirebaseStorage.getInstance();
        userId = FirebaseAuth.getInstance().getUid();

        etTitle = findViewById(R.id.etTitle);
        etFolio = findViewById(R.id.etFolio);
        etNotes = findViewById(R.id.etNotes);
        tvPdfName = findViewById(R.id.tvPdfName);
        tvSelectedDate = findViewById(R.id.tvSelectedDate);

        // Botones de Plataforma
        btnSlim = findViewById(R.id.btnPlatformSlim);
        btnCredly = findViewById(R.id.btnPlatformCredly);
        btnOther = findViewById(R.id.btnPlatformOther);

        btnSlim.setOnClickListener(v -> selectPlatform("Carlos Slim", btnSlim));
        btnCredly.setOnClickListener(v -> selectPlatform("Credly", btnCredly));
        btnOther.setOnClickListener(v -> selectPlatform("Otro", btnOther));

        findViewById(R.id.btnSelectDate).setOnClickListener(v -> showDatePicker());
        findViewById(R.id.btnClose).setOnClickListener(v -> finish());
        findViewById(R.id.btnSelectPdf).setOnClickListener(v -> selectPdf());
        findViewById(R.id.btnSave).setOnClickListener(v -> saveCertificate());
    }

    private void selectPlatform(String platform, Button selectedBtn) {
        selectedPlatform = platform;
        // Reset colores
        int normalColor = ContextCompat.getColor(this, R.color.surface_dark);
        int activeColor = ContextCompat.getColor(this, R.color.brand_primary);
        
        btnSlim.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.surface_dark));
        btnCredly.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.surface_dark));
        btnOther.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.surface_dark));

        // Activar el seleccionado
        selectedBtn.setBackgroundTintList(ContextCompat.getColorStateList(this, R.color.brand_primary));
    }

    private void showDatePicker() {
        final Calendar c = Calendar.getInstance();
        new DatePickerDialog(this, (view, y, m, d) -> {
            String date = d + "/" + (m + 1) + "/" + y;
            tvSelectedDate.setText(date);
            tvSelectedDate.setTextColor(Color.WHITE);
        }, c.get(Calendar.YEAR), c.get(Calendar.MONTH), c.get(Calendar.DAY_OF_MONTH)).show();
    }

    private void selectPdf() {
        Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        intent.setType("application/pdf");
        startActivityForResult(intent, 101);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == 101 && resultCode == RESULT_OK && data != null) {
            pdfUri = data.getData();
            tvPdfName.setText("PDF Seleccionado");
        }
    }

    private void saveCertificate() {
        String title = etTitle.getText().toString().trim();
        if (title.isEmpty()) return;

        String certId = UUID.randomUUID().toString();
        if (pdfUri != null) {
            StorageReference ref = storage.getReference().child("users/" + userId + "/certificates/" + certId + ".pdf");
            ref.putFile(pdfUri).addOnSuccessListener(task -> {
                ref.getDownloadUrl().addOnSuccessListener(uri -> saveToFirestore(certId, title, uri.toString()));
            });
        } else {
            saveToFirestore(certId, title, null);
        }
    }

    private void saveToFirestore(String id, String title, String pdfUrl) {
        Map<String, Object> cert = new HashMap<>();
        cert.put("id", id);
        cert.put("title", title);
        cert.put("platform", selectedPlatform);
        cert.put("issueDate", tvSelectedDate.getText().toString());
        cert.put("folio", etFolio.getText().toString());
        cert.put("notes", etNotes.getText().toString());
        cert.put("pdfUrl", pdfUrl);

        db.collection("users").document(userId).collection("certificates").document(id)
          .set(cert).addOnSuccessListener(aVoid -> {
              Toast.makeText(this, "Guardado", Toast.LENGTH_SHORT).show();
              finish();
          });
    }
}