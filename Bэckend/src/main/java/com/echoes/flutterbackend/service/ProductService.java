package com.echoes.flutterbackend.service;

import com.echoes.flutterbackend.dto.PageResponse;
import com.echoes.flutterbackend.dto.ProductFilter;
import com.echoes.flutterbackend.dto.ProductMapper;
import com.echoes.flutterbackend.dto.ProductRealtimeEvent;
import com.echoes.flutterbackend.dto.ProductRequest;
import com.echoes.flutterbackend.dto.ProductResponse;
import com.echoes.flutterbackend.entity.Product;
import com.echoes.flutterbackend.repository.FavoriteRepository;
import com.echoes.flutterbackend.repository.ProductRepository;
import com.echoes.flutterbackend.repository.UserRepository;
import com.echoes.flutterbackend.repository.spec.ProductSpecifications;
import com.echoes.flutterbackend.websocket.ProductUpdatesWebSocketHandler;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import jakarta.persistence.EntityNotFoundException;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@Transactional(readOnly = true)
public class ProductService {
    private final ProductRepository repository;
    private final FavoriteRepository favoriteRepository;
    private final UserRepository userRepository;
    private final Path uploadDirectory;
    private final ProductUpdatesWebSocketHandler productUpdatesWebSocketHandler;

    public ProductService(ProductRepository repository,
                          FavoriteRepository favoriteRepository,
                          UserRepository userRepository,
                          ProductUpdatesWebSocketHandler productUpdatesWebSocketHandler,
                          @Value("${app.upload-dir:uploads}") String uploadDir) {
        this.repository = repository;
        this.favoriteRepository = favoriteRepository;
        this.userRepository = userRepository;
        this.productUpdatesWebSocketHandler = productUpdatesWebSocketHandler;
        this.uploadDirectory = Path.of(uploadDir).toAbsolutePath();
    }

    public PageResponse<ProductResponse> search(ProductFilter filter, Pageable pageable) {
        Specification<Product> spec = ProductSpecifications.withFilter(filter);

        if (filter != null && Boolean.TRUE.equals(filter.onlyFavorites())) {
            Optional<Long> userId = resolveAuthenticatedUserId();
            if (userId.isEmpty()) {
                return PageResponse.from(Page.empty(pageable));
            }

            List<Long> favoriteProductIds = favoriteRepository.findByUserId(userId.get()).stream()
                    .map(f -> f.getProductId())
                    .distinct()
                    .toList();

            if (favoriteProductIds.isEmpty()) {
                return PageResponse.from(Page.empty(pageable));
            }

            spec = spec.and((root, cq, cb) -> root.get("id").in(favoriteProductIds));
        }

        final Page<Product> page = repository.findAll(spec, pageable);
        return PageResponse.from(page.map(ProductMapper::toResponse));
    }

    public ProductResponse getById(Long id) {
        Product product = repository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Product not found: " + id));
        return ProductMapper.toResponse(product);
    }

    @Transactional
    public ProductResponse create(ProductRequest request, MultipartFile image) throws IOException {
        Product product = new Product();
        ProductMapper.updateEntity(product, request);
        if (image != null && !image.isEmpty()) {
            product.setImage(saveImage(image));
        }
        Product saved = repository.save(product);
        publishRealtimeEvent("CREATED", saved.getId(), saved.getName());
        return ProductMapper.toResponse(saved);
    }

    @Transactional
    public ProductResponse update(Long id, ProductRequest request, MultipartFile image) throws IOException {
        Product product = repository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Product not found: " + id));

        if (image != null && !image.isEmpty()) {
            product.setImage(saveImage(image));
        }

        ProductMapper.updateEntity(product, request);
        Product updated = repository.save(product);
        publishRealtimeEvent("UPDATED", updated.getId(), updated.getName());
        return ProductMapper.toResponse(updated);
    }

    @Transactional
    public void delete(Long id) {
        if (!repository.existsById(id)) {
            throw new EntityNotFoundException("Product not found: " + id);
        }
        repository.deleteById(id);
        publishRealtimeEvent("DELETED", id, null);
    }

    private void publishRealtimeEvent(String type, Long productId, String productName) {
        productUpdatesWebSocketHandler.broadcast(
                new ProductRealtimeEvent(type, productId, productName, Instant.now())
        );
    }

    private String saveImage(MultipartFile image) throws IOException {
        Files.createDirectories(uploadDirectory);
        String cleanFilename = StringUtils.cleanPath(image.getOriginalFilename() == null ? "product" : image.getOriginalFilename());
        String filename = UUID.randomUUID() + "_" + cleanFilename;
        Path filePath = uploadDirectory.resolve(filename);
        Files.copy(image.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
        return "/uploads/" + filename;
    }

    private Optional<Long> resolveAuthenticatedUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            return Optional.empty();
        }

        Object principal = authentication.getPrincipal();
        if (!(principal instanceof String email) || email.isBlank()) {
            return Optional.empty();
        }

        return userRepository.findByEmail(email).map(u -> u.getId());
    }
}
