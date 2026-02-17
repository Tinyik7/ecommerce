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

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class GraphQlIntegrationTests {

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

    @BeforeEach
    void setup() {
        userRepository.deleteAll();

        User user = new User();
        user.setUsername("gql-user");
        user.setEmail("gql-user@test.com");
        user.setRole("USER");
        user.setPassword(passwordEncoder.encode("pass123"));
        user = userRepository.save(user);

        User admin = new User();
        admin.setUsername("gql-admin");
        admin.setEmail("gql-admin@test.com");
        admin.setRole("ADMIN");
        admin.setPassword(passwordEncoder.encode("pass123"));
        admin = userRepository.save(admin);

        userToken = jwtTokenProvider.generateAccessToken(user.getEmail(), user.getRole());
        adminToken = jwtTokenProvider.generateAccessToken(admin.getEmail(), admin.getRole());
    }

    @Test
    void productsQueryShouldWorkWithoutAuthentication() throws Exception {
        String body = """
                {"query":"query { products(page:0,size:2){ items { id name } totalElements } }"}
                """;

        mockMvc.perform(post("/graphql")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.products.totalElements").exists())
                .andExpect(jsonPath("$.data.products.items").isArray());
    }

    @Test
    void userCannotCreateProductViaGraphQlMutation() throws Exception {
        String body = """
                {"query":"mutation { createProduct(input:{name:\\"Denied\\",price:10.0,quantity:1}){ id name } }"}
                """;

        mockMvc.perform(post("/graphql")
                        .contentType(MediaType.APPLICATION_JSON)
                        .header("Authorization", "Bearer " + userToken)
                        .content(body))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.errors[0].message").exists());
    }

    @Test
    void adminCanCreateProductViaGraphQlMutation() throws Exception {
        String body = """
                {"query":"mutation { createProduct(input:{name:\\"GraphQL Allowed\\",price:10.0,quantity:1}){ id name } }"}
                """;

        mockMvc.perform(post("/graphql")
                        .contentType(MediaType.APPLICATION_JSON)
                        .header("Authorization", "Bearer " + adminToken)
                        .content(body))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.createProduct.id").exists())
                .andExpect(jsonPath("$.data.createProduct.name").value("GraphQL Allowed"));
    }
}
