package com.mindbox.app;

import android.os.Bundle;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;

import com.google.android.material.bottomnavigation.BottomNavigationView;
import com.google.firebase.auth.FirebaseAuth;

public class DashboardActivity extends AppCompatActivity {

    private FirebaseAuth mAuth;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_dashboard);

        mAuth = FirebaseAuth.getInstance();
        BottomNavigationView bottomNav = findViewById(R.id.bottom_navigation);

        // 1. Configurar el listener para cambiar de pantalla (Fragmentos)
        bottomNav.setOnItemSelectedListener(item -> {
            Fragment selectedFragment = null;
            int id = item.getItemId();

            if (id == R.id.nav_dashboard) {
                selectedFragment = new HomeFragment();
            } else if (id == R.id.nav_notes) {
                // Aquí iría tu NotesFragment cuando lo crees
                Toast.makeText(this, "Notas próximamente", Toast.LENGTH_SHORT).show();
            } else if (id == R.id.nav_reminders) {
                Toast.makeText(this, "Alertas próximamente", Toast.LENGTH_SHORT).show();
            } else if (id == R.id.nav_passwords) {
                // Cargamos el fragmento de las Llaves 2FA
                selectedFragment = new PasswordsFragment();
            }

            if (selectedFragment != null) {
                cambiarFragmento(selectedFragment);
            }
            return true;
        });

        // 2. Cargar la pantalla de Inicio por defecto al abrir la app
        if (savedInstanceState == null) {
            cambiarFragmento(new HomeFragment());
        }
    }

    /**
     * Método utilitario para intercambiar fragmentos en el contenedor
     */
    private void cambiarFragmento(Fragment fragment) {
        FragmentManager fragmentManager = getSupportFragmentManager();
        FragmentTransaction transaction = fragmentManager.beginTransaction();
        
        // Animación sutil de desvanecimiento (minimalista)
        transaction.setCustomAnimations(android.R.anim.fade_in, android.R.anim.fade_out);
        
        // Reemplaza el contenido del FrameLayout
        transaction.replace(R.id.fragment_container, fragment);
        transaction.commit();
    }
}