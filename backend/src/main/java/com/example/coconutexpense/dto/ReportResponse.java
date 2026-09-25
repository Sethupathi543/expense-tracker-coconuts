package com.example.coconutexpense.dto;

import java.math.BigDecimal;
import java.util.List;

public class ReportResponse<T> {
    private String reportType;
    private BigDecimal totalAmount;
    private List<T> data;

    public ReportResponse() {
    }

    public ReportResponse(String reportType, BigDecimal totalAmount, List<T> data) {
        this.reportType = reportType;
        this.totalAmount = totalAmount;
        this.data = data;
    }

    public String getReportType() {
        return reportType;
    }

    public void setReportType(String reportType) {
        this.reportType = reportType;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public List<T> getData() {
        return data;
    }

    public void setData(List<T> data) {
        this.data = data;
    }
}
