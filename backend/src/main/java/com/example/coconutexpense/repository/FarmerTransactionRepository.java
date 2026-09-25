package com.example.coconutexpense.repository;

import com.example.coconutexpense.entity.Farmer;
import com.example.coconutexpense.entity.FarmerTransaction;
import com.example.coconutexpense.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

public interface FarmerTransactionRepository extends JpaRepository<FarmerTransaction, Long> {

    List<FarmerTransaction> findByFarmerOrderByDateDescCreatedAtDesc(Farmer farmer);

    List<FarmerTransaction> findByFarmer_UserOrderByDateDescCreatedAtDesc(User user);

    Optional<FarmerTransaction> findByIdAndFarmer(Long id, Farmer farmer);

    @Query("SELECT COALESCE(SUM(ft.amountGiven), 0) FROM FarmerTransaction ft WHERE ft.farmer = :farmer")
    BigDecimal sumAmountGivenByFarmer(@Param("farmer") Farmer farmer);
}
