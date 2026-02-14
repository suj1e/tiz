package io.github.suj1e.auth.rest;

import io.github.suj1e.auth.exception.BusinessException;
import io.github.suj1e.auth.exception.ErrorCode;
import io.github.suj1e.auth.api.dto.response.MessageResponse;
import com.nexora.storage.FileStorageService;
import com.nexora.storage.FileMetadata;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

/**
 * File upload controller for user avatars and other files.
 *
 * <p>Uses nexora-spring-boot-starter-file-storage for file handling.
 *
 * @author sujie
 */
@Slf4j
@RestController
@RequestMapping("/v1/files")
@RequiredArgsConstructor
public class FileUploadController {

    private final FileStorageService fileStorageService;

    /**
     * Upload user avatar.
     */
    @PostMapping("/avatar")
    public FileMetadata uploadAvatar(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam("file") MultipartFile file) throws IOException {
        validateImageFile(file);
        Long userId = Long.parseLong(userDetails.getUsername());

        log.info("Uploading avatar for user: {}", userId);
        return fileStorageService.upload(file, "avatars/" + userId);
    }

    /**
     * Upload user avatar (admin version - for specific user).
     */
    @PostMapping("/avatar/{userId}")
    @PreAuthorize("hasRole('ADMIN')")
    public FileMetadata uploadAvatarForUser(
            @PathVariable Long userId,
            @RequestParam("file") MultipartFile file) throws IOException {
        validateImageFile(file);
        log.info("Admin uploading avatar for user: {}", userId);
        return fileStorageService.upload(file, "avatars/" + userId);
    }

    /**
     * Upload multiple files (admin only).
     */
    @PostMapping("/batch")
    @PreAuthorize("hasRole('ADMIN')")
    public List<FileMetadata> uploadMultipleFiles(
            @RequestParam("files") List<MultipartFile> files) throws IOException {
        log.info("Batch uploading {} files", files.size());
        return files.stream()
            .map(file -> {
                try {
                    return fileStorageService.upload(file, "batch/");
                } catch (IOException e) {
                    throw new BusinessException(ErrorCode.FILE_UPLOAD_FAILED, "Failed to upload file: " + file.getOriginalFilename());
                }
            })
            .toList();
    }

    /**
     * Delete user avatar.
     */
    @DeleteMapping("/avatar")
    public MessageResponse deleteAvatar(@AuthenticationPrincipal UserDetails userDetails) {
        Long userId = Long.parseLong(userDetails.getUsername());
        log.info("Deleting avatar for user: {}", userId);
        fileStorageService.delete("avatars/" + userId);
        return MessageResponse.of("Avatar deleted successfully");
    }

    /**
     * Delete user avatar (admin version).
     */
    @DeleteMapping("/avatar/{userId}")
    @PreAuthorize("hasRole('ADMIN')")
    public MessageResponse deleteAvatarForUser(@PathVariable Long userId) {
        log.info("Admin deleting avatar for user: {}", userId);
        fileStorageService.delete("avatars/" + userId);
        return MessageResponse.of("Avatar deleted successfully");
    }

    /**
     * Get avatar URL for current user.
     */
    @GetMapping("/avatar")
    public MessageResponse getAvatarUrl(@AuthenticationPrincipal UserDetails userDetails) {
        Long userId = Long.parseLong(userDetails.getUsername());
        String publicUrl = fileStorageService.getPublicUrl("avatars/" + userId);
        if (publicUrl != null) {
            return MessageResponse.of(publicUrl);
        }
        throw new BusinessException(ErrorCode.FILE_UPLOAD_FAILED, "Avatar not found");
    }

    /**
     * Validate that the uploaded file is an image.
     */
    private void validateImageFile(MultipartFile file) {
        if (file.isEmpty()) {
            throw new BusinessException(ErrorCode.FILE_UPLOAD_FAILED, "File is empty");
        }

        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new BusinessException(ErrorCode.INVALID_FILE_TYPE, "Only image files are allowed");
        }

        // Check file extension
        String filename = file.getOriginalFilename();
        if (filename != null) {
            String extension = filename.substring(filename.lastIndexOf(".") + 1).toLowerCase();
            List<String> allowedExtensions = List.of("jpg", "jpeg", "png", "webp", "gif");
            if (!allowedExtensions.contains(extension)) {
                throw new BusinessException(ErrorCode.INVALID_FILE_TYPE,
                    "Allowed extensions: " + String.join(", ", allowedExtensions));
            }
        }
    }
}
