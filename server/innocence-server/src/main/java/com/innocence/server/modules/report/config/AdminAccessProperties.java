package com.innocence.server.modules.report.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

import java.util.ArrayList;
import java.util.List;

@ConfigurationProperties(prefix = "innocence.admin")
public class AdminAccessProperties {

    private List<String> emails = new ArrayList<>();

    public List<String> getEmails() {
        return emails;
    }

    public void setEmails(List<String> emails) {
        this.emails = emails;
    }
}
