package com.mindbox.app;

import java.util.UUID;

public class Certificate {
    private String id;
    private String title;
    private String platform;
    private String issueDate;
    private String folio;
    private String pdfUrl;

    // Constructor vacío requerido por Firebase
    public Certificate() {}

    public Certificate(String id, String title, String platform, String issueDate, String folio, String pdfUrl) {
        this.id = id;
        this.title = title;
        this.platform = platform;
        this.issueDate = issueDate;
        this.folio = folio;
        this.pdfUrl = pdfUrl;
    }

    // Getters
    public String getId() { return id; }
    public String getTitle() { return title; }
    public String getPlatform() { return platform; }
    public String getIssueDate() { return issueDate; }
    public String getFolio() { return folio; }
    public String getPdfUrl() { return pdfUrl; }
}