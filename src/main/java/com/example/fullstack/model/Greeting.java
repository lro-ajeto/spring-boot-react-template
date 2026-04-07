package com.example.fullstack.model;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
public class Greeting {

    private String message;

    private LocalDateTime timestamp;

}
