package com.echoes.flutterbackend.exception;

import jakarta.persistence.EntityNotFoundException;
import jakarta.validation.ConstraintViolationException;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<ProblemResponse> handleDuplicateKey(DataIntegrityViolationException ex) {
        String message = ex.getMostSpecificCause() != null
                ? ex.getMostSpecificCause().getMessage()
                : "Data constraint violation";

        String userMessage = message;

        String lower = message.toLowerCase();
        if (lower.contains("password cannot be empty")) {
            userMessage = "Password cannot be empty";
        } else if (lower.contains("email") && lower.contains("exists")) {
            userMessage = "Email already exists";
        } else if (lower.contains("username")) {
            userMessage = "Username already exists";
        }

        return build(HttpStatus.CONFLICT, userMessage);
    }

    @ExceptionHandler(EntityNotFoundException.class)
    public ResponseEntity<ProblemResponse> handleNotFound(EntityNotFoundException ex) {
        return build(HttpStatus.NOT_FOUND, ex.getMessage());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ProblemResponse> handleValidation(MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();
        for (FieldError fieldError : ex.getBindingResult().getFieldErrors()) {
            errors.put(fieldError.getField(), fieldError.getDefaultMessage());
        }
        return build(HttpStatus.BAD_REQUEST, "Validation failed", errors);
    }

    @ExceptionHandler(ConstraintViolationException.class)
    public ResponseEntity<ProblemResponse> handleConstraintViolation(ConstraintViolationException ex) {
        return build(HttpStatus.BAD_REQUEST, ex.getMessage());
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ProblemResponse> handleGeneral(Exception ex) {
        return build(HttpStatus.INTERNAL_SERVER_ERROR, ex.getMessage());
    }

    private ResponseEntity<ProblemResponse> build(HttpStatus status, String message) {
        return build(status, message, null);
    }

    private ResponseEntity<ProblemResponse> build(HttpStatus status, String message, Map<String, String> details) {
        return ResponseEntity.status(status)
                .body(new ProblemResponse(status.value(), message, details));
    }

    public record ProblemResponse(int status, String message, Map<String, String> details, Instant timestamp) {
        public ProblemResponse(int status, String message, Map<String, String> details) {
            this(status, message, details, Instant.now());
        }
    }
}
