package com.mindbox.app;

import java.util.UUID;

public class Password {
    private String id;
    private String serviceName;
    private String accountEmail;
    private String secretKey;

    // Constructor vacío requerido por Firestore
    public Password() { }

    public Password(String serviceName, String accountEmail, String secretKey) {
        this.id = UUID.randomUUID().toString();
        this.serviceName = serviceName;
        this.accountEmail = accountEmail;
        this.secretKey = secretKey;
    }

    // Getters y Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getServiceName() { return serviceName; }
    public void setServiceName(String serviceName) { this.serviceName = serviceName; }
    public String getAccountEmail() { return accountEmail; }
    public void setAccountEmail(String accountEmail) { this.accountEmail = accountEmail; }
    public String getSecretKey() { return secretKey; }
    public void setSecretKey(String secretKey) { this.secretKey = secretKey; }
}