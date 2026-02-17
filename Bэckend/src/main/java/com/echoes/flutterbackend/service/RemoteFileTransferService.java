package com.echoes.flutterbackend.service;

import com.jcraft.jsch.ChannelSftp;
import com.jcraft.jsch.JSch;
import com.jcraft.jsch.SftpException;
import com.jcraft.jsch.Session;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.net.ftp.FTP;
import org.apache.commons.net.ftp.FTPClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Properties;

@Service
public class RemoteFileTransferService {
    private static final Logger log = LoggerFactory.getLogger(RemoteFileTransferService.class);

    @Value("${app.sftp.enabled:false}")
    private boolean sftpEnabled;
    @Value("${app.sftp.host:}")
    private String sftpHost;
    @Value("${app.sftp.port:22}")
    private int sftpPort;
    @Value("${app.sftp.username:}")
    private String sftpUsername;
    @Value("${app.sftp.password:}")
    private String sftpPassword;
    @Value("${app.sftp.remote-dir:/upload}")
    private String sftpRemoteDir;

    @Value("${app.ftp.enabled:false}")
    private boolean ftpEnabled;
    @Value("${app.ftp.host:}")
    private String ftpHost;
    @Value("${app.ftp.port:21}")
    private int ftpPort;
    @Value("${app.ftp.username:}")
    private String ftpUsername;
    @Value("${app.ftp.password:}")
    private String ftpPassword;
    @Value("${app.ftp.remote-dir:/upload}")
    private String ftpRemoteDir;
    @Value("${app.ftp.passive:true}")
    private boolean ftpPassive;

