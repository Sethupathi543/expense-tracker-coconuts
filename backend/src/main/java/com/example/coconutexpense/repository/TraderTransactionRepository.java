package com.example.coconutexpense.repository;

import com.example.coconutexpense.entity.Trader;
import com.example.coconutexpense.entity.TraderTransaction;
import com.example.coconutexpense.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

public interface TraderTransactionRepository extends JpaRepository<TraderTransaction, Long> {

    List<TraderTransaction> findByTraderOrderByDateDescCreatedAtDesc(Trader trader);

    List<TraderTransaction> findByTrader_UserOrderByDateDescCreatedAtDesc(User user);

    Optional<TraderTransaction> findByIdAndTrader(Long id, Trader trader);

    @Query("SELECT COALESCE(SUM(tt.amountReceived), 0) FROM TraderTransaction tt WHERE tt.trader = :trader")
    BigDecimal sumAmountReceivedByTrader(@Param("trader") Trader trader);
}
