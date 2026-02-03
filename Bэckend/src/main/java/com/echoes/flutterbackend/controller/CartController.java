package com.echoes.flutterbackend.controller;

import com.echoes.flutterbackend.dto.CartResponse;
import com.echoes.flutterbackend.service.CartService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/cart")
@CrossOrigin(origins = "*")
public class CartController {

    private final CartService cartService;

    public CartController(CartService cartService) {
        this.cartService = cartService;
    }

    @GetMapping("/{userId}")
    public ResponseEntity<CartResponse> getCart(@PathVariable Long userId) {
        return ResponseEntity.ok(cartService.getCartSnapshot(userId));
    }

    @PostMapping("/{userId}/add")
    public ResponseEntity<CartResponse> addItem(@PathVariable Long userId, @RequestBody Map<String, Object> payload) {
        Long productId = ((Number) payload.get("productId")).longValue();
        Integer quantity = ((Number) payload.getOrDefault("quantity", 1)).intValue();
        return ResponseEntity.ok(cartService.addItem(userId, productId, quantity));
    }

    @PutMapping("/{userId}/update/{productId}")
    public ResponseEntity<CartResponse> updateQuantity(@PathVariable Long userId,
                                                       @PathVariable Long productId,
                                                       @RequestBody Map<String, Object> payload) {
        Integer quantity = ((Number) payload.getOrDefault("quantity", 1)).intValue();
        return ResponseEntity.ok(cartService.updateItemQuantity(userId, productId, quantity));
    }

    @DeleteMapping("/{userId}/remove/{productId}")
    public ResponseEntity<CartResponse> removeProduct(@PathVariable Long userId, @PathVariable Long productId) {
        return ResponseEntity.ok(cartService.removeProductFromCart(userId, productId));
    }

    @DeleteMapping("/item/{itemId}")
    public ResponseEntity<CartResponse> removeItem(@PathVariable Long itemId) {
        return ResponseEntity.ok(cartService.removeItem(itemId));
    }

    @DeleteMapping("/{userId}/clear")
    public ResponseEntity<CartResponse> clearCart(@PathVariable Long userId) {
        return ResponseEntity.ok(cartService.clearCart(userId));
    }
}
