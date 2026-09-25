package com.example.coconutexpense.dto;

import java.math.BigDecimal;
import java.util.List;

public class DashboardSummaryResponse {
    private BigDecimal todayExpense;
    private BigDecimal thisWeekExpense;
    private BigDecimal thisMonthExpense;
    private List<ExpenseResponse> recentExpenses;

    public DashboardSummaryResponse() {
    }

    public DashboardSummaryResponse(BigDecimal todayExpense, BigDecimal thisWeekExpense,
                                    BigDecimal thisMonthExpense, List<ExpenseResponse> recentExpenses) {
        this.todayExpense = todayExpense;
        this.thisWeekExpense = thisWeekExpense;
        this.thisMonthExpense = thisMonthExpense;
        this.recentExpenses = recentExpenses;
    }

    public BigDecimal getTodayExpense() {
        return todayExpense;
    }

    public void setTodayExpense(BigDecimal todayExpense) {
        this.todayExpense = todayExpense;
    }

    public BigDecimal getThisWeekExpense() {
        return thisWeekExpense;
    }

    public void setThisWeekExpense(BigDecimal thisWeekExpense) {
        this.thisWeekExpense = thisWeekExpense;
    }

    public BigDecimal getThisMonthExpense() {
        return thisMonthExpense;
    }

    public void setThisMonthExpense(BigDecimal thisMonthExpense) {
        this.thisMonthExpense = thisMonthExpense;
    }

    public List<ExpenseResponse> getRecentExpenses() {
        return recentExpenses;
    }

    public void setRecentExpenses(List<ExpenseResponse> recentExpenses) {
        this.recentExpenses = recentExpenses;
    }
}
