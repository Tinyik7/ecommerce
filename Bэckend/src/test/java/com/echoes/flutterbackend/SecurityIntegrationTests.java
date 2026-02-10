package com.echoes.flutterbackend;

import com.echoes.flutterbackend.entity.User;
import com.echoes.flutterbackend.repository.UserRepository;
import com.echoes.flutterbackend.security.JwtTokenProvider;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class SecurityIntegrationTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    private String userToken;
    private String adminToken;
    private Long userId;
    private Long adminId;

    @BeforeEach
    void setup() {
        userRepository.deleteAll();

        User user = new User();
        user.setUsername("user1");
        user.setEmail("user1@test.com");
        user.setName("User One");
        user.setRole("USER");
        user.setPassword(passwordEncoder.encode("pass123"));
        user = userRepository.save(user);

        User admin = new User();
        admin.setUsername("admin1");
        admin.setEmail("admin1@test.com");
        admin.setName("Admin One");
        admin.setRole("ADMIN");
        admin.setPassword(passwordEncoder.encode("pass123"));
        admin = userRepository.save(admin);

        userId = user.getId();
        adminId = admin.getId();
        userToken = jwtTokenProvider.generateAccessToken(user.getEmail(), user.getRole());
        adminToken = jwtTokenProvider.generateAccessToken(admin.getEmail(), admin.getRole());
    }

    @Test
    void userCannotCreateProduct() throws Exception {
        mockMvc.perform(post("/api/v1/products")
                        .contentType(MediaType.APPLICATION_JSON)
                        .header("Authorization", "Bearer " + userToken)
                        .content("{\"name\":\"Blocked\",\"price\":10.0,\"quantity\":1}"))
                .andExpect(status().isForbidden());
    }

    @Test
    void adminCanCreateProduct() throws Exception {
        mockMvc.perform(post("/api/v1/products")
                        .contentType(MediaType.APPLICATION_JSON)
                        .header("Authorization", "Bearer " + adminToken)
                        .content("{\"name\":\"Allowed\",\"price\":10.0,\"quantity\":1}"))
                .andExpect(status().isOk());
    }

    @Test
    void userCannotUpdateRole() throws Exception {
        mockMvc.perform(put("/api/v1/users/" + userId + "/role")
                        .contentType(MediaType.APPLICATION_JSON)
                        .header("Authorization", "Bearer " + userToken)
                        .content("{\"role\":\"ADMIN\"}"))
                .andExpect(status().isForbidden());
    }

    @Test
    void userCannotAccessOtherUserCart() throws Exception {
        mockMvc.perform(get("/api/v1/cart/" + adminId)
                        .header("Authorization", "Bearer " + userToken))
                .andExpect(status().isForbidden());
    }

    @Test
    void userCannotAccessOtherUserFavorites() throws Exception {
        mockMvc.perform(get("/api/v1/favorites/" + adminId)
                        .header("Authorization", "Bearer " + userToken))
                .andExpect(status().isForbidden());
    }
}
