package com.example.coconutexpense.repository;

import com.example.coconutexpense.entity.ResourceEarning;
import com.example.coconutexpense.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.util.List;

public interface ResourceEarningRepository extends JpaRepository<ResourceEarning, Long> {

    List<ResourceEarning> findByUserOrderByDateDescCreatedAtDesc(User user);

    List<ResourceEarning> findByUserAndResourceTypeIgnoreCaseOrderByDateDescCreatedAtDesc(User user, String resourceType);

    @Query("SELECT COALESCE(SUM(r.totalAmount), 0) FROM ResourceEarning r WHERE r.user = :user")
    BigDecimal sumTotalByUser(@Param("user") User user);

    @Query("SELECT COALESCE(SUM(r.totalAmount), 0) FROM ResourceEarning r WHERE r.user = :user AND LOWER(r.resourceType) = LOWER(:resourceType)")
    BigDecimal sumTotalByUserAndResourceType(@Param("user") User user, @Param("resourceType") String resourceType);
}
