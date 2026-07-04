package com.innocence.server.modules.account.service;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.mail.MailException;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.time.Duration;
import java.util.Map;
import java.util.concurrent.TimeUnit;

@Service
public class EmailCodeService {

    private static final Duration CODE_EXPIRE = Duration.ofMinutes(10);
    private static final Duration SEND_COOLDOWN = Duration.ofSeconds(60);
    private static final String CODE_PREFIX = "innocence:auth:code:";
    private static final String COOLDOWN_PREFIX = "innocence:auth:cooldown:";

    private final StringRedisTemplate stringRedisTemplate;
    private final JavaMailSender javaMailSender;
    private final SecureRandom secureRandom = new SecureRandom();
    private final String fromAddress;

    public EmailCodeService(
            StringRedisTemplate stringRedisTemplate,
            JavaMailSender javaMailSender,
            @Value("${spring.mail.username}") String fromAddress
    ) {
        this.stringRedisTemplate = stringRedisTemplate;
        this.javaMailSender = javaMailSender;
        this.fromAddress = fromAddress;
    }

    public Map<String, Object> sendRegisterCode(String email) {
        return sendCode(email, "register", "Innocence 注册验证码");
    }

    public Map<String, Object> sendLoginCode(String email) {
        return sendCode(email, "login", "Innocence 登录验证码");
    }

    public Map<String, Object> sendResetCode(String email) {
        return sendCode(email, "reset", "Innocence 重置密码验证码");
    }

    public void validateCode(String email, String scene, String code) {
        String storedCode = stringRedisTemplate.opsForValue().get(codeKey(email, scene));
        if (storedCode == null) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "验证码已过期或不存在");
        }
        if (!storedCode.equals(code)) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "验证码错误");
        }
    }

    public void clearCode(String email, String scene) {
        stringRedisTemplate.delete(codeKey(email, scene));
    }

    private Map<String, Object> sendCode(String email, String scene, String subject) {
        String cooldownKey = cooldownKey(email, scene);
        Long remainingSeconds = stringRedisTemplate.getExpire(cooldownKey, TimeUnit.SECONDS);
        if (remainingSeconds != null && remainingSeconds > 0) {
            throw new BusinessException(ErrorCode.TOO_MANY_REQUESTS, "验证码发送过于频繁，请 " + remainingSeconds + " 秒后重试");
        }

        String code = generateCode();
        try {
            sendMail(email, subject, buildContent(code));
        } catch (MailException exception) {
            throw new BusinessException(ErrorCode.INTERNAL_ERROR, "验证码邮件发送失败，请检查邮箱配置");
        }

        stringRedisTemplate.opsForValue().set(codeKey(email, scene), code, CODE_EXPIRE);
        stringRedisTemplate.opsForValue().set(cooldownKey, "1", SEND_COOLDOWN);
        return Map.of(
                "cooldownSeconds", SEND_COOLDOWN.toSeconds(),
                "expireSeconds", CODE_EXPIRE.toSeconds()
        );
    }

    private void sendMail(String email, String subject, String content) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(fromAddress);
        message.setTo(email);
        message.setSubject(subject);
        message.setText(content);
        javaMailSender.send(message);
    }

    private String buildContent(String code) {
        return """
                你好，

                你的 Innocence 验证码是：%s

                验证码 10 分钟内有效，请勿泄露给他人。
                """.formatted(code);
    }

    private String generateCode() {
        int value = secureRandom.nextInt(900000) + 100000;
        return String.valueOf(value);
    }

    private String codeKey(String email, String scene) {
        return CODE_PREFIX + scene + ":" + email;
    }

    private String cooldownKey(String email, String scene) {
        return COOLDOWN_PREFIX + scene + ":" + email;
    }
}
