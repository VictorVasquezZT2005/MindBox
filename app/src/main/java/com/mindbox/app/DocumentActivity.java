package com.mindbox.app;

import android.Manifest;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.pdf.PdfDocument;
import android.media.MediaScannerConnection;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.view.View;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.Toast;
import androidx.activity.result.ActivityResultLauncher;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import com.canhub.cropper.CropImageContract;
import com.canhub.cropper.CropImageContractOptions;
import com.canhub.cropper.CropImageOptions;
import com.canhub.cropper.CropImageView;
import com.google.android.material.button.MaterialButton;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;

public class DocumentActivity extends AppCompatActivity {

    private Uri frontUri, backUri;
    private boolean isCapturingFront = true;
    private ImageView previewFront, previewBack, imgCheckFront, imgCheckBack;
    private MaterialButton btnGeneratePdf;
    private ProgressBar loadingProgress;

    private final CropImageOptions cropOptions = new CropImageOptions();

    private final ActivityResultLauncher<
        CropImageContractOptions
    > cropImageLauncher = registerForActivityResult(
        new CropImageContract(),
        result -> {
            if (result.isSuccessful()) {
                Uri uri = result.getUriContent();
                if (isCapturingFront) {
                    frontUri = uri;
                    previewFront.setImageURI(uri);
                    imgCheckFront.setVisibility(View.VISIBLE);
                } else {
                    backUri = uri;
                    previewBack.setImageURI(uri);
                    imgCheckBack.setVisibility(View.VISIBLE);
                }
                validateButtons();
            } else if (result.getError() != null) {
                Toast.makeText(
                    this,
                    "Error: " + result.getError().getMessage(),
                    Toast.LENGTH_SHORT
                ).show();
            }
        }
    );

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_document);

        initViews();
        setupCropOptions();

        findViewById(R.id.btnBack).setOnClickListener(v -> finish());

        findViewById(R.id.cardFront).setOnClickListener(v -> {
            isCapturingFront = true;
            checkPermissionAndLaunch();
        });

        findViewById(R.id.cardBack).setOnClickListener(v -> {
            isCapturingFront = false;
            checkPermissionAndLaunch();
        });

        btnGeneratePdf.setOnClickListener(v -> generatePdf());
    }

    private void initViews() {
        previewFront = findViewById(R.id.previewFront);
        previewBack = findViewById(R.id.previewBack);
        imgCheckFront = findViewById(R.id.imgCheckFront);
        imgCheckBack = findViewById(R.id.imgCheckBack);
        btnGeneratePdf = findViewById(R.id.btnGeneratePdf);
        loadingProgress = findViewById(R.id.loadingProgress);
    }

    private void setupCropOptions() {
        cropOptions.imageSourceIncludeGallery = true;
        cropOptions.imageSourceIncludeCamera = true;
        cropOptions.guidelines = CropImageView.Guidelines.ON;

        // Configuración de interfaz de recorte
        cropOptions.backgroundColor = Color.BLACK;
        cropOptions.activityMenuIconColor = Color.WHITE; // El "Check" será blanco
        cropOptions.toolbarColor = Color.parseColor("#ec5b13"); // Naranja MindBox
        cropOptions.toolbarTitleColor = Color.WHITE;
        cropOptions.toolbarBackButtonColor = Color.WHITE;
        cropOptions.activityTitle = "Ajustar Documento";
        cropOptions.autoZoomEnabled = true;
        cropOptions.allowRotation = true;
        cropOptions.allowFlipping = true;
    }

    private void checkPermissionAndLaunch() {
        if (
            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.CAMERA
            ) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(
                this,
                new String[] { Manifest.permission.CAMERA },
                101
            );
        } else {
            launchCropper();
        }
    }

    private void launchCropper() {
        cropImageLauncher.launch(
            new CropImageContractOptions(null, cropOptions)
        );
    }

    @Override
    public void onRequestPermissionsResult(
        int requestCode,
        String[] permissions,
        int[] grantResults
    ) {
        super.onRequestPermissionsResult(
            requestCode,
            permissions,
            grantResults
        );
        if (
            requestCode == 101 &&
            grantResults.length > 0 &&
            grantResults[0] == PackageManager.PERMISSION_GRANTED
        ) {
            launchCropper();
        } else {
            Toast.makeText(
                this,
                "Se necesita permiso de cámara",
                Toast.LENGTH_SHORT
            ).show();
        }
    }

    private void validateButtons() {
        btnGeneratePdf.setEnabled(frontUri != null && backUri != null);
    }

    private void generatePdf() {
        btnGeneratePdf.setEnabled(false);
        btnGeneratePdf.setText("");
        loadingProgress.setVisibility(View.VISIBLE);

        new Thread(() -> {
            try {
                PdfDocument pdfDocument = new PdfDocument();
                // Medidas estándar PDF (8.5x11 pulgadas a 72dpi)
                PdfDocument.PageInfo pageInfo =
                    new PdfDocument.PageInfo.Builder(612, 792, 1).create();
                PdfDocument.Page page = pdfDocument.startPage(pageInfo);
                Canvas canvas = page.getCanvas();

                Bitmap frontBmp = uriToBitmap(frontUri);
                Bitmap backBmp = uriToBitmap(backUri);

                // Tamaño para escala 150% (Aprox 13cm x 8cm)
                int targetW = 365;
                int targetH = 230;

                Bitmap fScaled = Bitmap.createScaledBitmap(
                    frontBmp,
                    targetW,
                    targetH,
                    true
                );
                Bitmap bScaled = Bitmap.createScaledBitmap(
                    backBmp,
                    targetW,
                    targetH,
                    true
                );

                // Dibujar en el canvas
                canvas.drawBitmap(fScaled, 123.5f, 100f, null);
                canvas.drawBitmap(bScaled, 123.5f, 380f, null);

                pdfDocument.finishPage(page);

                String fileName =
                    "Copia_ID_150_" + System.currentTimeMillis() + ".pdf";
                File downloadsDir =
                    Environment.getExternalStoragePublicDirectory(
                        Environment.DIRECTORY_DOWNLOADS
                    );
                File file = new File(downloadsDir, fileName);

                pdfDocument.writeTo(new FileOutputStream(file));
                pdfDocument.close();

                MediaScannerConnection.scanFile(
                    this,
                    new String[] { file.getAbsolutePath() },
                    null,
                    null
                );

                runOnUiThread(() -> {
                    Toast.makeText(
                        this,
                        "PDF guardado en Descargas",
                        Toast.LENGTH_LONG
                    ).show();
                    finish();
                });
            } catch (Exception e) {
                runOnUiThread(() ->
                    Toast.makeText(
                        this,
                        "Error: " + e.getMessage(),
                        Toast.LENGTH_SHORT
                    ).show()
                );
            } finally {
                runOnUiThread(() -> {
                    loadingProgress.setVisibility(View.GONE);
                    btnGeneratePdf.setText("Generar PDF en Descargas");
                    validateButtons();
                });
            }
        })
            .start();
    }

    private Bitmap uriToBitmap(Uri uri) throws Exception {
        InputStream is = getContentResolver().openInputStream(uri);
        return BitmapFactory.decodeStream(is);
    }
}
