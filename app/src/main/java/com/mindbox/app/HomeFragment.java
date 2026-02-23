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
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_home, container, false);

        mAuth = FirebaseAuth.getInstance();
        db = FirebaseFirestore.getInstance();
        tvWelcomeName = view.findViewById(R.id.tvWelcomeName);

        // 1. Cargar nombre desde Firestore
        if (mAuth.getCurrentUser() != null) {
            String uid = mAuth.getCurrentUser().getUid();
            db.collection("users").document(uid).get()
                .addOnSuccessListener(doc -> {
                    if (doc.exists() && isAdded()) {
                        String name = doc.getString("name");
                        tvWelcomeName.setText("Hola, " + name);
                    }
                });
        }

        // 2. Navegación de tarjetas
        view.findViewById(R.id.cardNetwork).setOnClickListener(v -> navegarAFramento(new StatsFragment()));
        view.findViewById(R.id.cardScanner).setOnClickListener(v -> navegarAFramento(new PasswordsFragment()));
        
        view.findViewById(R.id.cardResume).setOnClickListener(v -> {
            startActivity(new Intent(getActivity(), ResumeActivity.class));
        });

        // Icono de perfil en el header
        view.findViewById(R.id.btnProfileHeader).setOnClickListener(v -> navegarAFramento(new ProfileFragment()));

        return view;
    }

    private void navegarAFramento(Fragment fragment) {
        if (getActivity() != null) {
            getActivity().getSupportFragmentManager().beginTransaction()
                .replace(R.id.fragment_container, fragment)
                .addToBackStack(null)
                .commit();
        }
    }
}