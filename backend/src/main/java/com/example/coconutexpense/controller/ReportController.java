package com.example.coconutexpense.controller;

import com.example.coconutexpense.dto.CategoryReportItem;
import com.example.coconutexpense.dto.DailyReportItem;
import com.example.coconutexpense.dto.ReportResponse;
import com.example.coconutexpense.service.ExpenseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/reports")
public class ReportController {

    @Autowired
    private ExpenseService expenseService;

    @GetMapping("/daily")
    public ResponseEntity<ReportResponse<DailyReportItem>> getDailyReport(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return ResponseEntity.ok(expenseService.getDailyReport(startDate, endDate));
    }

    @GetMapping("/weekly")
    public ResponseEntity<ReportResponse<DailyReportItem>> getWeeklyReport() {
        return ResponseEntity.ok(expenseService.getWeeklyReport());
    }

    @GetMapping("/monthly")
    public ResponseEntity<ReportResponse<DailyReportItem>> getMonthlyReport(
            @RequestParam(required = false) Integer year,
            @RequestParam(required = false) Integer month) {
        return ResponseEntity.ok(expenseService.getMonthlyReport(year, month));
    }

    @GetMapping("/category-wise")
    public ResponseEntity<ReportResponse<CategoryReportItem>> getCategoryWiseReport() {
        return ResponseEntity.ok(expenseService.getCategoryWiseReport());
    }
}
