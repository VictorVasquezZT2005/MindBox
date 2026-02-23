package com.mindbox.app;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import java.util.ArrayList;
import java.util.List;

public class PasswordAdapter extends RecyclerView.Adapter<PasswordAdapter.ViewHolder> {
    
    private List<Password> passwords;
    private List<Password> passwordsFull;
    private OnPasswordClickListener listener;

    public interface OnPasswordClickListener {
        void onCopyClick(String code);
        void onDeleteClick(Password password);
    }

    public PasswordAdapter(List<Password> passwords, OnPasswordClickListener listener) {
        this.passwords = passwords;
        this.passwordsFull = new ArrayList<>(passwords);
        this.listener = listener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_password, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        Password p = passwords.get(position);
        holder.tvServiceName.setText(p.getServiceName());
        holder.tvAccountEmail.setText(p.getAccountEmail());
        
        String rawCode = TOTPHelper.generateCode(p.getSecretKey());
        String formattedCode = (rawCode != null && rawCode.length() == 6) ? 
                rawCode.substring(0, 3) + " " + rawCode.substring(3) : rawCode;
        holder.tvOtpCode.setText(formattedCode);

        int secondsLeft = TOTPHelper.getSecondsLeft();
        holder.tvTimeRemaining.setText(secondsLeft + "s restantes");

        holder.btnCopy.setOnClickListener(v -> listener.onCopyClick(rawCode));
        holder.btnDelete.setOnClickListener(v -> listener.onDeleteClick(p));
    }

    @Override
    public int getItemCount() { return passwords.size(); }

    public void updateData(List<Password> newList) {
        this.passwords = newList;
        this.passwordsFull = new ArrayList<>(newList);
        notifyDataSetChanged();
    }

    public void filter(String text) {
        List<Password> filteredList = new ArrayList<>();
        if (text == null || text.isEmpty()) {
            filteredList.addAll(passwordsFull);
        } else {
            String pattern = text.toLowerCase().trim();
            for (Password item : passwordsFull) {
                if (item.getServiceName().toLowerCase().contains(pattern)) {
                    filteredList.add(item);
                }
            }
        }
        this.passwords = filteredList;
        notifyDataSetChanged();
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        TextView tvServiceName, tvAccountEmail, tvOtpCode, tvTimeRemaining;
        ImageView btnCopy, btnDelete;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            tvServiceName = itemView.findViewById(R.id.tvServiceName);
            tvAccountEmail = itemView.findViewById(R.id.tvAccountEmail);
            tvOtpCode = itemView.findViewById(R.id.tvOtpCode);
            tvTimeRemaining = itemView.findViewById(R.id.tvTimeRemaining); 
            btnCopy = itemView.findViewById(R.id.btnCopy);
            btnDelete = itemView.findViewById(R.id.btnDelete);
            // Referencia a ivServiceLogo eliminada correctamente
        }
    }
}