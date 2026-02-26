package com.mindbox.app;

import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.firestore.FirebaseFirestore;
import java.util.ArrayList;
import java.util.List;

public class CertificatesActivity extends AppCompatActivity {
    private List<Certificate> fullList = new ArrayList<>();
    private List<Certificate> filteredList = new ArrayList<>();
    private CertificateAdapter adapter;
    private FirebaseFirestore db;
    private String userId;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_certificates);

        db = FirebaseFirestore.getInstance();
        userId = FirebaseAuth.getInstance().getUid();

        // Configuración de RecyclerView
        RecyclerView rv = findViewById(R.id.rvCertificates);
        rv.setLayoutManager(new LinearLayoutManager(this));
        
        adapter = new CertificateAdapter(filteredList, cert -> {
            Intent i = new Intent(this, CertificateDetailActivity.class);
            i.putExtra("CERT_ID", cert.getId());
            startActivity(i);
        });
        rv.setAdapter(adapter);

        // CORRECCIÓN DE CRASH (Línea 41)
        View btnBack = findViewById(R.id.btnBack);
        if (btnBack != null) {
            btnBack.setOnClickListener(v -> finish());
        }

        View fab = findViewById(R.id.fabAddCertificate);
        if (fab != null) {
            fab.setOnClickListener(v -> {
                startActivity(new Intent(this, AddCertificateActivity.class));
            });
        }

        setupSearch();
        loadData();
    }

    private void loadData() {
        if (userId == null) return;
        db.collection("users").document(userId)
            .collection("certificates").addSnapshotListener((value, error) -> {
                if (value != null) {
                    fullList = value.toObjects(Certificate.class);
                    filter(""); // Mostrar todos al inicio
                }
            });
    }

    private void setupSearch() {
        EditText etSearch = findViewById(R.id.etSearch);
        if (etSearch != null) {
            etSearch.addTextChangedListener(new TextWatcher() {
                @Override
                public void onTextChanged(CharSequence s, int start, int before, int count) {
                    filter(s.toString());
                }
                @Override public void beforeTextChanged(CharSequence s, int a, int b, int c) {}
                @Override public void afterTextChanged(Editable s) {}
            });
        }
    }

    private void filter(String query) {
        filteredList.clear();
        for (Certificate c : fullList) {
            if (c.getTitle().toLowerCase().contains(query.toLowerCase())) {
                filteredList.add(c);
            }
        }
        adapter.notifyDataSetChanged();
    }
}