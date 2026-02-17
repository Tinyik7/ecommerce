package com.echoes.flutterbackend.dto.graphql;

import com.echoes.flutterbackend.dto.PageResponse;
import com.echoes.flutterbackend.dto.ProductResponse;

import java.util.List;

public record ProductPageResult(
        List<ProductResponse> items,
        int totalElements,
        int totalPages,
        int page,
        int size,
        boolean hasNext
) {
    public static ProductPageResult from(PageResponse<ProductResponse> page) {
        final int safeTotalElements = page.totalElements() > Integer.MAX_VALUE
                ? Integer.MAX_VALUE
                : (int) page.totalElements();
        return new ProductPageResult(
                page.items(),
                safeTotalElements,
                page.totalPages(),
                page.page(),
                page.size(),
                page.hasNext()
        );
    }
}
