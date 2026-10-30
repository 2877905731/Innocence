package com.innocence.server.modules.account.service;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import com.innocence.server.modules.account.mapper.AdminAccountStore;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class RegistrationPolicyService {
    private final AdminAccountStore store;
    public RegistrationPolicyService(AdminAccountStore store) { this.store = store; }

    @Transactional(readOnly = true)
    public void requireEnabled() {
        if (!store.registrationEnabled(true)) {
            throw new BusinessException(ErrorCode.FORBIDDEN, "当前已暂停新用户注册，请联系管理员");
        }
    }
}
