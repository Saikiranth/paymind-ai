package com.paymind.userservice.controller;

import com.paymind.userservice.dto.UpdateProfileRequest;
import com.paymind.userservice.dto.UserProfileResponse;
import com.paymind.userservice.service.UserProfileService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
public class UserProfileController {

    private final UserProfileService userProfileService;

    public UserProfileController(UserProfileService userProfileService) {
        this.userProfileService = userProfileService;
    }

    @GetMapping("/profile")
    public ResponseEntity<UserProfileResponse> getProfile(Authentication authentication) {
        // authentication.getName() is the email, set by JwtAuthFilter from the validated token -
        // NEVER trust a user id/email passed as a request parameter for "whose profile is this".
        String email = authentication.getName();
        return ResponseEntity.ok(userProfileService.getProfile(email));
    }

    @PutMapping("/profile")
    public ResponseEntity<UserProfileResponse> updateProfile(
            Authentication authentication,
            @Valid @RequestBody UpdateProfileRequest request) {
        String email = authentication.getName();
        return ResponseEntity.ok(userProfileService.updateProfile(email, request));
    }
}