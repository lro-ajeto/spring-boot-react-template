package com.example.fullstack.config;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Map;
import org.springframework.boot.autoconfigure.web.servlet.error.ErrorViewResolver;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpStatus;
import org.springframework.web.servlet.ModelAndView;

@Configuration
public class SpaRedirectConfig {

    @Bean
    public ErrorViewResolver spaFallbackViewResolver() {
        return (HttpServletRequest request, HttpStatus status, Map<String, Object> model) -> {
            if (status != HttpStatus.NOT_FOUND) {
                return null;
            }

            String path = request.getRequestURI();
            if (path == null || path.startsWith("/api") || path.contains(".")) {
                return null;
            }

            return new ModelAndView("forward:/index.html", model);
        };
    }
}
