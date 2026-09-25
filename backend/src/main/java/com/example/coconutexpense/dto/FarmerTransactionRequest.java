package com.example.coconutexpense.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDate;

public class FarmerTransactionRequest {

    @NotNull(message = "Amount is required")
    @DecimalMin(value = "0.0", inclusive = false, message = "Amount must be positive")
    private BigDecimal amountGiven;

    @NotNull(message = "Date is required")
    private LocalDate date;

    private String paymentMethod;
    private String note;

    // Getters and Setters
    public BigDecimal getAmountGiven() { return amountGiven; }
    public void setAmountGiven(BigDecimal amountGiven) { this.amountGiven = amountGiven; }

    public LocalDate getDate() { return date; }
    public void setDate(LocalDate date) { this.date = date; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
}
