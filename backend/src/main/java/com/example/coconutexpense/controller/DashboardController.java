package com.example.coconutexpense.controller;

import com.example.coconutexpense.dto.DashboardSummaryResponse;
import com.example.coconutexpense.dto.ExpenseResponse;
import com.example.coconutexpense.service.ExpenseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/dashboard")
public class DashboardController {

    @Autowired
    private ExpenseService expenseService;

    @GetMapping("/summary")
    public ResponseEntity<DashboardSummaryResponse> getSummary() {
        return ResponseEntity.ok(expenseService.getDashboardSummary());
    }

    @GetMapping("/today")
    public ResponseEntity<Map<String, Object>> getTodayExpense() {
        BigDecimal total = expenseService.getTodayExpense();
        Map<String, Object> response = new HashMap<>();
        response.put("todayExpense", total);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/week")
    public ResponseEntity<Map<String, Object>> getThisWeekExpense() {
        BigDecimal total = expenseService.getThisWeekExpense();
        Map<String, Object> response = new HashMap<>();
        response.put("thisWeekExpense", total);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/month")
    public ResponseEntity<Map<String, Object>> getThisMonthExpense() {
        BigDecimal total = expenseService.getThisMonthExpense();
        Map<String, Object> response = new HashMap<>();
        response.put("thisMonthExpense", total);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/recent")
    public ResponseEntity<List<ExpenseResponse>> getRecentExpenses() {
        return ResponseEntity.ok(expenseService.getRecentExpenses());
    }
}
