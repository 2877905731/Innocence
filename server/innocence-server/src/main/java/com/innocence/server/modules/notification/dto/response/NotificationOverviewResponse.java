package com.innocence.server.modules.notification.dto.response;

import java.util.ArrayList;
import java.util.List;

public class NotificationOverviewResponse {

    private int unreadCount;
    private List<NotificationItemResponse> items = new ArrayList<>();

    public int getUnreadCount() {
        return unreadCount;
    }

    public void setUnreadCount(int unreadCount) {
        this.unreadCount = unreadCount;
    }

    public List<NotificationItemResponse> getItems() {
        return items;
    }

    public void setItems(List<NotificationItemResponse> items) {
        this.items = items == null ? new ArrayList<>() : items;
    }
}
