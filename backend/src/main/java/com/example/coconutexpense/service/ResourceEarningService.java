package com.example.coconutexpense.service;

import com.example.coconutexpense.dto.ResourceEarningRequest;
import com.example.coconutexpense.dto.ResourceEarningResponse;
import com.example.coconutexpense.dto.ResourceEarningSummaryResponse;
import com.example.coconutexpense.entity.ResourceEarning;
import com.example.coconutexpense.entity.User;
import com.example.coconutexpense.exception.ResourceNotFoundException;
import com.example.coconutexpense.repository.ResourceEarningRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class ResourceEarningService {

    @Autowired
    private ResourceEarningRepository repository;

    @Autowired
    private AuthService authService;

    public ResourceEarningResponse addEarning(ResourceEarningRequest request) {
        User user = authService.getCurrentAuthenticatedUser();
        ResourceEarning earning = new ResourceEarning();
        earning.setUser(user);
        earning.setResourceType(request.getResourceType());
        earning.setQuantity(request.getQuantity());
        earning.setUnit(request.getUnit());
        earning.setRatePerUnit(request.getRatePerUnit());
        earning.setTotalAmount(request.getTotalAmount());
        earning.setBuyerName(request.getBuyerName());
        earning.setDate(request.getDate());
        earning.setPaymentMethod(request.getPaymentMethod());
        earning.setNote(request.getNote());
        ResourceEarning saved = repository.save(earning);
        return toResponse(saved);
    }

    public List<ResourceEarningResponse> getAllEarnings(String resourceType) {
        User user = authService.getCurrentAuthenticatedUser();
        List<ResourceEarning> list;
        if (resourceType != null && !resourceType.isBlank() && !resourceType.equalsIgnoreCase("all")) {
            list = repository.findByUserAndResourceTypeIgnoreCaseOrderByDateDescCreatedAtDesc(user, resourceType);
        } else {
            list = repository.findByUserOrderByDateDescCreatedAtDesc(user);
        }
        return list.stream().map(this::toResponse).collect(Collectors.toList());
    }

    public ResourceEarningResponse getEarningById(Long id) {
        User user = authService.getCurrentAuthenticatedUser();
        ResourceEarning earning = repository.findById(id)
                .filter(e -> e.getUser().getId().equals(user.getId()))
                .orElseThrow(() -> new ResourceNotFoundException("Resource earning not found with id: " + id));
        return toResponse(earning);
    }

    public void deleteEarning(Long id) {
        User user = authService.getCurrentAuthenticatedUser();
        ResourceEarning earning = repository.findById(id)
                .filter(e -> e.getUser().getId().equals(user.getId()))
                .orElseThrow(() -> new ResourceNotFoundException("Resource earning not found with id: " + id));
        repository.delete(earning);
    }

    public ResourceEarningSummaryResponse getSummary() {
        User user = authService.getCurrentAuthenticatedUser();
        BigDecimal total = repository.sumTotalByUser(user);
        BigDecimal thotti = repository.sumTotalByUserAndResourceType(user, "Thotti");
        BigDecimal mattai = repository.sumTotalByUserAndResourceType(user, "Mattai");
        BigDecimal paruppu = repository.sumTotalByUserAndResourceType(user, "Paruppu");
        return new ResourceEarningSummaryResponse(total, thotti, mattai, paruppu);
    }

    private ResourceEarningResponse toResponse(ResourceEarning entity) {
        ResourceEarningResponse res = new ResourceEarningResponse();
        res.setId(entity.getId());
        res.setResourceType(entity.getResourceType());
        res.setQuantity(entity.getQuantity());
        res.setUnit(entity.getUnit());
        res.setRatePerUnit(entity.getRatePerUnit());
        res.setTotalAmount(entity.getTotalAmount());
        res.setBuyerName(entity.getBuyerName());
        res.setDate(entity.getDate());
        res.setPaymentMethod(entity.getPaymentMethod());
        res.setNote(entity.getNote());
        res.setCreatedAt(entity.getCreatedAt());
        return res;
    }
}
