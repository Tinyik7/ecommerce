package com.echoes.flutterbackend.dto;

import java.util.List;

public record CartResponse(
        Long cartId,
        Long userId,
        double total,
        List<CartItemResponse> items
) {
}
