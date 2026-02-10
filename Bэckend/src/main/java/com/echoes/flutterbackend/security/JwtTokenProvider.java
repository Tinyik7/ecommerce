package com.echoes.flutterbackend.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;

@Component
public class JwtTokenProvider {
    private static final Logger log = LoggerFactory.getLogger(JwtTokenProvider.class);

    private final long jwtAccessExpirationMs;
    private final long jwtRefreshExpirationMs;
    private final Key key;

    public JwtTokenProvider(
            @Value("${app.jwt.secret}") String jwtSecret,
            @Value("${app.jwt.access-expiration-ms:86400000}") long jwtAccessExpirationMs,
            @Value("${app.jwt.refresh-expiration-ms:604800000}") long jwtRefreshExpirationMs
    ) {
        this.jwtAccessExpirationMs = jwtAccessExpirationMs;
        this.jwtRefreshExpirationMs = jwtRefreshExpirationMs;
        this.key = Keys.hmacShaKeyFor(jwtSecret.getBytes());
    }

    public String generateAccessToken(String email) {
        return generateAccessToken(email, null);
    }

    public String generateAccessToken(String email, String role) {
        JwtBuilder builder = Jwts.builder()
                .setSubject(email)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + jwtAccessExpirationMs));

        if (role != null && !role.isBlank()) {
            builder.claim("role", role);
        }

        return builder.signWith(key, SignatureAlgorithm.HS256).compact();
    }

    public String generateRefreshToken(String email) {
        return Jwts.builder()
                .setSubject(email)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + jwtRefreshExpirationMs))
                .signWith(key, SignatureAlgorithm.HS256)
                .compact();
    }

    public String getUsernameFromToken(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(key)
                .build()
                .parseClaimsJws(token)
                .getBody()
                .getSubject();
    }

    public String getRoleFromToken(String token) {
        Object role = Jwts.parserBuilder()
                .setSigningKey(key)
                .build()
                .parseClaimsJws(token)
                .getBody()
                .get("role");
        return role == null ? null : role.toString();
    }

    public boolean validateToken(String token) {
        try {
            Jwts.parserBuilder()
                    .setSigningKey(key)
                    .build()
                    .parseClaimsJws(token);
            return true;
        } catch (ExpiredJwtException e) {
            log.debug("JWT token expired: {}", e.getMessage());
        } catch (UnsupportedJwtException e) {
            log.debug("Unsupported JWT: {}", e.getMessage());
        } catch (MalformedJwtException e) {
            log.debug("Malformed JWT: {}", e.getMessage());
        } catch (SignatureException e) {
            log.debug("Invalid JWT signature: {}", e.getMessage());
        } catch (IllegalArgumentException e) {
            log.debug("Invalid JWT argument: {}", e.getMessage());
        }
        return false;
    }
}
