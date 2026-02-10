package com.echoes.flutterbackend.service;

import com.echoes.flutterbackend.dto.PageResponse;
import com.echoes.flutterbackend.dto.ProductFilter;
import com.echoes.flutterbackend.dto.ProductMapper;
import com.echoes.flutterbackend.dto.ProductRequest;
import com.echoes.flutterbackend.dto.ProductResponse;
import com.echoes.flutterbackend.entity.Product;
import com.echoes.flutterbackend.repository.ProductRepository;
import com.echoes.flutterbackend.repository.spec.ProductSpecifications;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import jakarta.persistence.EntityNotFoundException;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

@Service
@Transactional(readOnly = true)
public class ProductService {
    private final ProductRepository repository;
    private final Path uploadDirectory;

    public ProductService(ProductRepository repository,
                          @Value("${app.upload-dir:uploads}") String uploadDir) {
        this.repository = repository;
        this.uploadDirectory = Path.of(uploadDir).toAbsolutePath();
    }

    public PageResponse<ProductResponse> search(ProductFilter filter, Pageable pageable) {
        final Page<Product> page = repository.findAll(
                ProductSpecifications.withFilter(filter),
                pageable
        );
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
        return ProductMapper.toResponse(updated);
    }

    @Transactional
    public void delete(Long id) {
        if (!repository.existsById(id)) {
            throw new EntityNotFoundException("Product not found: " + id);
        }
        repository.deleteById(id);
    }

    private String saveImage(MultipartFile image) throws IOException {
        Files.createDirectories(uploadDirectory);
        String cleanFilename = StringUtils.cleanPath(image.getOriginalFilename() == null ? "product" : image.getOriginalFilename());
        String filename = UUID.randomUUID() + "_" + cleanFilename;
        Path filePath = uploadDirectory.resolve(filename);
        Files.copy(image.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
        return "/uploads/" + filename;
    }
}
