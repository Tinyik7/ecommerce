package com.echoes.flutterbackend.dto;

import com.echoes.flutterbackend.entity.Product;

public final class ProductMapper {

    private ProductMapper() {
    }

    public static ProductResponse toResponse(Product product) {
        return new ProductResponse(
                product.getId(),
                product.getName(),
                product.getDescription(),
                product.getImage(),
                product.getQuantity(),
                product.getPrice(),
                product.getRating(),
                product.getReviews(),
                product.getSize(),
                product.getIsFavorite(),
                product.getInCart(),
                product.getCategory(),
                product.getBrand(),
                product.getColor(),
                product.getFeatured(),
                product.getDiscount(),
                product.getInStock(),
                product.getCreatedAt(),
                product.getUpdatedAt()
        );
    }

    public static void updateEntity(Product product, ProductRequest request) {
        product.setName(request.getName());
        if (request.getDescription() != null) {
            product.setDescription(request.getDescription());
        }
        if (request.getPrice() != null) {
            product.setPrice(request.getPrice());
        }
        if (request.getQuantity() != null) {
            product.setQuantity(request.getQuantity());
        }
        if (request.getRating() != null) {
            product.setRating(request.getRating());
        }
        if (request.getReviews() != null) {
            product.setReviews(request.getReviews());
        }
        if (request.getSize() != null) {
            product.setSize(request.getSize());
        }
        if (request.getCategory() != null) {
            product.setCategory(request.getCategory());
        }
        if (request.getBrand() != null) {
            product.setBrand(request.getBrand());
        }
        if (request.getColor() != null) {
            product.setColor(request.getColor());
        }
        if (request.getImage() != null && !request.getImage().isBlank()) {
            product.setImage(request.getImage());
        }
        if (request.getIsFavorite() != null) {
            product.setIsFavorite(request.getIsFavorite());
        }
        if (request.getInCart() != null) {
            product.setInCart(request.getInCart());
        }
        if (request.getFeatured() != null) {
            product.setFeatured(request.getFeatured());
        }
        if (request.getDiscount() != null) {
            product.setDiscount(request.getDiscount());
        }
        if (request.getInStock() != null) {
            product.setInStock(request.getInStock());
        }
        if (request.getCreatedAt() != null) {
            product.setCreatedAt(request.getCreatedAt());
        }
        if (request.getUpdatedAt() != null) {
            product.setUpdatedAt(request.getUpdatedAt());
        }
    }
}
