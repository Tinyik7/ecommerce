package com.echoes.flutterbackend.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.Instant;

@Entity
@Data
@Table(name = "products")
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String image;
    private String name;
    private Integer quantity;
    private Double price;
    private Double rating;
    private String reviews;
    private String size;
    private Boolean isFavorite;
    private Boolean inCart = false;

    @Column(length = 1024)
    private String description;

    private String category;
    private String brand;
    private String color;
    private Boolean featured = false;
    private Double discount;
    private Boolean inStock = true;

    @Column(name = "created_at", updatable = false)
    private Instant createdAt;

    @Column(name = "updated_at")
    private Instant updatedAt;

    @PrePersist
    public void onCreate() {
        final Instant now = Instant.now();
        createdAt = now;
        updatedAt = now;
    }

    @PreUpdate
    public void onUpdate() {
        updatedAt = Instant.now();
    }
}
