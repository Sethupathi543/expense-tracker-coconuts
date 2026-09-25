package com.example.coconutexpense.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;

public class TraderRequest {

    @NotBlank(message = "Trader name is required")
    private String name;

    private String phone;
    private String location;

    @NotNull(message = "Total sale amount is required")
    @DecimalMin(value = "0.0", inclusive = false, message = "Total sale amount must be positive")
    private BigDecimal totalSaleAmount;

    private String note;

    // Getters and Setters
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public BigDecimal getTotalSaleAmount() { return totalSaleAmount; }
    public void setTotalSaleAmount(BigDecimal totalSaleAmount) {
        this.totalSaleAmount = totalSaleAmount;
    }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
}
