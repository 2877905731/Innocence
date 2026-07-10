package com.innocence.server.modules.notification.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class CreateSystemAnnouncementRequest {

    @NotBlank(message = "Announcement title is required.")
    @Size(max = 64, message = "Announcement title must be 64 characters or fewer.")
    private String title;

    @NotBlank(message = "Announcement content is required.")
    @Size(max = 255, message = "Announcement content must be 255 characters or fewer.")
    private String content;

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }
}
