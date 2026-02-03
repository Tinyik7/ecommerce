package com.echoes.flutterbackend.repository.spec;

import com.echoes.flutterbackend.dto.ProductFilter;
import com.echoes.flutterbackend.entity.Product;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.util.StringUtils;

public final class ProductSpecifications {

    private ProductSpecifications() {
    }

    public static Specification<Product> withFilter(ProductFilter filter) {
        Specification<Product> spec = Specification.where(null);

        if (filter == null) {
            return spec;
        }

        if (StringUtils.hasText(filter.query())) {
            spec = spec.and(nameOrDescriptionContains(filter.query()));
        }

        if (StringUtils.hasText(filter.category())) {
            spec = spec.and(categoryEquals(filter.category()));
        }

        if (filter.minPrice() != null) {
            spec = spec.and(priceGreaterThanOrEqual(filter.minPrice()));
        }

        if (filter.maxPrice() != null) {
            spec = spec.and(priceLessThanOrEqual(filter.maxPrice()));
        }

        if (filter.minRating() != null) {
            spec = spec.and(ratingGreaterThanOrEqual(filter.minRating()));
        }

        if (Boolean.TRUE.equals(filter.onlyFavorites())) {
            spec = spec.and(onlyFavorites());
        }

        if (Boolean.TRUE.equals(filter.inStock())) {
            spec = spec.and(inStock());
        }

        return spec;
    }

    private static Specification<Product> nameOrDescriptionContains(String query) {
        return (root, cq, cb) -> cb.or(
                cb.like(cb.lower(root.get("name")), "%" + query.toLowerCase() + "%"),
                cb.like(cb.lower(root.get("description")), "%" + query.toLowerCase() + "%")
        );
    }

    private static Specification<Product> categoryEquals(String category) {
        return (root, cq, cb) -> cb.equal(cb.lower(root.get("category")), category.toLowerCase());
    }

    private static Specification<Product> priceGreaterThanOrEqual(Double minPrice) {
        return (root, cq, cb) -> cb.greaterThanOrEqualTo(root.get("price"), minPrice);
    }

    private static Specification<Product> priceLessThanOrEqual(Double maxPrice) {
        return (root, cq, cb) -> cb.lessThanOrEqualTo(root.get("price"), maxPrice);
    }

    private static Specification<Product> ratingGreaterThanOrEqual(Double minRating) {
        return (root, cq, cb) -> cb.greaterThanOrEqualTo(root.get("rating"), minRating);
    }

    private static Specification<Product> onlyFavorites() {
        return (root, cq, cb) -> cb.isTrue(root.get("isFavorite"));
    }

    private static Specification<Product> inStock() {
        return (root, cq, cb) -> cb.isTrue(root.get("inStock"));
    }
}
