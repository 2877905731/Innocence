package com.innocence.server.modules.account.dto.request;

import jakarta.validation.constraints.Size;

public class CancelAccountRequest {

    @Size(max = 64, message = "密码长度不能超过 64")
    private String password;

    @Size(max = 16, message = "验证码长度不能超过 16")
    private String emailCode;

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getEmailCode() {
        return emailCode;
    }

    public void setEmailCode(String emailCode) {
        this.emailCode = emailCode;
    }
}
