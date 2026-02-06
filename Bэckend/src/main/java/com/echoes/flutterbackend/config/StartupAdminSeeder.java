package com.echoes.flutterbackend.config;

import com.echoes.flutterbackend.entity.User;
import com.echoes.flutterbackend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class StartupAdminSeeder implements CommandLineRunner {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final boolean seedEnabled;
    private final String adminEmail;
    private final String adminPassword;
    private final String adminUsername;

    public StartupAdminSeeder(UserRepository userRepository,
                              PasswordEncoder passwordEncoder,
                              @Value("${app.admin.seed.enabled:false}") boolean seedEnabled,
                              @Value("${app.admin.email:admin@example.com}") String adminEmail,
                              @Value("${app.admin.password:Admin123!}") String adminPassword,
                              @Value("${app.admin.username:admin}") String adminUsername) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.seedEnabled = seedEnabled;
        this.adminEmail = adminEmail;
        this.adminPassword = adminPassword;
        this.adminUsername = adminUsername;
    }

    @Override
    public void run(String... args) {
        if (!seedEnabled) {
            return;
        }

        userRepository.findByEmail(adminEmail).ifPresentOrElse(
                existing -> {
                    if (existing.getRole() == null || !"ADMIN".equalsIgnoreCase(existing.getRole())) {
                        existing.setRole("ADMIN");
                        userRepository.save(existing);
                    }
                },
                () -> {
                    User admin = new User();
                    admin.setEmail(adminEmail);
                    admin.setUsername(adminUsername);
                    admin.setName(adminUsername);
                    admin.setRole("ADMIN");
                    admin.setPassword(passwordEncoder.encode(adminPassword));
                    userRepository.save(admin);
                }
        );
    }
}
