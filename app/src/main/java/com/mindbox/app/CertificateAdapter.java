package com.mindbox.app;

import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import java.util.List;

public class CertificateAdapter extends RecyclerView.Adapter<CertificateAdapter.ViewHolder> {
    private List<Certificate> certList;
    private OnCertClickListener listener;

    public interface OnCertClickListener {
        void onCertClick(Certificate cert);
    }

    public CertificateAdapter(List<Certificate> certList, OnCertClickListener listener) {
        this.certList = certList;
        this.listener = listener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        // Inflamos el item_certificate que tiene los márgenes de 12dp para que no se peguen
        View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_certificate, parent, false);
        return new ViewHolder(v);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        Certificate cert = certList.get(position);
        
        holder.tvTitle.setText(cert.getTitle());
        holder.tvPlatform.setText(cert.getPlatform());

        // Lógica de colores Premium (Estética "Mi Red Digital")
        int color = Color.parseColor("#1e94f6"); // Azul por defecto (MindBox)
        
        String platform = cert.getPlatform() != null ? cert.getPlatform() : "";
        
        if (platform.equalsIgnoreCase("Credly")) {
            color = Color.parseColor("#2196F3");
        } else if (platform.equalsIgnoreCase("Carlos Slim")) {
            color = Color.parseColor("#4CAF50");
        } else if (platform.equalsIgnoreCase("Udemy")) {
            color = Color.parseColor("#A435F0"); // Morado de Udemy
        }

        // Aplicamos el color al texto de la plataforma y al icono
        holder.tvPlatform.setTextColor(color);
        holder.ivBadge.setColorFilter(color);

        // Aplicamos el color al círculo de fondo con transparencia (Estilo Glassmorphism)
        if (holder.badgeBg.getBackground() != null) {
            holder.badgeBg.getBackground().setTint(color);
            holder.badgeBg.getBackground().setAlpha(40); // 40 de 255 para que sea sutil
        }

        // Click listener para abrir el detalle
        holder.itemView.setOnClickListener(v -> {
            if (listener != null) {
                listener.onCertClick(cert);
            }
        });
    }

    @Override
    public int getItemCount() {
        return certList != null ? certList.size() : 0;
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        TextView tvTitle, tvPlatform;
        ImageView ivBadge;
        View badgeBg;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            tvTitle = itemView.findViewById(R.id.tvTitle);
            tvPlatform = itemView.findViewById(R.id.tvPlatform);
            ivBadge = itemView.findViewById(R.id.ivBadge);
            badgeBg = itemView.findViewById(R.id.badgeContainer);
        }
    }
}