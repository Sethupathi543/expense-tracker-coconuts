package com.example.coconutexpense.repository;

import com.example.coconutexpense.entity.Expense;
import com.example.coconutexpense.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface ExpenseRepository extends JpaRepository<Expense, Long> {

    Optional<Expense> findByIdAndUser(Long id, User user);

    List<Expense> findTop5ByUserOrderByDateDescCreatedAtDesc(User user);

    @Query("SELECT e FROM Expense e WHERE e.user = :user " +
           "AND (:category IS NULL OR :category = '' OR LOWER(e.category) = LOWER(:category)) " +
           "AND (:startDate IS NULL OR e.date >= :startDate) " +
           "AND (:endDate IS NULL OR e.date <= :endDate) " +
           "AND (:keyword IS NULL OR :keyword = '' OR LOWER(e.note) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(e.category) LIKE LOWER(CONCAT('%', :keyword, '%'))) " +
           "ORDER BY e.date DESC, e.createdAt DESC")
    List<Expense> searchExpenses(
            @Param("user") User user,
            @Param("category") String category,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate,
            @Param("keyword") String keyword
    );

    @Query("SELECT COALESCE(SUM(e.amount), 0) FROM Expense e WHERE e.user = :user AND e.date = :date")
    BigDecimal sumAmountByUserAndDate(@Param("user") User user, @Param("date") LocalDate date);

    @Query("SELECT COALESCE(SUM(e.amount), 0) FROM Expense e WHERE e.user = :user AND e.date >= :startDate AND e.date <= :endDate")
    BigDecimal sumAmountByUserAndDateBetween(
            @Param("user") User user,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate
    );

    @Query("SELECT e.category as category, COALESCE(SUM(e.amount), 0) as totalAmount, COUNT(e) as count " +
           "FROM Expense e WHERE e.user = :user GROUP BY e.category ORDER BY SUM(e.amount) DESC")
    List<Object[]> findCategoryExpenseTotals(@Param("user") User user);

    @Query("SELECT e.date as date, COALESCE(SUM(e.amount), 0) as totalAmount " +
           "FROM Expense e WHERE e.user = :user AND e.date >= :startDate AND e.date <= :endDate " +
           "GROUP BY e.date ORDER BY e.date ASC")
    List<Object[]> findDailyExpenseTotals(
            @Param("user") User user,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate
    );
}
