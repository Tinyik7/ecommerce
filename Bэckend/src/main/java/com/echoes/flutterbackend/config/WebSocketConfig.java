package com.echoes.flutterbackend.config;

import com.echoes.flutterbackend.websocket.ProductUpdatesWebSocketHandler;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;

@Configuration
@EnableWebSocket
public class WebSocketConfig implements WebSocketConfigurer {

    private final ProductUpdatesWebSocketHandler productUpdatesWebSocketHandler;

    public WebSocketConfig(ProductUpdatesWebSocketHandler productUpdatesWebSocketHandler) {
        this.productUpdatesWebSocketHandler = productUpdatesWebSocketHandler;
    }

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        registry.addHandler(productUpdatesWebSocketHandler, "/ws/products")
                .setAllowedOriginPatterns("*");
    }
}
