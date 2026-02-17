package com.echoes.flutterbackend.dto.graphql;

public record ProductInput(
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
        Boolean inStock
) {
}
