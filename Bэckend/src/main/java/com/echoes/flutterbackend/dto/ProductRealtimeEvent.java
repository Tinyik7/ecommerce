package com.echoes.flutterbackend.dto;

import java.time.Instant;

public record ProductRealtimeEvent(
        String type,
        Long productId,
        String productName,
        Instant timestamp
) {
}
