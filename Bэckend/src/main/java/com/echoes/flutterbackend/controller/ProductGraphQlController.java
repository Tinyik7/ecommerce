package com.echoes.flutterbackend.controller;

import com.echoes.flutterbackend.dto.ProductFilter;
import com.echoes.flutterbackend.dto.ProductRequest;
import com.echoes.flutterbackend.dto.ProductResponse;
import com.echoes.flutterbackend.dto.graphql.ProductInput;
import com.echoes.flutterbackend.dto.graphql.ProductPageResult;
import com.echoes.flutterbackend.service.ProductService;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.MutationMapping;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;

import java.io.IOException;
import java.util.Set;

@Controller
public class ProductGraphQlController {
    private static final Set<String> ALLOWED_SORT_FIELDS = Set.of("name", "price", "rating", "createdAt");

    private final ProductService productService;

    public ProductGraphQlController(ProductService productService) {
        this.productService = productService;
    }

    @QueryMapping
    public ProductResponse productById(@Argument String id) {
        return productService.getById(Long.parseLong(id));
    }

    @QueryMapping
    public ProductPageResult products(
            @Argument String query,
            @Argument String category,
            @Argument Double minPrice,
            @Argument Double maxPrice,
            @Argument Double minRating,
            @Argument Boolean inStock,
            @Argument Boolean onlyFavorites,
            @Argument Integer page,
            @Argument Integer size,
            @Argument String sortBy,
            @Argument String sortDir
    ) {
        final int safePage = page == null ? 0 : Math.max(page, 0);
        final int safeSize = size == null ? 20 : Math.min(Math.max(size, 1), 100);
        final String safeSortBy = sortBy == null ? "createdAt" : sortBy;
        final String safeSortDir = sortDir == null ? "desc" : sortDir;

        final ProductFilter filter = new ProductFilter(
                query,
                category,
                minPrice,
                maxPrice,
                minRating,
                onlyFavorites,
                inStock
        );
        final Pageable pageable = PageRequest.of(
                safePage,
                safeSize,
                Sort.by(resolveDirection(safeSortDir), resolveSortField(safeSortBy))
        );
        return ProductPageResult.from(productService.search(filter, pageable));
    }

    @MutationMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ProductResponse createProduct(@Argument ProductInput input) throws IOException {
        return productService.create(toRequest(input), null);
    }

    @MutationMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ProductResponse updateProduct(@Argument String id, @Argument ProductInput input) throws IOException {
        return productService.update(Long.parseLong(id), toRequest(input), null);
    }

    @MutationMapping
    @PreAuthorize("hasRole('ADMIN')")
    public Boolean deleteProduct(@Argument String id) {
        productService.delete(Long.parseLong(id));
        return true;
    }

    private ProductRequest toRequest(ProductInput input) {
        ProductRequest request = new ProductRequest();
        request.setName(input.name());
        request.setDescription(input.description());
        request.setImage(input.image());
        request.setQuantity(input.quantity());
        request.setPrice(input.price());
        request.setRating(input.rating());
        request.setReviews(input.reviews());
        request.setSize(input.size());
        request.setIsFavorite(input.isFavorite());
        request.setInCart(input.inCart());
        request.setCategory(input.category());
        request.setBrand(input.brand());
        request.setColor(input.color());
        request.setFeatured(input.featured());
        request.setDiscount(input.discount());
        request.setInStock(input.inStock());
        return request;
    }

    private Sort.Direction resolveDirection(String sortDir) {
        return "asc".equalsIgnoreCase(sortDir) ? Sort.Direction.ASC : Sort.Direction.DESC;
    }

    private String resolveSortField(String sortBy) {
        return ALLOWED_SORT_FIELDS.contains(sortBy) ? sortBy : "createdAt";
    }
}
