package com.echoes.flutterbackend.controller;

import com.echoes.flutterbackend.dto.ProductResponse;
import com.echoes.flutterbackend.repository.UserRepository;
import com.echoes.flutterbackend.security.JwtTokenProvider;
import com.echoes.flutterbackend.service.FavoriteService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/favorites")
@CrossOrigin(origins = "http://localhost:52044")
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

    @GetMapping("/{userId}")
    public ResponseEntity<List<ProductResponse>> getFavorites(@PathVariable Long userId,
                                                              @RequestHeader(value = "Authorization", required = false) String auth) {
        assertUserMatchesToken(userId, auth);
        return ResponseEntity.ok(favoriteService.getFavoriteProducts(userId));
    }

    @PostMapping("/{userId}/add")
    public ResponseEntity<?> addFavorite(@PathVariable Long userId,
                                         @RequestHeader(value = "Authorization", required = false) String auth,
                                         @RequestBody Map<String, Object> body) {
        assertUserMatchesToken(userId, auth);
        if (body == null || !body.containsKey("productId")) {
            return ResponseEntity.badRequest().body(Map.of("message", "Missing field: productId"));
        }

        Long productId = ((Number) body.get("productId")).longValue();
        favoriteService.addFavorite(userId, productId);

        return ResponseEntity.ok(Map.of(
                "message", "Added to favorites",
                "productId", productId
        ));
    }

    @DeleteMapping("/{userId}/remove/{productId}")
    public ResponseEntity<?> removeFavorite(@PathVariable Long userId,
                                            @PathVariable Long productId,
                                            @RequestHeader(value = "Authorization", required = false) String auth) {
        assertUserMatchesToken(userId, auth);
        boolean removed = favoriteService.removeFavorite(userId, productId);
        if (removed) {
            return ResponseEntity.ok(Map.of("message", "Removed from favorites"));
        }
        return ResponseEntity.status(404).body(Map.of(
                "message", "Favorite not found",
                "productId", productId
        ));
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
