package com.echoes.flutterbackend.repository;

import com.echoes.flutterbackend.entity.CartItem;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface CartItemRepository extends JpaRepository<CartItem, Long> {
    Optional<CartItem> findByProductId(Long productId);
    Optional<CartItem> findByProductIdAndCartId(Long productId, Long cartId);
}