    public void testSftpConnection() {
        ensureSftpConfigured();
        Session session = null;
        try {
            session = openSftpSession();
            log.info("SFTP connection test succeeded to {}:{}", sftpHost, sftpPort);
        } catch (Exception ex) {
            log.error("SFTP connection test failed", ex);
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "SFTP connection failed");
        } finally {
            if (session != null && session.isConnected()) {
                session.disconnect();
            }
        }
    }

    public String uploadToSftp(MultipartFile file, String remotePath) {
        ensureSftpConfigured();
        validateFile(file);

        final String remoteFilePath = resolveRemotePath(sftpRemoteDir, remotePath, file.getOriginalFilename());
        Session session = null;
        ChannelSftp channel = null;
        try {
            session = openSftpSession();
            channel = (ChannelSftp) session.openChannel("sftp");
            channel.connect(10000);
            ensureSftpDirectoryExists(channel, remoteFilePath);
            try (InputStream inputStream = file.getInputStream()) {
                channel.put(inputStream, remoteFilePath);
            }
            log.info("Uploaded file '{}' to SFTP path '{}'", file.getOriginalFilename(), remoteFilePath);
            return remoteFilePath;
        } catch (Exception ex) {
            log.error("SFTP upload failed for '{}'", file.getOriginalFilename(), ex);
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "SFTP upload failed");
        } finally {
            if (channel != null && channel.isConnected()) {
                channel.disconnect();
            }
            if (session != null && session.isConnected()) {
                session.disconnect();
            }
        }
    }

    public void testFtpConnection() {
        ensureFtpConfigured();
        FTPClient ftp = new FTPClient();
        try {
            ftp.connect(ftpHost, ftpPort);
            if (!ftp.login(ftpUsername, ftpPassword)) {
                throw new IOException("FTP login failed");
            }
            log.info("FTP connection test succeeded to {}:{}", ftpHost, ftpPort);
        } catch (Exception ex) {
            log.error("FTP connection test failed", ex);
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "FTP connection failed");
        } finally {
            disconnectFtpQuietly(ftp);
        }
    }

    public String uploadToFtp(MultipartFile file, String remotePath) {
        ensureFtpConfigured();
        validateFile(file);

        final String remoteFilePath = resolveRemotePath(ftpRemoteDir, remotePath, file.getOriginalFilename());
        FTPClient ftp = new FTPClient();
        try {
            ftp.connect(ftpHost, ftpPort);
            if (!ftp.login(ftpUsername, ftpPassword)) {
                throw new IOException("FTP login failed");
            }
            if (ftpPassive) {
                ftp.enterLocalPassiveMode();
            }
            ftp.setFileType(FTP.BINARY_FILE_TYPE);
            ensureFtpDirectoryExists(ftp, remoteFilePath);
            try (InputStream inputStream = file.getInputStream()) {
                if (!ftp.storeFile(remoteFilePath, inputStream)) {
                    throw new IOException("FTP storeFile failed");
                }
            }
            log.info("Uploaded file '{}' to FTP path '{}'", file.getOriginalFilename(), remoteFilePath);
            return remoteFilePath;
        } catch (Exception ex) {
            log.error("FTP upload failed for '{}'", file.getOriginalFilename(), ex);
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "FTP upload failed");
        } finally {
            disconnectFtpQuietly(ftp);
        }
    }

    private Session openSftpSession() throws Exception {
        final JSch jSch = new JSch();
        final Session session = jSch.getSession(sftpUsername, sftpHost, sftpPort);
        session.setPassword(sftpPassword);
        Properties config = new Properties();
        config.put("StrictHostKeyChecking", "no");
        session.setConfig(config);
        session.connect(10000);
        return session;
    }

    private void validateFile(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "File is required");
        }
    }

    private void ensureSftpConfigured() {
        if (!sftpEnabled) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "SFTP is disabled");
        }
        if (StringUtils.isAnyBlank(sftpHost, sftpUsername, sftpPassword)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "SFTP credentials are not configured");
        }
    }

    private void ensureFtpConfigured() {
        if (!ftpEnabled) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "FTP is disabled");
        }
        if (StringUtils.isAnyBlank(ftpHost, ftpUsername, ftpPassword)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "FTP credentials are not configured");
        }
    }

    private String resolveRemotePath(String defaultDir, String remotePath, String originalFilename) {
        if (StringUtils.isNotBlank(remotePath)) {
            return remotePath.trim();
        }
        final String name = StringUtils.defaultIfBlank(originalFilename, "upload.bin");
        final String fileNameOnly = Paths.get(name).getFileName().toString();
        final String base = StringUtils.defaultIfBlank(defaultDir, "/upload");
        return base.endsWith("/") ? base + fileNameOnly : base + "/" + fileNameOnly;
    }

    private void ensureSftpDirectoryExists(ChannelSftp channel, String remoteFilePath) throws SftpException {
        Path parentPath = Paths.get(remoteFilePath).getParent();
        if (parentPath == null) {
            return;
        }
        String normalized = parentPath.toString().replace('\\', '/');
        if (normalized.isBlank()) {
            return;
        }
        String[] parts = normalized.split("/");
        StringBuilder current = new StringBuilder();
        if (normalized.startsWith("/")) {
            current.append("/");
        }
        for (String part : parts) {
            if (part.isBlank()) {
                continue;
            }
            if (current.length() > 1 && !current.toString().endsWith("/")) {
                current.append("/");
            }
            current.append(part);
            String dir = current.toString();
            try {
                channel.stat(dir);
            } catch (SftpException ex) {
                channel.mkdir(dir);
            }
        }
    }

    private void ensureFtpDirectoryExists(FTPClient ftp, String remoteFilePath) throws IOException {
        Path parentPath = Paths.get(remoteFilePath).getParent();
        if (parentPath == null) {
            return;
        }
        String normalized = parentPath.toString().replace('\\', '/');
        if (normalized.isBlank()) {
            return;
        }
        String[] parts = normalized.split("/");
        StringBuilder current = new StringBuilder();
        if (normalized.startsWith("/")) {
            current.append("/");
        }
        for (String part : parts) {
            if (part.isBlank()) {
                continue;
            }
            if (current.length() > 1 && !current.toString().endsWith("/")) {
                current.append("/");
            }
            current.append(part);
            String dir = current.toString();
            if (!ftp.changeWorkingDirectory(dir)) {
                if (!ftp.makeDirectory(dir)) {
                    throw new IOException("Cannot create remote directory: " + dir);
                }
            }
        }
    }

    private void disconnectFtpQuietly(FTPClient ftp) {
        try {
            if (ftp.isConnected()) {
                ftp.logout();
                ftp.disconnect();
            }
        } catch (Exception ignored) {
            // No-op
        }
    }
}
