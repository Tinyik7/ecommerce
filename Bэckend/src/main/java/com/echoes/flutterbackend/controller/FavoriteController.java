package com.echoes.flutterbackend.controller;

import com.echoes.flutterbackend.dto.ProductResponse;
import com.echoes.flutterbackend.entity.Favorite;
import com.echoes.flutterbackend.repository.UserRepository;
import com.echoes.flutterbackend.security.JwtTokenProvider;
import com.echoes.flutterbackend.service.FavoriteService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/v1/favorites")
@CrossOrigin(origins = "http://localhost:52044") // ⚠️ Замени на порт фронта
public class FavoriteController {

    private final FavoriteService favoriteService;
    private final JwtTokenProvider jwtTokenProvider;
    private final UserRepository userRepository;

    public FavoriteController(FavoriteService favoriteService,
                              JwtTokenProvider jwtTokenProvider,
                              UserRepository userRepository) {
        this.favoriteService = favoriteService;
        this.jwtTokenProvider = jwtTokenProvider;
        this.userRepository = userRepository;
    }

    /**
     * Получить все избранные товары пользователя
     */
    @GetMapping("/{userId}")
    public ResponseEntity<List<ProductResponse>> getFavorites(@PathVariable Long userId,
                                                              @RequestHeader(value = "Authorization", required = false) String auth) {
        assertUserMatchesToken(userId, auth);
        return ResponseEntity.ok(favoriteService.getFavoriteProducts(userId));
    }

    /**
     * Добавить товар в избранное
     */
    @PostMapping("/{userId}/add")
    public ResponseEntity<?> addFavorite(@PathVariable Long userId,
                                         @RequestHeader(value = "Authorization", required = false) String auth,
                                         @RequestBody Map<String, Object> body) {
        assertUserMatchesToken(userId, auth);
        try {
            if (body == null || !body.containsKey("productId")) {
                return ResponseEntity.badRequest().body(Map.of("error", "Missing field: productId"));
            }

            Long productId = ((Number) body.get("productId")).longValue();
            Optional<Favorite> added = favoriteService.addFavorite(userId, productId);

            // Если уже в избранном — возвращаем понятное сообщение
            return added.<ResponseEntity<?>>map(ResponseEntity::ok)
                    .orElseGet(() -> ResponseEntity.ok(Map.of(
                            "message", "Already in favorites",
                            "productId", productId
                    )));

        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of(
                    "error", "Error adding favorite",
                    "details", e.getMessage()
            ));
        }
    }

    /**
     * Удалить товар из избранного
     */
    @DeleteMapping("/{userId}/remove/{productId}")
    public ResponseEntity<?> removeFavorite(@PathVariable Long userId,
                                            @PathVariable Long productId,
                                            @RequestHeader(value = "Authorization", required = false) String auth) {
        assertUserMatchesToken(userId, auth);
        try {
            boolean removed = favoriteService.removeFavorite(userId, productId);
            if (removed) {
                return ResponseEntity.ok(Map.of("message", "Removed from favorites"));
            } else {
                return ResponseEntity.status(404).body(Map.of(
                        "error", "Favorite not found",
                        "productId", productId
                ));
            }
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(Map.of(
                    "error", "Error removing favorite",
                    "details", e.getMessage()
            ));
        }
    }

    private void assertUserMatchesToken(Long userId, String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Missing token");
        }
        String token = authHeader.substring(7);
        if (!jwtTokenProvider.validateToken(token)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid token");
        }
        String email = jwtTokenProvider.getUsernameFromToken(token);
        Long tokenUserId = userRepository.findByEmail(email)
                .map(u -> u.getId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "User not found"));
        if (!tokenUserId.equals(userId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Access denied");
        }
    }
}
