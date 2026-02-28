package com.mindbox.app;

import java.util.UUID;

public class Certificate {

    private String id;
    private String title;
    private String platform;
    private String issueDate;
    private String date; // Fecha de registro
    private String folio;
    private String credlyId;
    private String score;
    private String notes;
    private String pdfUrl;
    private long timestamp;

    // Constructor requerido por Firebase
    public Certificate() {
        this.id = UUID.randomUUID().toString();
        this.platform = "Otro";
    }

    // Getters
    public String getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public String getPlatform() {
        return platform;
    }

    public String getIssueDate() {
        return issueDate;
    }

    public String getDate() {
        return date;
    }

    public String getFolio() {
        return folio;
    }

    public String getCredlyId() {
        return credlyId;
    }

    public String getScore() {
        return score;
    }

    public String getNotes() {
        return notes;
    }

    public String getPdfUrl() {
        return pdfUrl;
    }

    public long getTimestamp() {
        return timestamp;
    }

    // Setters
    public void setId(String id) {
        this.id = id;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public void setPlatform(String platform) {
        this.platform = platform;
    }

    public void setIssueDate(String issueDate) {
        this.issueDate = issueDate;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public void setFolio(String folio) {
        this.folio = folio;
    }

    public void setCredlyId(String credlyId) {
        this.credlyId = credlyId;
    }

    public void setScore(String score) {
        this.score = score;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public void setPdfUrl(String pdfUrl) {
        this.pdfUrl = pdfUrl;
    }

    public void setTimestamp(long timestamp) {
        this.timestamp = timestamp;
    }
}
