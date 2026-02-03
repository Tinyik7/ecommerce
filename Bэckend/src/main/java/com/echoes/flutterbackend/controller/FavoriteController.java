package com.echoes.flutterbackend.controller;

import com.echoes.flutterbackend.dto.ProductResponse;
import com.echoes.flutterbackend.entity.Favorite;
import com.echoes.flutterbackend.service.FavoriteService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/v1/favorites")
@CrossOrigin(origins = "http://localhost:52044") // ⚠️ Замени на порт фронта
public class FavoriteController {

    private final FavoriteService favoriteService;

    public FavoriteController(FavoriteService favoriteService) {
        this.favoriteService = favoriteService;
    }

    /**
     * Получить все избранные товары пользователя
     */
    @GetMapping("/{userId}")
    public ResponseEntity<List<ProductResponse>> getFavorites(@PathVariable Long userId) {
        return ResponseEntity.ok(favoriteService.getFavoriteProducts(userId));
    }

    /**
     * Добавить товар в избранное
     */
    @PostMapping("/{userId}/add")
    public ResponseEntity<?> addFavorite(@PathVariable Long userId, @RequestBody Map<String, Object> body) {
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
    public ResponseEntity<?> removeFavorite(@PathVariable Long userId, @PathVariable Long productId) {
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
}
