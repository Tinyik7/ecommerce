package com.echoes.flutterbackend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.time.Instant;

@Data
public class ProductRequest {

    private Long id;

    @NotBlank(message = "Name is required")
    private String name;

    @Size(max = 1024, message = "Description should be up to 1024 characters")
    private String description;

    private String image;

    @NotNull(message = "Price is required")
    @DecimalMin(value = "0.0", message = "Price must be positive")
    private Double price;

    @Min(value = 0, message = "Quantity must be positive")
    private Integer quantity;

    @DecimalMin(value = "0.0", message = "Rating must be positive")
    private Double rating;

    private String reviews;
    private String size;
    private String category;
    private String brand;
    private String color;

    @JsonProperty("is_favorite")
    private Boolean isFavorite;

    @JsonProperty("in_cart")
    private Boolean inCart;

    private Boolean featured;

    @JsonProperty("in_stock")
    private Boolean inStock;

    private Double discount;

    @JsonProperty("created_at")
    private Instant createdAt;

    @JsonProperty("updated_at")
    private Instant updatedAt;
}
