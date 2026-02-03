package com.echoes.flutterbackend.service;

import com.echoes.flutterbackend.dto.CartItemResponse;
import com.echoes.flutterbackend.dto.CartResponse;
import com.echoes.flutterbackend.dto.ProductMapper;
import com.echoes.flutterbackend.dto.ProductResponse;
import com.echoes.flutterbackend.entity.Cart;
import com.echoes.flutterbackend.entity.CartItem;
import com.echoes.flutterbackend.entity.Product;
import com.echoes.flutterbackend.entity.User;
import com.echoes.flutterbackend.repository.CartItemRepository;
import com.echoes.flutterbackend.repository.CartRepository;
import com.echoes.flutterbackend.repository.ProductRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class CartService {

    private final CartRepository cartRepository;
    private final CartItemRepository cartItemRepository;
    private final ProductRepository productRepository;

    public CartService(CartRepository cartRepository,
                       CartItemRepository cartItemRepository,
                       ProductRepository productRepository) {
        this.cartRepository = cartRepository;
        this.cartItemRepository = cartItemRepository;
        this.productRepository = productRepository;
    }

    public CartResponse getCartSnapshot(Long userId) {
        return toResponse(getOrCreateCart(userId));
    }

    public CartResponse addItem(Long userId, Long productId, Integer quantity) {
        Cart cart = getOrCreateCart(userId);

        Optional<CartItem> existingItemOpt = cartItemRepository.findByProductIdAndCartId(productId, cart.getId());
        CartItem item = existingItemOpt.orElseGet(() -> {
            CartItem newItem = new CartItem();
            newItem.setCart(cart);
            newItem.setProductId(productId);
            newItem.setQuantity(0);
            return newItem;
        });

        int baseQuantity = item.getQuantity() == null ? 0 : item.getQuantity();
        item.setQuantity(baseQuantity + quantity);
        cartItemRepository.save(item);
        return toResponse(cartRepository.findById(cart.getId()).orElse(cart));
    }

    public CartResponse updateItemQuantity(Long userId, Long productId, Integer quantity) {
        Cart cart = getOrCreateCart(userId);
        if (cart.getItems() == null) {
            throw new EntityNotFoundException("Cart is empty");
        }
        CartItem item = cart.getItems().stream()
                .filter(ci -> ci.getProductId().equals(productId))
                .findFirst()
                .orElseThrow(() -> new EntityNotFoundException("Product not found in cart: " + productId));
        item.setQuantity(quantity);
        cartItemRepository.save(item);
        return toResponse(getOrCreateCart(userId));
    }

    public CartResponse removeProductFromCart(Long userId, Long productId) {
        Cart cart = getOrCreateCart(userId);
        if (cart.getItems() != null) {
            cart.getItems().removeIf(item -> item.getProductId().equals(productId));
            cartRepository.save(cart);
        }
        return toResponse(getOrCreateCart(userId));
    }

    public CartResponse removeItem(Long itemId) {
        CartItem item = cartItemRepository.findById(itemId)
                .orElseThrow(() -> new EntityNotFoundException("Cart item not found: " + itemId));
        Long userId = item.getCart().getUser().getId();
        cartItemRepository.delete(item);
        return toResponse(getOrCreateCart(userId));
    }

    public CartResponse clearCart(Long userId) {
        Cart cart = getOrCreateCart(userId);
        if (cart.getItems() != null) {
            cart.getItems().clear();
            cartRepository.save(cart);
        }
        return toResponse(getOrCreateCart(userId));
    }

    private Cart getOrCreateCart(Long userId) {
        return cartRepository.findByUserId(userId)
                .orElseGet(() -> {
                    Cart cart = new Cart();
                    User user = new User();
                    user.setId(userId);
                    cart.setUser(user);
                    return cartRepository.save(cart);
                });
    }

    private CartResponse toResponse(Cart cart) {
        List<CartItem> items = cart.getItems();
        if (items == null || items.isEmpty()) {
            return new CartResponse(cart.getId(), cart.getUser().getId(), 0, List.of());
        }

        List<Long> productIds = items.stream()
                .map(CartItem::getProductId)
                .toList();

        Map<Long, Product> productMap = productRepository.findAllById(productIds).stream()
                .collect(Collectors.toMap(Product::getId, product -> product));

        List<CartItemResponse> responseItems = items.stream()
                .filter(item -> productMap.containsKey(item.getProductId()))
                .map(item -> {
                    ProductResponse productResponse = ProductMapper.toResponse(productMap.get(item.getProductId()));
                    return new CartItemResponse(item.getId(), item.getQuantity(), productResponse);
                })
                .toList();

        double total = responseItems.stream()
                .mapToDouble(item -> (item.product().price() != null ? item.product().price() : 0) * item.quantity())
                .sum();

        return new CartResponse(cart.getId(), cart.getUser().getId(), total, responseItems);
    }
}
