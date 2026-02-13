package com.echoes.flutterbackend.controller;

import com.echoes.flutterbackend.dto.ChangePasswordRequest;
import com.echoes.flutterbackend.dto.ForgotPasswordRequest;
import com.echoes.flutterbackend.dto.LoginRequest;
import com.echoes.flutterbackend.dto.ResetPasswordRequest;
import com.echoes.flutterbackend.dto.UpdateProfileRequest;
import com.echoes.flutterbackend.entity.User;
import com.echoes.flutterbackend.repository.UserRepository;
import com.echoes.flutterbackend.security.JwtTokenProvider;
import com.echoes.flutterbackend.service.UserService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/v1/users")
@CrossOrigin(origins = "*")
public class UserController {

    private final UserService userService;
    private final UserRepository userRepository;
    private final JwtTokenProvider jwt;

    public UserController(UserService userService, UserRepository userRepository, JwtTokenProvider jwt) {
        this.userService = userService;
        this.userRepository = userRepository;
        this.jwt = jwt;
    }

    /**
     * Регистрация нового пользователя
     */
    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody User req) {
        if (req.getPassword() == null || req.getPassword().isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Password cannot be empty"));
        }
        if (userRepository.findByEmail(req.getEmail()).isPresent()) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of("message", "Email already exists"));
        }
        if (req.getUsername() != null && userRepository.findByUsername(req.getUsername()).isPresent()) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of("message", "Username already exists"));
        }

        User saved = userService.register(req);
        return ResponseEntity.ok(Map.of(
                "id", saved.getId(),
                "email", saved.getEmail(),
                "username", saved.getUsername(),
                "role", saved.getRole(),
                "message", "Registration successful"
        ));
    }

    /**
     * Авторизация пользователя
     */
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest req) {
        String email = req.getEmail();
        String password = req.getPassword();

        return userService.login(email, password)
                .map(user -> {
                    // ✅ generateAccessToken включает роль
                    String token = jwt.generateAccessToken(email, user.getRole());
                    return ResponseEntity.ok(Map.of(
                            "token", token,
                            "id", user.getId(),
                            "email", user.getEmail(),
                            "username", user.getUsername(),
                            "role", user.getRole()
                    ));
                })
                .orElseGet(() -> ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(Map.of("message", "Invalid email or password")));
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(@RequestBody ForgotPasswordRequest req) {
        String token = userService.initiatePasswordReset(req.getEmail());
        if (token == null) {
            return ResponseEntity.ok(Map.of(
                    "message", "If account exists, reset instructions are generated"
            ));
        }
        // Demo mode: token is returned directly instead of email delivery.
        return ResponseEntity.ok(Map.of(
                "message", "Reset token generated",
                "resetToken", token
        ));
    }

    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@RequestBody ResetPasswordRequest req) {
        boolean changed = userService.resetPasswordByToken(req.getToken(), req.getNewPassword());
        if (!changed) {
            return ResponseEntity.badRequest().body(Map.of("message", "Invalid or expired reset token"));
        }
        return ResponseEntity.ok(Map.of("message", "Password updated"));
    }

    /**
     * Получить текущего пользователя (по токену)
     */
    @GetMapping("/me")
    public ResponseEntity<?> me(@RequestHeader("Authorization") String auth) {
        if (auth == null || !auth.startsWith("Bearer ")) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Missing token"));
        }

        String token = auth.substring(7);
        if (!jwt.validateToken(token)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("message", "Invalid token"));
        }

        String email = jwt.getUsernameFromToken(token);
        Optional<User> userOpt = userRepository.findByEmail(email);
        if (userOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "User not found"));
        }

        User user = userOpt.get();
        return ResponseEntity.ok(Map.of(
                "id", user.getId(),
                "email", user.getEmail(),
                "username", user.getUsername(),
                "role", user.getRole()
        ));
    }

    @PutMapping("/me")
    public ResponseEntity<?> updateProfile(@RequestHeader("Authorization") String auth,
                                           @RequestBody UpdateProfileRequest req) {
        User user = userService.getUserFromAuthHeader(auth);

        String email = req.getEmail();
        if (email != null && !email.isBlank()) {
            userService.assertEmailAvailable(email, user.getId());
            user.setEmail(email.trim());
        }

        String username = req.getUsername();
        if (username != null && !username.isBlank()) {
            userService.assertUsernameAvailable(username, user.getId());
            user.setUsername(username.trim());
        }

        String name = req.getName();
        if (name != null && !name.isBlank()) {
            user.setName(name.trim());
        }

        User saved = userRepository.save(user);
        return ResponseEntity.ok(Map.of(
                "id", saved.getId(),
                "email", saved.getEmail(),
                "username", saved.getUsername(),
                "name", saved.getName(),
                "role", saved.getRole()
        ));
    }

    @PutMapping("/me/password")
    public ResponseEntity<?> changePassword(@RequestHeader("Authorization") String auth,
                                            @RequestBody ChangePasswordRequest req) {
        User user = userService.getUserFromAuthHeader(auth);

        if (req.getCurrentPassword() == null || req.getCurrentPassword().isBlank()
                || req.getNewPassword() == null || req.getNewPassword().isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Current and new password are required"));
        }

        boolean changed = userService.changePassword(user, req.getCurrentPassword(), req.getNewPassword());
        if (!changed) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("message", "Invalid current password"));
        }
        return ResponseEntity.ok(Map.of("message", "Password updated"));
    }

    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/{id}/role")
    public ResponseEntity<?> updateUserRole(@PathVariable Long id, @RequestBody Map<String, String> body) {
        String role = body.get("role");
        if (role == null || role.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Role is required"));
        }
        String normalized = role.trim().toUpperCase();
        if (!normalized.equals("ADMIN") && !normalized.equals("USER")) {
            return ResponseEntity.badRequest().body(Map.of("message", "Invalid role"));
        }

        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found"));
        user.setRole(normalized);
        userRepository.save(user);

        return ResponseEntity.ok(Map.of(
                "id", user.getId(),
                "email", user.getEmail(),
                "role", user.getRole()
        ));
    }
}
