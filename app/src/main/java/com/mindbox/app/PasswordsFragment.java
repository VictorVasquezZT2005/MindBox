package com.mindbox.app;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.Toast;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import java.util.ArrayList;
import java.util.List;

public class PasswordsFragment extends Fragment implements PasswordAdapter.OnPasswordClickListener {

    private RecyclerView rvPasswords;
    private PasswordAdapter adapter;
    private List<Password> passwordList = new ArrayList<>();
    private FirebaseFirestore db;
    private FirebaseAuth mAuth;
    private EditText etSearch;
    private final Handler handler = new Handler();
    private Runnable refreshRunnable;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_passwords, container, false);
        db = FirebaseFirestore.getInstance();
        mAuth = FirebaseAuth.getInstance();

        rvPasswords = view.findViewById(R.id.rvPasswords);
        rvPasswords.setLayoutManager(new LinearLayoutManager(getContext()));
        
        // Inicializamos adaptador con listener
        adapter = new PasswordAdapter(passwordList, this);
        rvPasswords.setAdapter(adapter);

        etSearch = view.findViewById(R.id.etSearch);
        etSearch.addTextChangedListener(new TextWatcher() {
            @Override public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
            @Override public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (adapter != null) adapter.filter(s.toString());
            }
            @Override public void afterTextChanged(Editable s) {}
        });

        view.findViewById(R.id.fabAdd).setOnClickListener(v -> 
            startActivity(new Intent(getActivity(), AddPasswordActivity.class)));

        cargarDatosFirestore();
        iniciarReloj();
        return view;
    }

    @Override
    public void onCopyClick(String code) {
        ClipboardManager clipboard = (ClipboardManager) getActivity().getSystemService(Context.CLIPBOARD_SERVICE);
        ClipData clip = ClipData.newPlainText("2FA Code", code);
        clipboard.setPrimaryClip(clip);
        Toast.makeText(getContext(), "Código copiado", Toast.LENGTH_SHORT).show();
    }

    @Override
    public void onDeleteClick(Password p) {
        new AlertDialog.Builder(getContext(), R.style.AlertDialogCustom)
            .setTitle("¿Eliminar llave?")
            .setMessage("Esta acción no se puede deshacer. Perderás el acceso 2FA para " + p.getServiceName())
            .setPositiveButton("ELIMINAR", (dialog, which) -> eliminarDeFirestore(p))
            .setNegativeButton("CANCELAR", null)
            .show();
    }

    private void eliminarDeFirestore(Password p) {
        String uid = mAuth.getUid();
        if (uid == null || p.getId() == null) return;

        db.collection("users").document(uid).collection("passwords").document(p.getId())
            .delete()
            .addOnSuccessListener(aVoid -> Toast.makeText(getContext(), "Llave eliminada", Toast.LENGTH_SHORT).show())
            .addOnFailureListener(e -> Toast.makeText(getContext(), "Error al eliminar", Toast.LENGTH_SHORT).show());
    }

    private void cargarDatosFirestore() {
        String uid = mAuth.getUid();
        if (uid == null) return;
        db.collection("users").document(uid).collection("passwords")
            .addSnapshotListener((value, error) -> {
                if (value != null) {
                    passwordList.clear();
                    for (QueryDocumentSnapshot doc : value) {
                        Password p = doc.toObject(Password.class);
                        p.setId(doc.getId()); // Muy importante para poder eliminar luego
                        passwordList.add(p);
                    }
                    adapter.updateData(passwordList);
                }
            });
    }

    private void iniciarReloj() {
        refreshRunnable = new Runnable() {
            @Override public void run() {
                if (adapter != null && etSearch.getText().toString().isEmpty()) adapter.notifyDataSetChanged();
                handler.postDelayed(this, 1000);
            }
        };
        handler.post(refreshRunnable);
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        handler.removeCallbacks(refreshRunnable);
    }
}