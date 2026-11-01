package com.innocence.server.modules.account.service;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import com.innocence.server.common.web.GlobalExceptionHandler;
import com.innocence.server.modules.account.controller.AuthController;
import com.innocence.server.modules.account.domain.UserAuth;
import com.innocence.server.modules.account.mapper.AdminAccountStore;
import com.innocence.server.modules.account.mapper.UserMapper;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import org.mockito.ArgumentCaptor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ValueOperations;
import org.springframework.mail.MailSendException;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class EmailCodeServiceTest {
    private static final String EMAIL = "synthetic@example.invalid";
    private static final String CODE_KEY = "innocence:auth:code:login:" + EMAIL;
    private static final String COOLDOWN_KEY = "innocence:auth:cooldown:login:" + EMAIL;

    private final StringRedisTemplate redis = mock(StringRedisTemplate.class);
    private final JavaMailSender mail = mock(JavaMailSender.class);
    private final UserMapper users = mock(UserMapper.class);
    private final AdminAccountStore policyStore = mock(AdminAccountStore.class);
    private final EmailCodeService codes = new EmailCodeService(redis, mail, EMAIL,
            new RegistrationPolicyService(policyStore), users);

    @ParameterizedTest
    @ValueSource(booleans = {false, true})
    void unknownAccountCannotSendOrUseRedisRegardlessOfRegistrationSetting(boolean registrationEnabled) {
        when(policyStore.registrationEnabled(true)).thenReturn(registrationEnabled);

        BusinessException error = assertThrows(BusinessException.class, () -> codes.sendLoginCode(EMAIL));

        assertEquals(ErrorCode.NOT_FOUND, error.getCode());
        assertArrayEquals("没有该账号".getBytes(StandardCharsets.UTF_8),
                error.getMessage().getBytes(StandardCharsets.UTF_8));
        verifyNoInteractions(mail, redis, policyStore);
    }

    @ParameterizedTest
    @ValueSource(booleans = {false, true})
    void registeredAccountReceivesLoginCodeRegardlessOfRegistrationSetting(boolean registrationEnabled) {
        when(policyStore.registrationEnabled(true)).thenReturn(registrationEnabled);
        when(users.findAuthByEmail(EMAIL)).thenReturn(new UserAuth());
        @SuppressWarnings("unchecked")
        ValueOperations<String, String> values = mock(ValueOperations.class);
        when(redis.opsForValue()).thenReturn(values);

        assertEquals(Map.of("cooldownSeconds", 60L, "expireSeconds", 600L), codes.sendLoginCode(EMAIL));

        ArgumentCaptor<SimpleMailMessage> sent = ArgumentCaptor.forClass(SimpleMailMessage.class);
        verify(mail).send(sent.capture());
        assertArrayEquals(new String[]{EMAIL}, sent.getValue().getTo());
        assertEquals("Innocence 登录验证码", sent.getValue().getSubject());
        ArgumentCaptor<String> code = ArgumentCaptor.forClass(String.class);
        verify(values).set(eq(CODE_KEY), code.capture(), eq(Duration.ofMinutes(10)));
        assertTrue(code.getValue().matches("[1-9][0-9]{5}"));
        assertTrue(sent.getValue().getText().contains(code.getValue()));
        verify(values).set(COOLDOWN_KEY, "1", Duration.ofSeconds(60));
        verifyNoInteractions(policyStore);
    }

    @Test
    void registeredAccountStillHonorsSendCooldown() {
        when(users.findAuthByEmail(EMAIL)).thenReturn(new UserAuth());
        when(redis.getExpire(COOLDOWN_KEY, TimeUnit.SECONDS)).thenReturn(45L);

        assertEquals(ErrorCode.TOO_MANY_REQUESTS,
                assertThrows(BusinessException.class, () -> codes.sendLoginCode(EMAIL)).getCode());
        verifyNoInteractions(mail);
        verify(redis, never()).opsForValue();
    }

    @Test
    void accountLookupFailureCannotSendMailOrWriteCode() {
        when(users.findAuthByEmail(EMAIL)).thenThrow(new IllegalStateException("synthetic database failure"));

        assertThrows(IllegalStateException.class, () -> codes.sendLoginCode(EMAIL));
        verifyNoInteractions(mail, redis);
    }

    @Test
    void failedMailDoesNotStoreCodeOrCooldown() {
        when(users.findAuthByEmail(EMAIL)).thenReturn(new UserAuth());
        doThrow(new MailSendException("synthetic failure")).when(mail).send(any(SimpleMailMessage.class));

        assertEquals(ErrorCode.INTERNAL_ERROR,
                assertThrows(BusinessException.class, () -> codes.sendLoginCode(EMAIL)).getCode());
        verify(redis, never()).opsForValue();
    }

    @Test
    void httpUnknownAccountReturnsExactPromptBeforeMailOrRedis() throws Exception {
        mvc().perform(post("/api/app/v1/auth/email/send-login-code")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"" + EMAIL + "\"}"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code").value(ErrorCode.NOT_FOUND))
                .andExpect(jsonPath("$.message").value("没有该账号"))
                .andExpect(jsonPath("$.data").isEmpty());
        verifyNoInteractions(mail, redis);
    }

    @ParameterizedTest
    @ValueSource(strings = {"{}", "{\"email\":\"\"}", "{\"email\":\"invalid\"}"})
    void httpMissingOrInvalidEmailCannotLookUpOrSend(String body) throws Exception {
        mvc().perform(post("/api/app/v1/auth/email/send-login-code")
                        .contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value(ErrorCode.VALIDATION_ERROR));
        verifyNoInteractions(users, mail, redis);
    }

    private MockMvc mvc() {
        return MockMvcBuilders.standaloneSetup(new AuthController(mock(AccountService.class), codes,
                        mock(SessionAuthService.class)))
                .setControllerAdvice(new GlobalExceptionHandler()).build();
    }
}
