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

public class CertificateAdapter
    extends RecyclerView.Adapter<CertificateAdapter.ViewHolder>
{

    private List<Certificate> certList;
    private OnCertClickListener listener;

    public interface OnCertClickListener {
        void onCertClick(Certificate cert);
    }

    public CertificateAdapter(
        List<Certificate> certList,
        OnCertClickListener listener
    ) {
        this.certList = certList;
        this.listener = listener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(
        @NonNull ViewGroup parent,
        int viewType
    ) {
        View v = LayoutInflater.from(parent.getContext()).inflate(
            R.layout.item_certificate,
            parent,
            false
        );
        return new ViewHolder(v);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        Certificate cert = certList.get(position);
        holder.tvTitle.setText(cert.getTitle());
        holder.tvPlatform.setText(cert.getPlatform());

        int color;
        String platform = cert.getPlatform() != null ? cert.getPlatform() : "";

        // Lógica de colores Premium basada en Compose
        if (platform.equalsIgnoreCase("Credly")) {
            color = Color.parseColor("#2196F3");
        } else if (platform.equalsIgnoreCase("Carlos Slim")) {
            color = Color.parseColor("#4CAF50");
        } else if (platform.equalsIgnoreCase("Udemy")) {
            color = Color.parseColor("#A435F0");
        } else {
            color = Color.parseColor("#1e94f6");
        }

        holder.tvPlatform.setTextColor(color);
        holder.ivBadge.setColorFilter(color);

        if (holder.badgeBg != null) {
            holder.badgeBg.getBackground().setTint(color);
            holder.badgeBg.getBackground().setAlpha(25); // 10% aprox de opacidad
        }

        holder.itemView.setOnClickListener(v -> {
            if (listener != null) listener.onCertClick(cert);
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
