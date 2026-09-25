package com.example.coconutexpense.service;

import com.example.coconutexpense.dto.*;
import com.example.coconutexpense.entity.*;
import com.example.coconutexpense.exception.BadRequestException;
import com.example.coconutexpense.exception.ResourceNotFoundException;
import com.example.coconutexpense.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class CoconutBusinessService {

    @Autowired
    private FarmerRepository farmerRepository;

    @Autowired
    private FarmerTransactionRepository farmerTransactionRepository;

    @Autowired
    private TraderRepository traderRepository;

    @Autowired
    private TraderTransactionRepository traderTransactionRepository;

    @Autowired
    private AuthService authService;

    // ===================== FARMER =====================

    public FarmerResponse addFarmer(FarmerRequest request) {
        User user = authService.getCurrentAuthenticatedUser();
        String name = request.getName().trim();

        // Check if farmer already exists (active or soft-deleted)
        var existingOpt = farmerRepository.findByUserAndNameIgnoreCase(user, name);
        if (existingOpt.isPresent()) {
            Farmer existing = existingOpt.get();
            if (Boolean.TRUE.equals(existing.getDeleted())) {
                // Restore previously soft-deleted farmer with historical data preserved
                existing.setDeleted(false);
                if (request.getPhone() != null && !request.getPhone().isBlank()) {
                    existing.setPhone(request.getPhone());
                }
                if (request.getLocation() != null && !request.getLocation().isBlank()) {
                    existing.setLocation(request.getLocation());
                }
                if (request.getNote() != null && !request.getNote().isBlank()) {
                    existing.setNote(request.getNote());
                }
                if (request.getTotalPurchaseAmount() != null) {
                    existing.setTotalPurchaseAmount(existing.getTotalPurchaseAmount().add(request.getTotalPurchaseAmount()));
                }
                Farmer saved = farmerRepository.save(existing);
                BigDecimal paid = farmerTransactionRepository.sumAmountGivenByFarmer(saved);
                return toFarmerResponse(saved, paid);
            } else {
                throw new BadRequestException("Farmer with name '" + name + "' already exists.");
            }
        }

        Farmer farmer = new Farmer();
        farmer.setUser(user);
        farmer.setName(name);
        farmer.setPhone(request.getPhone());
        farmer.setLocation(request.getLocation());
        farmer.setTotalPurchaseAmount(request.getTotalPurchaseAmount());
        farmer.setNote(request.getNote());
        farmer.setDeleted(false);
        Farmer saved = farmerRepository.save(farmer);
        return toFarmerResponse(saved, BigDecimal.ZERO);
    }

    public List<FarmerResponse> getAllFarmers() {
        User user = authService.getCurrentAuthenticatedUser();
        return farmerRepository.findByUserAndDeletedFalseOrderByCreatedAtDesc(user).stream()
                .map(f -> {
                    BigDecimal paid = farmerTransactionRepository.sumAmountGivenByFarmer(f);
                    return toFarmerResponse(f, paid);
                })
                .collect(Collectors.toList());
    }

    public FarmerResponse getFarmerById(Long farmerId) {
        User user = authService.getCurrentAuthenticatedUser();
        Farmer farmer = farmerRepository.findByIdAndUserAndDeletedFalse(farmerId, user)
                .orElseThrow(() -> new ResourceNotFoundException("Farmer not found with id: " + farmerId));
        BigDecimal paid = farmerTransactionRepository.sumAmountGivenByFarmer(farmer);
        return toFarmerResponse(farmer, paid);
    }

    public FarmerResponse updateFarmer(Long farmerId, FarmerRequest request) {
        User user = authService.getCurrentAuthenticatedUser();
        Farmer farmer = farmerRepository.findByIdAndUserAndDeletedFalse(farmerId, user)
                .orElseThrow(() -> new ResourceNotFoundException("Farmer not found with id: " + farmerId));

        // Ensure new totalPurchaseAmount >= already paid
        BigDecimal paid = farmerTransactionRepository.sumAmountGivenByFarmer(farmer);
        if (request.getTotalPurchaseAmount().compareTo(paid) < 0) {
            throw new BadRequestException("Total purchase amount cannot be less than amount already paid (" + paid + ")");
        }

        farmer.setName(request.getName());
        farmer.setPhone(request.getPhone());
        farmer.setLocation(request.getLocation());
        farmer.setTotalPurchaseAmount(request.getTotalPurchaseAmount());
        farmer.setNote(request.getNote());
        Farmer saved = farmerRepository.save(farmer);
        return toFarmerResponse(saved, paid);
    }

    public void deleteFarmer(Long farmerId) {
        User user = authService.getCurrentAuthenticatedUser();
        Farmer farmer = farmerRepository.findByIdAndUserAndDeletedFalse(farmerId, user)
                .orElseThrow(() -> new ResourceNotFoundException("Farmer not found with id: " + farmerId));
        farmer.setDeleted(true);
        farmerRepository.save(farmer);
    }

    // ===================== FARMER TRANSACTIONS =====================

    public FarmerTransactionResponse addFarmerTransaction(Long farmerId, FarmerTransactionRequest request) {
        User user = authService.getCurrentAuthenticatedUser();
        Farmer farmer = farmerRepository.findByIdAndUserAndDeletedFalse(farmerId, user)
                .orElseThrow(() -> new ResourceNotFoundException("Farmer not found with id: " + farmerId));

        BigDecimal alreadyPaid = farmerTransactionRepository.sumAmountGivenByFarmer(farmer);
        BigDecimal newTotal = alreadyPaid.add(request.getAmountGiven());

        if (newTotal.compareTo(farmer.getTotalPurchaseAmount()) > 0) {
            BigDecimal maxAllowed = farmer.getTotalPurchaseAmount().subtract(alreadyPaid);
            throw new BadRequestException(
                "Payment exceeds remaining balance. Maximum allowed: ₹" + maxAllowed);
        }

        FarmerTransaction tx = new FarmerTransaction();
        tx.setFarmer(farmer);
        tx.setAmountGiven(request.getAmountGiven());
        tx.setDate(request.getDate());
        tx.setPaymentMethod(request.getPaymentMethod());
        tx.setNote(request.getNote());
        FarmerTransaction saved = farmerTransactionRepository.save(tx);
        return toFarmerTransactionResponse(saved);
    }

    public List<FarmerTransactionResponse> getFarmerTransactions(Long farmerId) {
        User user = authService.getCurrentAuthenticatedUser();
        Farmer farmer = farmerRepository.findByIdAndUserAndDeletedFalse(farmerId, user)
                .orElseThrow(() -> new ResourceNotFoundException("Farmer not found with id: " + farmerId));
        return farmerTransactionRepository.findByFarmerOrderByDateDescCreatedAtDesc(farmer).stream()
                .map(this::toFarmerTransactionResponse)
                .collect(Collectors.toList());
    }

    public List<FarmerTransactionResponse> getAllFarmerTransactions() {
        User user = authService.getCurrentAuthenticatedUser();
        return farmerTransactionRepository.findByFarmer_UserOrderByDateDescCreatedAtDesc(user).stream()
                .map(this::toFarmerTransactionResponse)
                .collect(Collectors.toList());
    }

    public void deleteFarmerTransaction(Long farmerId, Long txId) {
        User user = authService.getCurrentAuthenticatedUser();
        Farmer farmer = farmerRepository.findByIdAndUserAndDeletedFalse(farmerId, user)
                .orElseThrow(() -> new ResourceNotFoundException("Farmer not found with id: " + farmerId));
        FarmerTransaction tx = farmerTransactionRepository.findByIdAndFarmer(txId, farmer)
                .orElseThrow(() -> new ResourceNotFoundException("Transaction not found with id: " + txId));
        farmerTransactionRepository.delete(tx);
    }

    // ===================== TRADER =====================

    public TraderResponse addTrader(TraderRequest request) {
        User user = authService.getCurrentAuthenticatedUser();
        String name = request.getName().trim();

        // Check if trader already exists (active or soft-deleted)
        var existingOpt = traderRepository.findByUserAndNameIgnoreCase(user, name);
        if (existingOpt.isPresent()) {
            Trader existing = existingOpt.get();
            if (Boolean.TRUE.equals(existing.getDeleted())) {
                // Restore previously soft-deleted trader with historical data preserved
                existing.setDeleted(false);
                if (request.getPhone() != null && !request.getPhone().isBlank()) {
                    existing.setPhone(request.getPhone());
                }
                if (request.getLocation() != null && !request.getLocation().isBlank()) {
                    existing.setLocation(request.getLocation());
                }
                if (request.getNote() != null && !request.getNote().isBlank()) {
                    existing.setNote(request.getNote());
                }
                if (request.getTotalSaleAmount() != null) {
                    existing.setTotalSaleAmount(existing.getTotalSaleAmount().add(request.getTotalSaleAmount()));
                }
                Trader saved = traderRepository.save(existing);
                BigDecimal received = traderTransactionRepository.sumAmountReceivedByTrader(saved);
                return toTraderResponse(saved, received);
            } else {
                throw new BadRequestException("Trader with name '" + name + "' already exists.");
            }
        }

        Trader trader = new Trader();
        trader.setUser(user);
        trader.setName(name);
        trader.setPhone(request.getPhone());
        trader.setLocation(request.getLocation());
        trader.setTotalSaleAmount(request.getTotalSaleAmount());
        trader.setNote(request.getNote());
        trader.setDeleted(false);
        Trader saved = traderRepository.save(trader);
        return toTraderResponse(saved, BigDecimal.ZERO);
    }

    public List<TraderResponse> getAllTraders() {
        User user = authService.getCurrentAuthenticatedUser();
        return traderRepository.findByUserAndDeletedFalseOrderByCreatedAtDesc(user).stream()
                .map(t -> {
                    BigDecimal received = traderTransactionRepository.sumAmountReceivedByTrader(t);
                    return toTraderResponse(t, received);
                })
                .collect(Collectors.toList());
    }

    public TraderResponse getTraderById(Long traderId) {
        User user = authService.getCurrentAuthenticatedUser();
        Trader trader = traderRepository.findByIdAndUserAndDeletedFalse(traderId, user)
                .orElseThrow(() -> new ResourceNotFoundException("Trader not found with id: " + traderId));
        BigDecimal received = traderTransactionRepository.sumAmountReceivedByTrader(trader);
        return toTraderResponse(trader, received);
    }

    public TraderResponse updateTrader(Long traderId, TraderRequest request) {
        User user = authService.getCurrentAuthenticatedUser();
        Trader trader = traderRepository.findByIdAndUserAndDeletedFalse(traderId, user)
                .orElseThrow(() -> new ResourceNotFoundException("Trader not found with id: " + traderId));

        BigDecimal received = traderTransactionRepository.sumAmountReceivedByTrader(trader);
        if (request.getTotalSaleAmount().compareTo(received) < 0) {
            throw new BadRequestException("Total sale amount cannot be less than amount already received (" + received + ")");
        }

        trader.setName(request.getName());
        trader.setPhone(request.getPhone());
        trader.setLocation(request.getLocation());
        trader.setTotalSaleAmount(request.getTotalSaleAmount());
        trader.setNote(request.getNote());
        Trader saved = traderRepository.save(trader);
        return toTraderResponse(saved, received);
    }

    public void deleteTrader(Long traderId) {
        User user = authService.getCurrentAuthenticatedUser();
        Trader trader = traderRepository.findByIdAndUserAndDeletedFalse(traderId, user)
                .orElseThrow(() -> new ResourceNotFoundException("Trader not found with id: " + traderId));
        trader.setDeleted(true);
        traderRepository.save(trader);
    }

    // ===================== TRADER TRANSACTIONS =====================

    public TraderTransactionResponse addTraderTransaction(Long traderId, TraderTransactionRequest request) {
        User user = authService.getCurrentAuthenticatedUser();
        Trader trader = traderRepository.findByIdAndUserAndDeletedFalse(traderId, user)
                .orElseThrow(() -> new ResourceNotFoundException("Trader not found with id: " + traderId));

        BigDecimal alreadyReceived = traderTransactionRepository.sumAmountReceivedByTrader(trader);
        BigDecimal newTotal = alreadyReceived.add(request.getAmountReceived());

        if (newTotal.compareTo(trader.getTotalSaleAmount()) > 0) {
            BigDecimal maxAllowed = trader.getTotalSaleAmount().subtract(alreadyReceived);
            throw new BadRequestException(
                "Amount exceeds pending balance. Maximum allowed: ₹" + maxAllowed);
        }

        TraderTransaction tx = new TraderTransaction();
        tx.setTrader(trader);
        tx.setAmountReceived(request.getAmountReceived());
        tx.setDate(request.getDate());
        tx.setPaymentMethod(request.getPaymentMethod());
        tx.setNote(request.getNote());
        TraderTransaction saved = traderTransactionRepository.save(tx);
        return toTraderTransactionResponse(saved);
    }

    public List<TraderTransactionResponse> getTraderTransactions(Long traderId) {
        User user = authService.getCurrentAuthenticatedUser();
        Trader trader = traderRepository.findByIdAndUserAndDeletedFalse(traderId, user)
                .orElseThrow(() -> new ResourceNotFoundException("Trader not found with id: " + traderId));
        return traderTransactionRepository.findByTraderOrderByDateDescCreatedAtDesc(trader).stream()
                .map(this::toTraderTransactionResponse)
                .collect(Collectors.toList());
    }

    public List<TraderTransactionResponse> getAllTraderTransactions() {
        User user = authService.getCurrentAuthenticatedUser();
        return traderTransactionRepository.findByTrader_UserOrderByDateDescCreatedAtDesc(user).stream()
                .map(this::toTraderTransactionResponse)
                .collect(Collectors.toList());
    }

    public void deleteTraderTransaction(Long traderId, Long txId) {
        User user = authService.getCurrentAuthenticatedUser();
        Trader trader = traderRepository.findByIdAndUserAndDeletedFalse(traderId, user)
                .orElseThrow(() -> new ResourceNotFoundException("Trader not found with id: " + traderId));
        TraderTransaction tx = traderTransactionRepository.findByIdAndTrader(txId, trader)
                .orElseThrow(() -> new ResourceNotFoundException("Transaction not found with id: " + txId));
        traderTransactionRepository.delete(tx);
    }

    // ===================== SUMMARY =====================

    public CoconutSummaryResponse getSummary() {
        User user = authService.getCurrentAuthenticatedUser();

        BigDecimal totalFarmerPurchase = farmerRepository.sumTotalPurchaseByUser(user);
        BigDecimal totalFarmerPaid = farmerRepository.sumTotalPaidByUser(user);
        BigDecimal farmerPending = totalFarmerPurchase.subtract(totalFarmerPaid);

        BigDecimal totalTraderSales = traderRepository.sumTotalSalesByUser(user);
        BigDecimal totalTraderReceived = traderRepository.sumTotalReceivedByUser(user);
        BigDecimal traderPending = totalTraderSales.subtract(totalTraderReceived);

        CoconutSummaryResponse response = new CoconutSummaryResponse();
        response.setTotalFarmerPurchase(totalFarmerPurchase);
        response.setTotalFarmerPaid(totalFarmerPaid);
        response.setFarmerPending(farmerPending.compareTo(BigDecimal.ZERO) < 0 ? BigDecimal.ZERO : farmerPending);
        response.setTotalTraderSales(totalTraderSales);
        response.setTotalTraderReceived(totalTraderReceived);
        response.setTraderPending(traderPending.compareTo(BigDecimal.ZERO) < 0 ? BigDecimal.ZERO : traderPending);
        return response;
    }

    // ===================== MAPPERS =====================

    private FarmerResponse toFarmerResponse(Farmer farmer, BigDecimal paid) {
        FarmerResponse r = new FarmerResponse();
        r.setId(farmer.getId());
        r.setName(farmer.getName());
        r.setPhone(farmer.getPhone());
        r.setLocation(farmer.getLocation());
        r.setTotalPurchaseAmount(farmer.getTotalPurchaseAmount());
        r.setTotalPaid(paid);
        BigDecimal remaining = farmer.getTotalPurchaseAmount().subtract(paid);
        r.setRemainingAmount(remaining.compareTo(BigDecimal.ZERO) < 0 ? BigDecimal.ZERO : remaining);
        r.setNote(farmer.getNote());
        r.setCreatedAt(farmer.getCreatedAt());
        return r;
    }

    private FarmerTransactionResponse toFarmerTransactionResponse(FarmerTransaction tx) {
        FarmerTransactionResponse r = new FarmerTransactionResponse();
        r.setId(tx.getId());
        r.setFarmerId(tx.getFarmer().getId());
        r.setFarmerName(tx.getFarmer().getName());
        r.setAmountGiven(tx.getAmountGiven());
        r.setDate(tx.getDate());
        r.setPaymentMethod(tx.getPaymentMethod());
        r.setNote(tx.getNote());
        r.setCreatedAt(tx.getCreatedAt());
        return r;
    }

    private TraderResponse toTraderResponse(Trader trader, BigDecimal received) {
        TraderResponse r = new TraderResponse();
        r.setId(trader.getId());
        r.setName(trader.getName());
        r.setPhone(trader.getPhone());
        r.setLocation(trader.getLocation());
        r.setTotalSaleAmount(trader.getTotalSaleAmount());
        r.setTotalReceived(received);
        BigDecimal remaining = trader.getTotalSaleAmount().subtract(received);
        r.setRemainingAmount(remaining.compareTo(BigDecimal.ZERO) < 0 ? BigDecimal.ZERO : remaining);
        r.setNote(trader.getNote());
        r.setCreatedAt(trader.getCreatedAt());
        return r;
    }

    private TraderTransactionResponse toTraderTransactionResponse(TraderTransaction tx) {
        TraderTransactionResponse r = new TraderTransactionResponse();
        r.setId(tx.getId());
        r.setTraderId(tx.getTrader().getId());
        r.setTraderName(tx.getTrader().getName());
        r.setAmountReceived(tx.getAmountReceived());
        r.setDate(tx.getDate());
        r.setPaymentMethod(tx.getPaymentMethod());
        r.setNote(tx.getNote());
        r.setCreatedAt(tx.getCreatedAt());
        return r;
    }
}
