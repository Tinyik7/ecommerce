package com.echoes.flutterbackend;

import com.echoes.flutterbackend.dto.PageResponse;
import com.echoes.flutterbackend.dto.ProductFilter;
import com.echoes.flutterbackend.dto.ProductRequest;
import com.echoes.flutterbackend.dto.ProductResponse;
import com.echoes.flutterbackend.service.ProductService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.domain.PageRequest;
import org.springframework.test.context.ActiveProfiles;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@ActiveProfiles("test")
class ProductServiceTests {

    @Autowired
    private ProductService productService;

    @Test
    void createAndSearchProduct() throws Exception {
        ProductRequest req = new ProductRequest();
        req.setName("Test Product");
        req.setPrice(10.0);
        req.setQuantity(5);
        req.setCategory("Test");
        req.setInStock(true);

        ProductResponse created = productService.create(req, null);
        assertNotNull(created.id());

        ProductFilter filter = new ProductFilter("test", "Test", null, null, null, null, true);
        PageResponse<ProductResponse> page = productService.search(filter, PageRequest.of(0, 10));
        assertTrue(page.items().stream().anyMatch(p -> "Test Product".equals(p.name())));
    }
}
