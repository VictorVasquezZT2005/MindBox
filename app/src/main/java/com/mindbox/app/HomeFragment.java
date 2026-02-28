package com.mindbox.app;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.firestore.FirebaseFirestore;

public class HomeFragment extends Fragment {

    private TextView tvWelcomeName;
    private FirebaseAuth mAuth;
    private FirebaseFirestore db;

    @Nullable
    @Override
    public View onCreateView(
        @NonNull LayoutInflater inflater,
        @Nullable ViewGroup container,
        @Nullable Bundle savedInstanceState
    ) {
        View view = inflater.inflate(R.layout.fragment_home, container, false);

        mAuth = FirebaseAuth.getInstance();
        db = FirebaseFirestore.getInstance();
        tvWelcomeName = view.findViewById(R.id.tvWelcomeName);

        // 1. Cargar nombre desde Firestore
        if (mAuth.getCurrentUser() != null) {
            db
                .collection("users")
                .document(mAuth.getUid())
                .get()
                .addOnSuccessListener(doc -> {
                    if (doc.exists() && isAdded()) {
                        tvWelcomeName.setText("Hola, " + doc.getString("name"));
                    }
                });
        }

        // 2. NAVEGACIÓN HACIA ACTIVIDADES (Flujo independiente)

        // Cursos -> CertificatesActivity
        view
            .findViewById(R.id.cardCourses)
            .setOnClickListener(v -> {
                startActivity(
                    new Intent(getActivity(), CertificatesActivity.class)
                );
            });

        // Red -> StatsActivity (CAMBIADO: De Fragment a Activity)
        view
            .findViewById(R.id.cardNetwork)
            .setOnClickListener(v -> {
                startActivity(new Intent(getActivity(), StatsActivity.class));
            });

        // CV -> ResumeActivity
        view
            .findViewById(R.id.cardResume)
            .setOnClickListener(v -> {
                startActivity(new Intent(getActivity(), ResumeActivity.class));
            });

        // Perfil Header -> ProfileActivity
        view
            .findViewById(R.id.btnProfileHeader)
            .setOnClickListener(v -> {
                startActivity(new Intent(getActivity(), ProfileActivity.class));
            });
        // Scanner -> DocumentActivity (Para el escaneo de ID 150%)
        view
            .findViewById(R.id.cardScanner)
            .setOnClickListener(v -> {
                if (getActivity() != null) {
                    Intent intent = new Intent(
                        getActivity(),
                        DocumentActivity.class
                    );
                    startActivity(intent);
                }
            });

        return view;
    }

    private void navegarAFramento(Fragment fragment) {
        if (getActivity() != null) {
            getActivity()
                .getSupportFragmentManager()
                .beginTransaction()
                .replace(R.id.fragment_container, fragment)
                .addToBackStack(null)
                .commit();
        }
    }
}
