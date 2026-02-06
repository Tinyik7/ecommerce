package com.echoes.flutterbackend.controller;

import com.echoes.flutterbackend.dto.CartResponse;
import com.echoes.flutterbackend.repository.UserRepository;
import com.echoes.flutterbackend.security.JwtTokenProvider;
import com.echoes.flutterbackend.service.CartService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/cart")
@CrossOrigin(origins = "*")
public class CartController {

    private final CartService cartService;
    private final JwtTokenProvider jwtTokenProvider;
    private final UserRepository userRepository;

    public CartController(CartService cartService,
                          JwtTokenProvider jwtTokenProvider,
                          UserRepository userRepository) {
        this.cartService = cartService;
        this.jwtTokenProvider = jwtTokenProvider;
        this.userRepository = userRepository;
    }

    @GetMapping("/{userId}")
    public ResponseEntity<CartResponse> getCart(@PathVariable Long userId,
                                                @RequestHeader(value = "Authorization", required = false) String auth) {
        assertUserMatchesToken(userId, auth);
        return ResponseEntity.ok(cartService.getCartSnapshot(userId));
    }

    @PostMapping("/{userId}/add")
    public ResponseEntity<CartResponse> addItem(@PathVariable Long userId,
                                                @RequestHeader(value = "Authorization", required = false) String auth,
                                                @RequestBody Map<String, Object> payload) {
        assertUserMatchesToken(userId, auth);
        Long productId = ((Number) payload.get("productId")).longValue();
        Integer quantity = ((Number) payload.getOrDefault("quantity", 1)).intValue();
        return ResponseEntity.ok(cartService.addItem(userId, productId, quantity));
    }

    @PutMapping("/{userId}/update/{productId}")
    public ResponseEntity<CartResponse> updateQuantity(@PathVariable Long userId,
                                                       @PathVariable Long productId,
                                                       @RequestHeader(value = "Authorization", required = false) String auth,
                                                       @RequestBody Map<String, Object> payload) {
        assertUserMatchesToken(userId, auth);
        Integer quantity = ((Number) payload.getOrDefault("quantity", 1)).intValue();
        return ResponseEntity.ok(cartService.updateItemQuantity(userId, productId, quantity));
    }

    @DeleteMapping("/{userId}/remove/{productId}")
    public ResponseEntity<CartResponse> removeProduct(@PathVariable Long userId,
                                                      @PathVariable Long productId,
                                                      @RequestHeader(value = "Authorization", required = false) String auth) {
        assertUserMatchesToken(userId, auth);
        return ResponseEntity.ok(cartService.removeProductFromCart(userId, productId));
    }

    @DeleteMapping("/item/{itemId}")
    public ResponseEntity<CartResponse> removeItem(@PathVariable Long itemId) {
        return ResponseEntity.ok(cartService.removeItem(itemId));
    }

    @DeleteMapping("/{userId}/clear")
    public ResponseEntity<CartResponse> clearCart(@PathVariable Long userId,
                                                  @RequestHeader(value = "Authorization", required = false) String auth) {
        assertUserMatchesToken(userId, auth);
        return ResponseEntity.ok(cartService.clearCart(userId));
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
