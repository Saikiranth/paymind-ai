package com.paymind.userservice.service;

import com.paymind.userservice.dto.UpdateProfileRequest;
import com.paymind.userservice.dto.UserProfileResponse;
import com.paymind.userservice.entity.User;
import com.paymind.userservice.exception.UserNotFoundException;
import com.paymind.userservice.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserProfileService {

    private final UserRepository userRepository;

    public UserProfileService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public UserProfileResponse getProfile(String email) {
        User user = findByEmailOrThrow(email);
        return toResponse(user);
    }

    @Transactional
    public UserProfileResponse updateProfile(String email, UpdateProfileRequest request) {
        User user = findByEmailOrThrow(email);
        user.setFullName(request.getFullName());
        userRepository.save(user);
        return toResponse(user);
    }

    private User findByEmailOrThrow(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new UserNotFoundException("User not found: " + email));
    }

    private UserProfileResponse toResponse(User user) {
        return UserProfileResponse.builder()
                .id(user.getId())
                .fullName(user.getFullName())
                .email(user.getEmail())
                .isActive(user.getIsActive())
                .createdAt(user.getCreatedAt())
                .build();
    }
}