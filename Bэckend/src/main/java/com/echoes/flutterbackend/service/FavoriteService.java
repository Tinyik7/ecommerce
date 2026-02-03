package com.echoes.flutterbackend.service;

import com.echoes.flutterbackend.dto.ProductMapper;
import com.echoes.flutterbackend.dto.ProductResponse;
import com.echoes.flutterbackend.entity.Favorite;
import com.echoes.flutterbackend.repository.FavoriteRepository;
import com.echoes.flutterbackend.repository.ProductRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class FavoriteService {
    private final FavoriteRepository favoriteRepository;
    private final ProductRepository productRepository;

    public FavoriteService(FavoriteRepository favoriteRepository,
                           ProductRepository productRepository) {
        this.favoriteRepository = favoriteRepository;
        this.productRepository = productRepository;
    }

    public List<ProductResponse> getFavoriteProducts(Long userId) {
        List<Long> productIds = favoriteRepository.findByUserId(userId).stream()
                .map(Favorite::getProductId)
                .toList();
        return productRepository.findAllById(productIds).stream()
                .map(ProductMapper::toResponse)
                .toList();
    }

    public Optional<Favorite> addFavorite(Long userId, Long productId) {
        Optional<Favorite> existing = favoriteRepository.findByUserIdAndProductId(userId, productId);
        if (existing.isPresent()) {
            return existing;
        }

        Favorite favorite = new Favorite();
        favorite.setUserId(userId);
        favorite.setProductId(productId);
        return Optional.of(favoriteRepository.save(favorite));
    }

    public boolean removeFavorite(Long userId, Long productId) {
        Optional<Favorite> existing = favoriteRepository.findByUserIdAndProductId(userId, productId);
        if (existing.isPresent()) {
            favoriteRepository.delete(existing.get());
            return true;
        }
        return false;
    }
}
