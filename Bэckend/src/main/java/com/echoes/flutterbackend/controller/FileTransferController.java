package com.echoes.flutterbackend.controller;

import com.echoes.flutterbackend.service.RemoteFileTransferService;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/transfer")
@CrossOrigin(origins = "*")
public class FileTransferController {

    private final RemoteFileTransferService transferService;

    public FileTransferController(RemoteFileTransferService transferService) {
        this.transferService = transferService;
    }

    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping("/sftp/test")
    public ResponseEntity<?> testSftpConnection() {
        transferService.testSftpConnection();
        return ResponseEntity.ok(Map.of("message", "SFTP connection is valid"));
    }

    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping(value = "/sftp/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> uploadToSftp(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "remotePath", required = false) String remotePath
    ) {
        String storedPath = transferService.uploadToSftp(file, remotePath);
        return ResponseEntity.ok(Map.of(
                "message", "SFTP upload completed",
                "path", storedPath
        ));
    }

    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping("/ftp/test")
    public ResponseEntity<?> testFtpConnection() {
        transferService.testFtpConnection();
        return ResponseEntity.ok(Map.of("message", "FTP connection is valid"));
    }

    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping(value = "/ftp/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> uploadToFtp(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "remotePath", required = false) String remotePath
    ) {
        String storedPath = transferService.uploadToFtp(file, remotePath);
        return ResponseEntity.ok(Map.of(
                "message", "FTP upload completed",
                "path", storedPath
        ));
    }
}
