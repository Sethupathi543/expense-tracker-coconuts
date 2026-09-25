package com.example.coconutexpense.service;

import com.example.coconutexpense.dto.*;
import com.example.coconutexpense.entity.Expense;
import com.example.coconutexpense.entity.User;
import com.example.coconutexpense.exception.ResourceNotFoundException;
import com.example.coconutexpense.repository.ExpenseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ExpenseService {

    @Autowired
    private ExpenseRepository expenseRepository;

    @Autowired
    private AuthService authService;

    @Transactional
    public ExpenseResponse createExpense(ExpenseRequest request) {
        User user = authService.getCurrentAuthenticatedUser();

        Expense expense = new Expense(
                user,
                request.getAmount(),
                request.getCategory().trim(),
                request.getDate(),
                request.getPaymentMethod().trim(),
                request.getNote() != null ? request.getNote().trim() : ""
        );

        Expense savedExpense = expenseRepository.save(expense);
        return ExpenseResponse.fromEntity(savedExpense);
    }

    public List<ExpenseResponse> getAllExpenses(String keyword, String category, LocalDate startDate, LocalDate endDate) {
        User user = authService.getCurrentAuthenticatedUser();
        List<Expense> expenses = expenseRepository.searchExpenses(user, category, startDate, endDate, keyword);
        return expenses.stream().map(ExpenseResponse::fromEntity).collect(Collectors.toList());
    }

    public ExpenseResponse getExpenseById(Long id) {
        User user = authService.getCurrentAuthenticatedUser();
        Expense expense = expenseRepository.findByIdAndUser(id, user)
                .orElseThrow(() -> new ResourceNotFoundException("Expense not found with id: " + id));
        return ExpenseResponse.fromEntity(expense);
    }

    @Transactional
    public ExpenseResponse updateExpense(Long id, ExpenseRequest request) {
        User user = authService.getCurrentAuthenticatedUser();
        Expense expense = expenseRepository.findByIdAndUser(id, user)
                .orElseThrow(() -> new ResourceNotFoundException("Expense not found with id: " + id));

        expense.setAmount(request.getAmount());
        expense.setCategory(request.getCategory().trim());
        expense.setDate(request.getDate());
        expense.setPaymentMethod(request.getPaymentMethod().trim());
        expense.setNote(request.getNote() != null ? request.getNote().trim() : "");

        Expense updatedExpense = expenseRepository.save(expense);
        return ExpenseResponse.fromEntity(updatedExpense);
    }

    @Transactional
    public void deleteExpense(Long id) {
        User user = authService.getCurrentAuthenticatedUser();
        Expense expense = expenseRepository.findByIdAndUser(id, user)
                .orElseThrow(() -> new ResourceNotFoundException("Expense not found with id: " + id));

        expenseRepository.delete(expense);
    }

    // Dashboard Methods
    public BigDecimal getTodayExpense() {
        User user = authService.getCurrentAuthenticatedUser();
        return expenseRepository.sumAmountByUserAndDate(user, LocalDate.now());
    }

    public BigDecimal getThisWeekExpense() {
        User user = authService.getCurrentAuthenticatedUser();
        LocalDate startOfWeek = LocalDate.now().with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
        LocalDate endOfWeek = LocalDate.now().with(TemporalAdjusters.nextOrSame(DayOfWeek.SUNDAY));
        return expenseRepository.sumAmountByUserAndDateBetween(user, startOfWeek, endOfWeek);
    }

    public BigDecimal getThisMonthExpense() {
        User user = authService.getCurrentAuthenticatedUser();
        LocalDate startOfMonth = LocalDate.now().withDayOfMonth(1);
        LocalDate endOfMonth = LocalDate.now().withDayOfMonth(LocalDate.now().lengthOfMonth());
        return expenseRepository.sumAmountByUserAndDateBetween(user, startOfMonth, endOfMonth);
    }

    public List<ExpenseResponse> getRecentExpenses() {
        User user = authService.getCurrentAuthenticatedUser();
        List<Expense> recent = expenseRepository.findTop5ByUserOrderByDateDescCreatedAtDesc(user);
        return recent.stream().map(ExpenseResponse::fromEntity).collect(Collectors.toList());
    }

    public DashboardSummaryResponse getDashboardSummary() {
        return new DashboardSummaryResponse(
                getTodayExpense(),
                getThisWeekExpense(),
                getThisMonthExpense(),
                getRecentExpenses()
        );
    }

    // Report Methods
    public ReportResponse<DailyReportItem> getDailyReport(LocalDate startDate, LocalDate endDate) {
        User user = authService.getCurrentAuthenticatedUser();
        if (startDate == null) {
            startDate = LocalDate.now().minusDays(30);
        }
        if (endDate == null) {
            endDate = LocalDate.now();
        }

        List<Object[]> rawList = expenseRepository.findDailyExpenseTotals(user, startDate, endDate);
        List<DailyReportItem> items = new ArrayList<>();
        BigDecimal total = BigDecimal.ZERO;

        for (Object[] row : rawList) {
            LocalDate date = (LocalDate) row[0];
            BigDecimal amount = (BigDecimal) row[1];
            items.add(new DailyReportItem(date, amount));
            total = total.add(amount);
        }

        return new ReportResponse<>("Daily Report", total, items);
    }

    public ReportResponse<DailyReportItem> getWeeklyReport() {
        LocalDate startOfWeek = LocalDate.now().with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
        LocalDate endOfWeek = LocalDate.now().with(TemporalAdjusters.nextOrSame(DayOfWeek.SUNDAY));
        ReportResponse<DailyReportItem> res = getDailyReport(startOfWeek, endOfWeek);
        res.setReportType("Weekly Report");
        return res;
    }

    public ReportResponse<DailyReportItem> getMonthlyReport(Integer year, Integer month) {
        LocalDate now = LocalDate.now();
        int targetYear = (year != null) ? year : now.getYear();
        int targetMonth = (month != null) ? month : now.getMonthValue();

        LocalDate startOfMonth = LocalDate.of(targetYear, targetMonth, 1);
        LocalDate endOfMonth = startOfMonth.withDayOfMonth(startOfMonth.lengthOfMonth());

        ReportResponse<DailyReportItem> res = getDailyReport(startOfMonth, endOfMonth);
        res.setReportType("Monthly Report");
        return res;
    }

    public ReportResponse<CategoryReportItem> getCategoryWiseReport() {
        User user = authService.getCurrentAuthenticatedUser();
        List<Object[]> rawList = expenseRepository.findCategoryExpenseTotals(user);

        BigDecimal total = BigDecimal.ZERO;
        List<CategoryReportItem> items = new ArrayList<>();

        for (Object[] row : rawList) {
            String category = (String) row[0];
            BigDecimal amount = (BigDecimal) row[1];
            long count = ((Number) row[2]).longValue();
            total = total.add(amount);
            items.add(new CategoryReportItem(category, amount, count, 0.0));
        }

        if (total.compareTo(BigDecimal.ZERO) > 0) {
            for (CategoryReportItem item : items) {
                double pct = item.getTotalAmount()
                        .multiply(BigDecimal.valueOf(100))
                        .divide(total, 1, RoundingMode.HALF_UP)
                        .doubleValue();
                item.setPercentage(pct);
            }
        }

        return new ReportResponse<>("Category-wise Report", total, items);
    }
}
