package com.example.coconutexpense.repository;

import com.example.coconutexpense.entity.Trader;
import com.example.coconutexpense.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

public interface TraderRepository extends JpaRepository<Trader, Long> {

    List<Trader> findByUserAndDeletedFalseOrderByCreatedAtDesc(User user);

    Optional<Trader> findByIdAndUserAndDeletedFalse(Long id, User user);

    Optional<Trader> findByUserAndNameIgnoreCase(User user, String name);

    @Query("SELECT COALESCE(SUM(tt.amountReceived), 0) FROM TraderTransaction tt WHERE tt.trader.user = :user AND tt.trader.deleted = false")
    BigDecimal sumTotalReceivedByUser(@Param("user") User user);

    @Query("SELECT COALESCE(SUM(t.totalSaleAmount), 0) FROM Trader t WHERE t.user = :user AND t.deleted = false")
    BigDecimal sumTotalSalesByUser(@Param("user") User user);
}
