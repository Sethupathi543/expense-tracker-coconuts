package com.example.coconutexpense.controller;

import com.example.coconutexpense.dto.CoconutSummaryResponse;
import com.example.coconutexpense.service.CoconutBusinessService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/coconut")
@CrossOrigin(origins = "*")
public class CoconutController {

    @Autowired
    private CoconutBusinessService coconutBusinessService;

    @GetMapping("/summary")
    public ResponseEntity<CoconutSummaryResponse> getSummary() {
        return ResponseEntity.ok(coconutBusinessService.getSummary());
    }
}
