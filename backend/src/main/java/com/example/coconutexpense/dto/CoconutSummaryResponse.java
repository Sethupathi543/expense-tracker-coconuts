package com.example.coconutexpense.dto;

import java.math.BigDecimal;

public class CoconutSummaryResponse {

    private BigDecimal totalFarmerPurchase;
    private BigDecimal totalFarmerPaid;
    private BigDecimal farmerPending;

    private BigDecimal totalTraderSales;
    private BigDecimal totalTraderReceived;
    private BigDecimal traderPending;

    // Getters and Setters
    public BigDecimal getTotalFarmerPurchase() { return totalFarmerPurchase; }
    public void setTotalFarmerPurchase(BigDecimal totalFarmerPurchase) {
        this.totalFarmerPurchase = totalFarmerPurchase;
    }

    public BigDecimal getTotalFarmerPaid() { return totalFarmerPaid; }
    public void setTotalFarmerPaid(BigDecimal totalFarmerPaid) {
        this.totalFarmerPaid = totalFarmerPaid;
    }

    public BigDecimal getFarmerPending() { return farmerPending; }
    public void setFarmerPending(BigDecimal farmerPending) {
        this.farmerPending = farmerPending;
    }

    public BigDecimal getTotalTraderSales() { return totalTraderSales; }
    public void setTotalTraderSales(BigDecimal totalTraderSales) {
        this.totalTraderSales = totalTraderSales;
    }

    public BigDecimal getTotalTraderReceived() { return totalTraderReceived; }
    public void setTotalTraderReceived(BigDecimal totalTraderReceived) {
        this.totalTraderReceived = totalTraderReceived;
    }

    public BigDecimal getTraderPending() { return traderPending; }
    public void setTraderPending(BigDecimal traderPending) {
        this.traderPending = traderPending;
    }
}
