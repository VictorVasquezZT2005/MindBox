package com.mindbox.app;

import android.app.DatePickerDialog;
import android.content.Intent;
import android.content.res.ColorStateList;
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
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.StorageReference;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class AddCertificateActivity extends AppCompatActivity {

    private EditText etTitle, etFolio, etNotes, etCustomPlatform;
    private TextView tvPdfName, tvSelectedDate, tvFolioLabel;
    private Button btnSlim, btnCredly, btnOther;
    private Uri pdfUri;
    private String platformType = "Carlos Slim"; // Default

    private FirebaseFirestore db;
    private FirebaseStorage storage;
    private String userId;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_add_certificate);

        // Firebase Setup
        db = FirebaseFirestore.getInstance();
        storage = FirebaseStorage.getInstance();
        userId = FirebaseAuth.getInstance().getUid();

        // Bind Views
        etTitle = findViewById(R.id.etTitle);
        etFolio = findViewById(R.id.etFolio);
        etNotes = findViewById(R.id.etNotes);
        etCustomPlatform = findViewById(R.id.etCustomPlatform);
        tvPdfName = findViewById(R.id.tvPdfName);
        tvSelectedDate = findViewById(R.id.tvSelectedDate);
        tvFolioLabel = findViewById(R.id.tvFolioLabel);

        btnSlim = findViewById(R.id.btnPlatformSlim);
        btnCredly = findViewById(R.id.btnPlatformCredly);
        btnOther = findViewById(R.id.btnPlatformOther);

        // Click Listeners (Behavior de FilterChips)
        btnSlim.setOnClickListener(v ->
            updateUIForPlatform("Carlos Slim", btnSlim)
        );
        btnCredly.setOnClickListener(v ->
            updateUIForPlatform("Credly", btnCredly)
        );
        btnOther.setOnClickListener(v -> updateUIForPlatform("Otro", btnOther));

        // Botones de acción
        findViewById(R.id.btnSelectDate).setOnClickListener(v ->
            showDatePicker()
        );
        findViewById(R.id.btnSelectPdf).setOnClickListener(v -> selectPdf());
        findViewById(R.id.btnClose).setOnClickListener(v -> finish());
        findViewById(R.id.btnSave).setOnClickListener(v -> saveCertificate());

        // Estado inicial
        updateUIForPlatform("Carlos Slim", btnSlim);
    }

    private void updateUIForPlatform(String platform, Button selectedBtn) {
        this.platformType = platform;

        // 1. Visibilidad del campo extra (Como el 'if' en Compose)
        etCustomPlatform.setVisibility(
            platform.equals("Otro") ? View.VISIBLE : View.GONE
        );

        // 2. Dinamismo de labels y hints
        if (platform.equals("Credly")) {
            tvFolioLabel.setText("ID de Credly / Badge URL");
            etFolio.setHint("Ej. https://credly.com/...");
        } else {
            tvFolioLabel.setText("Folio de Certificado");
            etFolio.setHint("ID-0000-X");
        }

        // 3. Estilo visual de los botones (Chips)
        Button[] allButtons = { btnSlim, btnCredly, btnOther };
        for (Button b : allButtons) {
            if (b == selectedBtn) {
                b.setBackgroundTintList(
                    ColorStateList.valueOf(Color.parseColor("#1A1e94f6"))
                );
                b.setTextColor(Color.parseColor("#1e94f6"));
            } else {
                b.setBackgroundTintList(
                    ColorStateList.valueOf(Color.TRANSPARENT)
                );
                b.setTextColor(Color.parseColor("#94a3b8"));
            }
        }
    }

    private void showDatePicker() {
        Calendar c = Calendar.getInstance();
        new DatePickerDialog(
            this,
            (view, year, month, day) -> {
                String date = day + "/" + (month + 1) + "/" + year;
                tvSelectedDate.setText(date);
                tvSelectedDate.setTextColor(Color.WHITE);
            },
            c.get(Calendar.YEAR),
            c.get(Calendar.MONTH),
            c.get(Calendar.DAY_OF_MONTH)
        )
            .show();
    }

    private void selectPdf() {
        Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        intent.setType("application/pdf");
        startActivityForResult(intent, 101);
    }

    @Override
    protected void onActivityResult(
        int requestCode,
        int resultCode,
        @Nullable Intent data
    ) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == 101 && resultCode == RESULT_OK && data != null) {
            pdfUri = data.getData();
            tvPdfName.setText("PDF Seleccionado");
            tvPdfName.setTextColor(Color.parseColor("#1e94f6"));
        }
    }

    private void saveCertificate() {
        String title = etTitle.getText().toString().trim();
        if (title.isEmpty()) {
            Toast.makeText(
                this,
                "Título obligatorio",
                Toast.LENGTH_SHORT
            ).show();
            return;
        }

        // Determinar plataforma final (Como en tu código Compose)
        String finalPlatform = platformType.equals("Otro")
            ? etCustomPlatform.getText().toString().trim()
            : platformType;

        String certId = UUID.randomUUID().toString();

        if (pdfUri != null) {
            // Formato de nombre: titulo_curso_abcde.pdf
            String cleanTitle = title.replace(" ", "_").toLowerCase();
            String fileName =
                cleanTitle + "_" + certId.substring(0, 5) + ".pdf";

            StorageReference ref = storage
                .getReference()
                .child("users/" + userId + "/certificates/" + fileName);
            ref
                .putFile(pdfUri)
                .addOnSuccessListener(taskSnapshot -> {
                    ref
                        .getDownloadUrl()
                        .addOnSuccessListener(uri -> {
                            writeToFirestore(
                                certId,
                                title,
                                finalPlatform,
                                uri.toString()
                            );
                        });
                })
                .addOnFailureListener(e ->
                    Toast.makeText(
                        this,
                        "Error Storage",
                        Toast.LENGTH_SHORT
                    ).show()
                );
        } else {
            writeToFirestore(certId, title, finalPlatform, null);
        }
    }

    private void writeToFirestore(
        String id,
        String title,
        String platform,
        String pdfUrl
    ) {
        Map<String, Object> cert = new HashMap<>();
        cert.put("id", id);
        cert.put("title", title);
        cert.put("platform", platform);
        cert.put(
            "issueDate",
            tvSelectedDate.getText().toString().equals("Seleccionar fecha")
                ? ""
                : tvSelectedDate.getText().toString()
        );
        cert.put("folio", etFolio.getText().toString());
        cert.put("notes", etNotes.getText().toString());
        cert.put("pdfUrl", pdfUrl);
        cert.put("timestamp", System.currentTimeMillis());

        db
            .collection("users")
            .document(userId)
            .collection("certificates")
            .document(id)
            .set(cert)
            .addOnSuccessListener(aVoid -> {
                Toast.makeText(
                    this,
                    "Logro guardado",
                    Toast.LENGTH_SHORT
                ).show();
                finish();
            });
    }
}
