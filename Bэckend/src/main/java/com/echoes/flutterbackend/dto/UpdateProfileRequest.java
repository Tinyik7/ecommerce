package com.echoes.flutterbackend.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class UpdateProfileRequest {
    @Size(min = 3, max = 50, message = "Username must be 3-50 characters")
    private String username;

    @Size(max = 100, message = "Name must be at most 100 characters")
    private String name;

    @Email(message = "Email format is invalid")
    private String email;
}
