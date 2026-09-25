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
@RequestMapping("/api/traders")
@CrossOrigin(origins = "*")
public class TraderController {

    @Autowired
    private CoconutBusinessService coconutBusinessService;

    // Trader CRUD
    @PostMapping
    public ResponseEntity<TraderResponse> addTrader(@Valid @RequestBody TraderRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(coconutBusinessService.addTrader(request));
    }

    @GetMapping
    public ResponseEntity<List<TraderResponse>> getAllTraders() {
        return ResponseEntity.ok(coconutBusinessService.getAllTraders());
    }

    @GetMapping("/transactions")
    public ResponseEntity<List<TraderTransactionResponse>> getAllTransactions() {
        return ResponseEntity.ok(coconutBusinessService.getAllTraderTransactions());
    }

    @GetMapping("/{id}")
    public ResponseEntity<TraderResponse> getTraderById(@PathVariable Long id) {
        return ResponseEntity.ok(coconutBusinessService.getTraderById(id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<TraderResponse> updateTrader(
            @PathVariable Long id, @Valid @RequestBody TraderRequest request) {
        return ResponseEntity.ok(coconutBusinessService.updateTrader(id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTrader(@PathVariable Long id) {
        coconutBusinessService.deleteTrader(id);
        return ResponseEntity.noContent().build();
    }

    // Trader Transactions
    @PostMapping("/{traderId}/transactions")
    public ResponseEntity<TraderTransactionResponse> addTransaction(
            @PathVariable Long traderId,
            @Valid @RequestBody TraderTransactionRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(coconutBusinessService.addTraderTransaction(traderId, request));
    }

    @GetMapping("/{traderId}/transactions")
    public ResponseEntity<List<TraderTransactionResponse>> getTransactions(@PathVariable Long traderId) {
        return ResponseEntity.ok(coconutBusinessService.getTraderTransactions(traderId));
    }

    @DeleteMapping("/{traderId}/transactions/{txId}")
    public ResponseEntity<Void> deleteTransaction(
            @PathVariable Long traderId, @PathVariable Long txId) {
        coconutBusinessService.deleteTraderTransaction(traderId, txId);
        return ResponseEntity.noContent().build();
    }
}
