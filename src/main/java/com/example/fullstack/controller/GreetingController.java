package com.example.fullstack.controller;

import com.example.fullstack.model.Greeting;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;

@RestController
@Tag(name = "Greeting", description = "Greeting API")
public class GreetingController {

    @GetMapping("/api/greeting")
    @Operation(summary = "Get greeting", description = "Returns a greeting message with the current timestamp")
    @ApiResponse(responseCode = "200", description = "Greeting returned successfully")
    public Greeting greeting() {
        return new Greeting("Velkommen til denne workshop!", LocalDateTime.now());
    }
}
