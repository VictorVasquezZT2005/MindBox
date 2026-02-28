package com.mindbox.app;

import android.content.Intent;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.widget.Button;
import android.widget.EditText;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.firestore.FirebaseFirestore;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class CertificatesActivity extends AppCompatActivity {

    private List<Certificate> fullList = new ArrayList<>();
    private List<Certificate> filteredList = new ArrayList<>();
    private CertificateAdapter adapter;
    private FirebaseFirestore db;
    private String userId;

    private String searchQuery = "";
    private String selectedPlatform = "Todas";

    private Button btnAll, btnCredly, btnUdemy, btnSlim;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_certificates);

        db = FirebaseFirestore.getInstance();
        userId = FirebaseAuth.getInstance().getUid();

        // Referencias UI
        btnAll = findViewById(R.id.btnFilterAll);
        btnCredly = findViewById(R.id.btnFilterCredly);
        btnUdemy = findViewById(R.id.btnFilterUdemy);
        btnSlim = findViewById(R.id.btnFilterSlim); // Añadir este ID en el XML

        setupRecyclerView();
        setupSearch();
        setupPlatformFilters();
        loadData();

        findViewById(R.id.btnBack).setOnClickListener(v -> finish());
        findViewById(R.id.fabAddCertificate).setOnClickListener(v ->
            startActivity(new Intent(this, AddCertificateActivity.class))
        );
    }

    private void setupRecyclerView() {
        RecyclerView rv = findViewById(R.id.rvCertificates);
        rv.setLayoutManager(new LinearLayoutManager(this));
        adapter = new CertificateAdapter(filteredList, cert -> {
            Intent i = new Intent(this, CertificateDetailActivity.class);
            i.putExtra("CERT_ID", cert.getId());
            startActivity(i);
        });
        rv.setAdapter(adapter);
    }

    private void setupPlatformFilters() {
        btnAll.setOnClickListener(v -> updateSelection("Todas"));
        btnCredly.setOnClickListener(v -> updateSelection("Credly"));
        btnUdemy.setOnClickListener(v -> updateSelection("Udemy"));
        btnSlim.setOnClickListener(v -> updateSelection("Carlos Slim"));
    }

    private void updateSelection(String platform) {
        this.selectedPlatform = platform;
        updateButtonsUI();
        applyFilters();
    }

    private void updateButtonsUI() {
        setButtonStyle(btnAll, "Todas");
        setButtonStyle(btnCredly, "Credly");
        setButtonStyle(btnUdemy, "Udemy");
        setButtonStyle(btnSlim, "Carlos Slim");
    }

    private void setButtonStyle(Button btn, String platformName) {
        boolean isSelected = selectedPlatform.equals(platformName);
        btn.setBackgroundTintList(
            ColorStateList.valueOf(
                Color.parseColor(isSelected ? "#1e94f6" : "#1C1C1E")
            )
        );
        btn.setTextColor(
            isSelected ? Color.WHITE : Color.parseColor("#666666")
        );
    }

    private void setupSearch() {
        EditText etSearch = findViewById(R.id.etSearch);
        etSearch.addTextChangedListener(
            new TextWatcher() {
                @Override
                public void onTextChanged(
                    CharSequence s,
                    int start,
                    int before,
                    int count
                ) {
                    searchQuery = s.toString().toLowerCase().trim();
                    applyFilters();
                }

                @Override
                public void beforeTextChanged(
                    CharSequence s,
                    int a,
                    int b,
                    int c
                ) {}

                @Override
                public void afterTextChanged(Editable s) {}
            }
        );
    }

    private void loadData() {
        if (userId == null) return;
        db
            .collection("users")
            .document(userId)
            .collection("certificates")
            .addSnapshotListener((value, error) -> {
                if (value != null) {
                    fullList = value.toObjects(Certificate.class);
                    applyFilters();
                }
            });
    }

    private void applyFilters() {
        filteredList.clear();
        for (Certificate cert : fullList) {
            boolean matchesSearch = cert
                .getTitle()
                .toLowerCase()
                .contains(searchQuery);
            boolean matchesPlatform =
                selectedPlatform.equals("Todas") ||
                (cert.getPlatform() != null &&
                    cert.getPlatform().equalsIgnoreCase(selectedPlatform));

            if (matchesSearch && matchesPlatform) {
                filteredList.add(cert);
            }
        }
        // Ordenar por fecha (Timestamp) de mayor a menor
        Collections.sort(filteredList, (c1, c2) ->
            Long.compare(c2.getTimestamp(), c1.getTimestamp())
        );
        adapter.notifyDataSetChanged();
    }
}
