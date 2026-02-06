package com.echoes.flutterbackend;

import com.echoes.flutterbackend.entity.User;
import com.echoes.flutterbackend.repository.UserRepository;
import com.echoes.flutterbackend.service.UserService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.ActiveProfiles;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@ActiveProfiles("test")
class UserServiceTests {

    @Autowired
    private UserService userService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Test
    void registerShouldHashPasswordAndSetDefaultRole() {
        User user = new User();
        user.setEmail("user@test.com");
        user.setUsername("user");
        user.setPassword("secret");

        User saved = userService.register(user);

        assertNotNull(saved.getId());
        assertNotEquals("secret", saved.getPassword());
        assertTrue(passwordEncoder.matches("secret", saved.getPassword()));
        assertEquals("USER", saved.getRole());
    }

    @Test
    void changePasswordShouldValidateCurrentPassword() {
        User user = new User();
        user.setEmail("change@test.com");
        user.setUsername("change");
        user.setPassword(passwordEncoder.encode("oldpass"));
        user.setRole("USER");
        User saved = userRepository.save(user);

        boolean ok = userService.changePassword(saved, "oldpass", "newpass");
        assertTrue(ok);

        User updated = userRepository.findById(saved.getId()).orElseThrow();
        assertTrue(passwordEncoder.matches("newpass", updated.getPassword()));
    }
}
