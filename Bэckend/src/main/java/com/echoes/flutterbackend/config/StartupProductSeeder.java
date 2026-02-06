package com.echoes.flutterbackend.config;

import com.echoes.flutterbackend.entity.Product;
import com.echoes.flutterbackend.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class StartupProductSeeder implements CommandLineRunner {

    private final ProductRepository productRepository;
    private final boolean seedEnabled;

    public StartupProductSeeder(ProductRepository productRepository,
                                @Value("${app.products.seed.enabled:false}") boolean seedEnabled) {
        this.productRepository = productRepository;
        this.seedEnabled = seedEnabled;
    }

    @Override
    public void run(String... args) {
        if (!seedEnabled) {
            return;
        }

        if (productRepository.count() > 0) {
            return;
        }

        List<Product> products = List.of(
                createProduct("Basic T-Shirt", "Clothing", 12.99, 50, 4.3, true),
                createProduct("Running Sneakers", "Shoes", 59.99, 20, 4.6, true),
                createProduct("Classic Hoodie", "Clothing", 39.50, 35, 4.4, true),
                createProduct("Leather Wallet", "Accessories", 24.90, 40, 4.1, true),
                createProduct("Smart Watch", "Electronics", 149.00, 10, 4.7, true),
                createProduct("Travel Backpack", "Bags", 54.00, 18, 4.5, true)
        );

        productRepository.saveAll(products);
    }

    private Product createProduct(String name, String category, double price, int quantity, double rating, boolean inStock) {
        Product p = new Product();
        p.setName(name);
        p.setCategory(category);
        p.setPrice(price);
        p.setQuantity(quantity);
        p.setRating(rating);
        p.setInStock(inStock);
        p.setFeatured(false);
        p.setDescription(name + " - demo item");
        return p;
    }
}
