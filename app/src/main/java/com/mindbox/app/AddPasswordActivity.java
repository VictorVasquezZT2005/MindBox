package com.mindbox.app;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Size;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.camera.core.CameraSelector;
import androidx.camera.core.ImageAnalysis;
import androidx.camera.core.Preview;
import androidx.camera.lifecycle.ProcessCameraProvider;
import androidx.camera.view.PreviewView;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.google.common.util.concurrent.ListenableFuture;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.mlkit.vision.barcode.BarcodeScanner;
import com.google.mlkit.vision.barcode.BarcodeScanning;
import com.google.mlkit.vision.common.InputImage;

import java.util.concurrent.ExecutionException;

public class AddPasswordActivity extends AppCompatActivity {

    private PreviewView previewView;
    private EditText etServiceName, etAccountEmail, etSecretKey; // Agregado etAccountEmail
    private Button btnSave;
    private FirebaseFirestore db;
    private String userId;
    
    // Bandera para evitar que el escáner dispare múltiples guardados a la vez
    private boolean isScanning = true;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_add_password);

        db = FirebaseFirestore.getInstance();
        userId = FirebaseAuth.getInstance().getUid();

        previewView = findViewById(R.id.previewView);
        etServiceName = findViewById(R.id.etServiceName);
        etAccountEmail = findViewById(R.id.etAccountEmail); // Vinculado
        etSecretKey = findViewById(R.id.etSecretKey);
        btnSave = findViewById(R.id.btnSave);

        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) 
                != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.CAMERA}, 101);
        } else {
            iniciarCamara();
        }

        btnSave.setOnClickListener(v -> guardarLlave(
                etServiceName.getText().toString().trim(),
                etAccountEmail.getText().toString().trim(),
                etSecretKey.getText().toString().trim()
        ));
    }

    private void iniciarCamara() {
        ListenableFuture<ProcessCameraProvider> cameraProviderFuture = 
                ProcessCameraProvider.getInstance(this);

        cameraProviderFuture.addListener(() -> {
            try {
                ProcessCameraProvider cameraProvider = cameraProviderFuture.get();
                
                Preview preview = new Preview.Builder().build();
                preview.setSurfaceProvider(previewView.getSurfaceProvider());

                BarcodeScanner scanner = BarcodeScanning.getClient();

                ImageAnalysis imageAnalysis = new ImageAnalysis.Builder()
                        .setTargetResolution(new Size(1280, 720))
                        .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                        .build();

                imageAnalysis.setAnalyzer(ContextCompat.getMainExecutor(this), image -> {
                    if (!isScanning) {
                        image.close();
                        return;
                    }

                    @SuppressWarnings("UnsafeOptInUsageError")
                    InputImage inputImage = InputImage.fromMediaImage(
                            image.getImage(), image.getImageInfo().getRotationDegrees());

                    scanner.process(inputImage)
                            .addOnSuccessListener(barcodes -> {
                                if (barcodes.size() > 0 && isScanning) {
                                    isScanning = false; // Pausamos escaneo
                                    String rawValue = barcodes.get(0).getRawValue();
                                    procesarQR(rawValue);
                                }
                            })
                            .addOnCompleteListener(task -> image.close());
                });

                cameraProvider.bindToLifecycle(this, CameraSelector.DEFAULT_BACK_CAMERA, preview, imageAnalysis);

            } catch (ExecutionException | InterruptedException e) {
                e.printStackTrace();
            }
        }, ContextCompat.getMainExecutor(this));
    }

    private void procesarQR(String data) {
        String[] info = TOTPHelper.parseQrCode(data);
        if (info != null) {
            // Llenamos los campos para que el usuario vea qué se escaneó
            etServiceName.setText(info[0]);
            etAccountEmail.setText(info[1]);
            etSecretKey.setText(info[2]);
            
            // Guardamos automáticamente
            guardarLlave(info[0], info[1], info[2]);
        } else {
            Toast.makeText(this, "QR no válido para 2FA", Toast.LENGTH_SHORT).show();
            isScanning = true; // Reintentar si falló
        }
    }

    private void guardarLlave(String servicio, String cuenta, String llave) {
        if (servicio.isEmpty() || llave.isEmpty()) {
            Toast.makeText(this, "Servicio y Llave son obligatorios", Toast.LENGTH_SHORT).show();
            isScanning = true;
            return;
        }

        Password newPass = new Password(servicio, cuenta, llave);
        db.collection("users").document(userId)
                .collection("passwords").document(newPass.getId())
                .set(newPass)
                .addOnSuccessListener(aVoid -> {
                    Toast.makeText(this, "Llave vinculada con éxito", Toast.LENGTH_SHORT).show();
                    finish();
                })
                .addOnFailureListener(e -> {
                    Toast.makeText(this, "Error al guardar", Toast.LENGTH_SHORT).show();
                    isScanning = true;
                });
    }
}