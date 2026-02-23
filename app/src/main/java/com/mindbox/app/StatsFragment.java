package com.mindbox.app;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.firestore.FirebaseFirestore;

public class StatsFragment extends Fragment {

    private FirebaseFirestore db;
    private String userId;
    private int nNotes = 0, nCerts = 0, nPass = 0, nReminders = 0;
    private TextView tvSummary;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_stats, container, false);

        db = FirebaseFirestore.getInstance();
        userId = FirebaseAuth.getInstance().getUid();
        tvSummary = view.findViewById(R.id.tvTotalSummary);

        // Configuración de filas con iconos estándar de Android que NO fallan
        setupStatRow(view.findViewById(R.id.statNotes), "Notas Guardadas", android.R.drawable.ic_menu_edit, 0xFF007AFF);
        setupStatRow(view.findViewById(R.id.statCerts), "Cursos y Logros", android.R.drawable.star_on, 0xFF5856D6);
        setupStatRow(view.findViewById(R.id.statPasswords), "Llaves de Acceso", android.R.drawable.ic_lock_idle_lock, 0xFF34C759);
        setupStatRow(view.findViewById(R.id.statReminders), "Recordatorios", android.R.drawable.ic_dialog_info, 0xFFFF2D55);

        if (userId != null) fetchCounts();

        return view;
    }

    private void setupStatRow(View row, String label, int iconRes, int color) {
        if (row == null) return;
        ((TextView) row.findViewById(R.id.tvStatLabel)).setText(label);
        ImageView iv = row.findViewById(R.id.ivStatIcon);
        iv.setImageResource(iconRes);
        iv.setColorFilter(color);
        row.findViewById(R.id.viewIconBg).getBackground().setTint(color);
        row.findViewById(R.id.viewIconBg).setAlpha(0.15f);
    }

    private void fetchCounts() {
        db.collection("users").document(userId).collection("notes").get().addOnSuccessListener(s -> {
            nNotes = s.size(); updateUI(R.id.statNotes, nNotes); actualizarResumen();
        });
        db.collection("users").document(userId).collection("passwords").get().addOnSuccessListener(s -> {
            nPass = s.size(); updateUI(R.id.statPasswords, nPass); actualizarResumen();
        });
    }

    private void updateUI(int rowId, int value) {
        if (getView() == null) return;
        View row = getView().findViewById(rowId);
        if (row != null) ((TextView) row.findViewById(R.id.tvStatValue)).setText(String.valueOf(value));
    }

    private void actualizarResumen() {
        int total = nNotes + nCerts + nPass + nReminders;
        if (tvSummary != null) tvSummary.setText("Tu MindBox tiene " + total + " puntos de información conectados.");
    }
}