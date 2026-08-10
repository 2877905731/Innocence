package com.innocence.server.modules.account.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.nio.file.Path;

@Component
@ConfigurationProperties(prefix = "innocence.avatar")
public class AvatarStorageProperties {

    private String storageDir = "./data/uploads/avatars";
    private String publicPath = "/uploads/avatars";
    private long maxBytes = 5 * 1024 * 1024;

    public String getStorageDir() {
        return storageDir;
    }

    public void setStorageDir(String storageDir) {
        this.storageDir = storageDir;
    }

    public String getPublicPath() {
        return publicPath;
    }

    public void setPublicPath(String publicPath) {
        this.publicPath = publicPath;
    }

    public long getMaxBytes() {
        return maxBytes;
    }

    public void setMaxBytes(long maxBytes) {
        this.maxBytes = maxBytes;
    }

    public Path storageLocation() {
        return Path.of(storageDir).toAbsolutePath().normalize();
    }
}
