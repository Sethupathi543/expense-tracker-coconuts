package com.example.coconutexpense.controller;

import com.example.coconutexpense.dto.*;
import com.example.coconutexpense.service.CoconutBusinessService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/farmers")
@CrossOrigin(origins = "*")
public class FarmerController {

    @Autowired
    private CoconutBusinessService coconutBusinessService;

    // Farmer CRUD
    @PostMapping
    public ResponseEntity<FarmerResponse> addFarmer(@Valid @RequestBody FarmerRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(coconutBusinessService.addFarmer(request));
    }

    @GetMapping
    public ResponseEntity<List<FarmerResponse>> getAllFarmers() {
        return ResponseEntity.ok(coconutBusinessService.getAllFarmers());
    }

    @GetMapping("/transactions")
    public ResponseEntity<List<FarmerTransactionResponse>> getAllTransactions() {
        return ResponseEntity.ok(coconutBusinessService.getAllFarmerTransactions());
    }

    @GetMapping("/{id}")
    public ResponseEntity<FarmerResponse> getFarmerById(@PathVariable Long id) {
        return ResponseEntity.ok(coconutBusinessService.getFarmerById(id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<FarmerResponse> updateFarmer(
            @PathVariable Long id, @Valid @RequestBody FarmerRequest request) {
        return ResponseEntity.ok(coconutBusinessService.updateFarmer(id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteFarmer(@PathVariable Long id) {
        coconutBusinessService.deleteFarmer(id);
        return ResponseEntity.noContent().build();
    }

    // Farmer Transactions
    @PostMapping("/{farmerId}/transactions")
    public ResponseEntity<FarmerTransactionResponse> addTransaction(
            @PathVariable Long farmerId,
            @Valid @RequestBody FarmerTransactionRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(coconutBusinessService.addFarmerTransaction(farmerId, request));
    }

    @GetMapping("/{farmerId}/transactions")
    public ResponseEntity<List<FarmerTransactionResponse>> getTransactions(@PathVariable Long farmerId) {
        return ResponseEntity.ok(coconutBusinessService.getFarmerTransactions(farmerId));
    }

    @DeleteMapping("/{farmerId}/transactions/{txId}")
    public ResponseEntity<Void> deleteTransaction(
            @PathVariable Long farmerId, @PathVariable Long txId) {
        coconutBusinessService.deleteFarmerTransaction(farmerId, txId);
        return ResponseEntity.noContent().build();
    }
}
