package com.echoes.flutterbackend.dto;

public record ProductFilter(
        String query,
        String category,
        Double minPrice,
        Double maxPrice,
        Double minRating,
        Boolean onlyFavorites,
        Boolean inStock
) {
}
