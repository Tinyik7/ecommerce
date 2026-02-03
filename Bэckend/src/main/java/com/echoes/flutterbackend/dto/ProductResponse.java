package com.echoes.flutterbackend.dto;

import java.time.Instant;

public record ProductResponse(
        Long id,
        String name,
        String description,
        String image,
        Integer quantity,
        Double price,
        Double rating,
        String reviews,
        String size,
        Boolean isFavorite,
        Boolean inCart,
        String category,
        String brand,
        String color,
        Boolean featured,
        Double discount,
        Boolean inStock,
        Instant createdAt,
        Instant updatedAt
) {
}
