package com.echoes.flutterbackend.dto;

import lombok.Data;

@Data
public class UpdateProfileRequest {
    private String username;
    private String name;
    private String email;
}
