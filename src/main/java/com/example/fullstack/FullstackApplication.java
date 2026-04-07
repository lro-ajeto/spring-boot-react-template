package com.example.fullstack;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.info.Info;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@OpenAPIDefinition(
        info = @Info(
                title = "FullStack API",
                version = "1.0",
                description = "API documentation for Fullstack Project"
        )
)
@SpringBootApplication
public class FullstackApplication {

    public static void main(String[] args) {
        SpringApplication.run(FullstackApplication.class, args);
    }
}
