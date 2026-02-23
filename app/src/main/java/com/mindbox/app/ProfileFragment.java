package com.mindbox.app;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.Toast;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.firestore.FirebaseFirestore;
import java.util.HashMap;
import java.util.Map;

public class ProfileFragment extends Fragment {

    private EditText etName, etEmail;
    private FirebaseAuth mAuth;
    private FirebaseFirestore db;
    private boolean isEditing = false;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_profile, container, false);

        mAuth = FirebaseAuth.getInstance();
        db = FirebaseFirestore.getInstance();

        etName = view.findViewById(R.id.etProfileName);
        etEmail = view.findViewById(R.id.etProfileEmail);

        cargarDatos();

        // Botón Editar/Guardar
        view.findViewById(R.id.btnEditProfile).setOnClickListener(v -> {
            if (!isEditing) {
                habilitarEdicion(true);
            } else {
                guardarCambios();
            }
        });

        // Botón Logout
        view.findViewById(R.id.btnLogout).setOnClickListener(v -> {
            mAuth.signOut();
            Intent intent = new Intent(getActivity(), MainActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
            startActivity(intent);
        });

        return view;
    }

    private void cargarDatos() {
        String uid = mAuth.getUid();
        db.collection("users").document(uid).get().addOnSuccessListener(doc -> {
            if (doc.exists()) {
                etName.setText(doc.getString("name"));
                etEmail.setText(mAuth.getCurrentUser().getEmail());
            }
        });
    }

    private void habilitarEdicion(boolean active) {
        isEditing = active;
        etName.setEnabled(active);
        Toast.makeText(getContext(), active ? "Modo edición activado" : "Modo lectura", Toast.LENGTH_SHORT).show();
    }

    private void guardarCambios() {
        String newName = etName.getText().toString().trim();
        Map<String, Object> update = new HashMap<>();
        update.put("name", newName);

        db.collection("users").document(mAuth.getUid()).update(update)
            .addOnSuccessListener(aVoid -> {
                habilitarEdicion(false);
                Toast.makeText(getContext(), "Perfil actualizado", Toast.LENGTH_SHORT).show();
            });
    }
}