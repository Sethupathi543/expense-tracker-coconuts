package com.example.coconutexpense.dto;

import java.math.BigDecimal;

public class ResourceEarningSummaryResponse {

    private BigDecimal totalEarnings;
    private BigDecimal thottiEarnings;
    private BigDecimal mattaiEarnings;
    private BigDecimal paruppuEarnings;

    public ResourceEarningSummaryResponse() {}

    public ResourceEarningSummaryResponse(BigDecimal totalEarnings, BigDecimal thottiEarnings, BigDecimal mattaiEarnings, BigDecimal paruppuEarnings) {
        this.totalEarnings = totalEarnings;
        this.thottiEarnings = thottiEarnings;
        this.mattaiEarnings = mattaiEarnings;
        this.paruppuEarnings = paruppuEarnings;
    }

    public BigDecimal getTotalEarnings() { return totalEarnings; }
    public void setTotalEarnings(BigDecimal totalEarnings) { this.totalEarnings = totalEarnings; }

    public BigDecimal getThottiEarnings() { return thottiEarnings; }
    public void setThottiEarnings(BigDecimal thottiEarnings) { this.thottiEarnings = thottiEarnings; }

    public BigDecimal getMattaiEarnings() { return mattaiEarnings; }
    public void setMattaiEarnings(BigDecimal mattaiEarnings) { this.mattaiEarnings = mattaiEarnings; }

    public BigDecimal getParuppuEarnings() { return paruppuEarnings; }
    public void setParuppuEarnings(BigDecimal paruppuEarnings) { this.paruppuEarnings = paruppuEarnings; }
}
