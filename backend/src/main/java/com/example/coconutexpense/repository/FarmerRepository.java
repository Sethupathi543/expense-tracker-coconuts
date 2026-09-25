package com.example.coconutexpense.repository;

import com.example.coconutexpense.entity.Farmer;
import com.example.coconutexpense.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

public interface FarmerRepository extends JpaRepository<Farmer, Long> {

    List<Farmer> findByUserAndDeletedFalseOrderByCreatedAtDesc(User user);

    Optional<Farmer> findByIdAndUserAndDeletedFalse(Long id, User user);

    Optional<Farmer> findByUserAndNameIgnoreCase(User user, String name);

    @Query("SELECT COALESCE(SUM(ft.amountGiven), 0) FROM FarmerTransaction ft WHERE ft.farmer.user = :user AND ft.farmer.deleted = false")
    BigDecimal sumTotalPaidByUser(@Param("user") User user);

    @Query("SELECT COALESCE(SUM(f.totalPurchaseAmount), 0) FROM Farmer f WHERE f.user = :user AND f.deleted = false")
    BigDecimal sumTotalPurchaseByUser(@Param("user") User user);
}
