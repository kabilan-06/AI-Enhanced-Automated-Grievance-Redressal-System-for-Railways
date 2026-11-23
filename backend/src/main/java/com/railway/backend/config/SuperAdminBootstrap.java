package com.railway.backend.config;

import com.railway.backend.entity.User;
import com.railway.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class SuperAdminBootstrap implements ApplicationRunner {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Value("${app.bootstrap-super-admin.enabled:false}")
    private boolean enabled;

    @Value("${app.bootstrap-super-admin.email:kabil@gmail.com}")
    private String email;

    @Value("${app.bootstrap-super-admin.password:Kabilan006}")
    private String password;

    @Value("${app.bootstrap-super-admin.full-name:Kabil}")
    private String fullName;

    public SuperAdminBootstrap(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(ApplicationArguments args) {
        if (!enabled) {
            return;
        }

        String normalizedEmail = email == null ? "" : email.trim().toLowerCase();
        if (normalizedEmail.isBlank() || password == null || password.length() < 6) {
            return;
        }

        User admin = userRepository.findByUsername(normalizedEmail).orElseGet(User::new);
        admin.setUsername(normalizedEmail);
        admin.setPassword(passwordEncoder.encode(password));
        admin.setRole("SUPER_ADMIN");
        admin.setFullName(fullName == null || fullName.isBlank() ? "Kabil" : fullName.trim());
        admin.setStation(null);
        userRepository.save(admin);
    }
}
