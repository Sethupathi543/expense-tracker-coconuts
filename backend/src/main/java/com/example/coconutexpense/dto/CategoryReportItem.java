package com.example.coconutexpense.dto;

import java.math.BigDecimal;

public class CategoryReportItem {
    private String category;
    private BigDecimal totalAmount;
    private long count;
    private double percentage;

    public CategoryReportItem() {
    }

    public CategoryReportItem(String category, BigDecimal totalAmount, long count, double percentage) {
        this.category = category;
        this.totalAmount = totalAmount;
        this.count = count;
        this.percentage = percentage;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public long getCount() {
        return count;
    }

    public void setCount(long count) {
        this.count = count;
    }

    public double getPercentage() {
        return percentage;
    }

    public void setPercentage(double percentage) {
        this.percentage = percentage;
    }
}
