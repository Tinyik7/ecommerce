package com.echoes.flutterbackend.dto;

public record CartItemResponse(
        Long itemId,
        Integer quantity,
        ProductResponse product
) {
}
