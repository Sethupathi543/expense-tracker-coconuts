package com.example.coconutexpense.controller;

import com.example.coconutexpense.dto.ResourceEarningRequest;
import com.example.coconutexpense.dto.ResourceEarningResponse;
import com.example.coconutexpense.dto.ResourceEarningSummaryResponse;
import com.example.coconutexpense.service.ResourceEarningService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/resource-earnings")
@CrossOrigin(origins = "*")
public class ResourceEarningController {

    @Autowired
    private ResourceEarningService service;

    @PostMapping
    public ResponseEntity<ResourceEarningResponse> addEarning(@Valid @RequestBody ResourceEarningRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.addEarning(request));
    }

    @GetMapping
    public ResponseEntity<List<ResourceEarningResponse>> getAllEarnings(@RequestParam(required = false) String resourceType) {
        return ResponseEntity.ok(service.getAllEarnings(resourceType));
    }

    @GetMapping("/summary")
    public ResponseEntity<ResourceEarningSummaryResponse> getSummary() {
        return ResponseEntity.ok(service.getSummary());
    }

    @GetMapping("/{id}")
    public ResponseEntity<ResourceEarningResponse> getEarningById(@PathVariable Long id) {
        return ResponseEntity.ok(service.getEarningById(id));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteEarning(@PathVariable Long id) {
        service.deleteEarning(id);
        return ResponseEntity.noContent().build();
    }
}
