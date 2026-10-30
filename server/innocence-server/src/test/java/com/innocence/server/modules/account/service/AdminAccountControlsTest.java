package com.innocence.server.modules.account.service;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import com.innocence.server.modules.account.domain.User;
import com.innocence.server.modules.account.dto.request.EmailRegisterRequest;
import com.innocence.server.modules.account.mapper.AdminAccountStore;
import com.innocence.server.modules.account.mapper.UserMapper;
import com.innocence.server.modules.checkin.service.CheckInService;
import com.innocence.server.modules.friend.mapper.FriendMapper;
import com.innocence.server.modules.report.service.AdminAccessService;
import org.junit.jupiter.api.Test;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class AdminAccountControlsTest {
    @Test void closedRegistrationCannotSendMailOrConsumeAPreviouslyIssuedCode() {
        AdminAccountStore store=mock(AdminAccountStore.class);
        RegistrationPolicyService policy=new RegistrationPolicyService(store);
        JavaMailSender mail=mock(JavaMailSender.class);
        StringRedisTemplate redis=mock(StringRedisTemplate.class);
        EmailCodeService codes=new EmailCodeService(redis, mail, "synthetic@example.invalid", policy);
        UserMapper users=mock(UserMapper.class);
        AccountService account=new AccountService(users, codes, mock(CheckInService.class), mock(FriendMapper.class), policy);
        assertEquals(ErrorCode.FORBIDDEN, assertThrows(BusinessException.class, () -> codes.sendRegisterCode("synthetic@example.invalid")).getCode());
        EmailRegisterRequest request=new EmailRegisterRequest();
        assertEquals(ErrorCode.FORBIDDEN, assertThrows(BusinessException.class, () -> account.registerByEmail(request)).getCode());
        verifyNoInteractions(mail, redis, users);
    }

    @Test void policyDatabaseFailureCannotOpenRegistration() {
        AdminAccountStore store=mock(AdminAccountStore.class);
        when(store.registrationEnabled(true)).thenThrow(new IllegalStateException("unavailable"));
        assertThrows(IllegalStateException.class, () -> new RegistrationPolicyService(store).requireEnabled());
    }

    @Test void unauthorizedOperatorCannotReadChangeOrDeleteAccounts() {
        AdminAccountStore store=mock(AdminAccountStore.class);
        AdminAccessService access=mock(AdminAccessService.class);
        UserMapper users=mock(UserMapper.class);
        doThrow(new BusinessException(ErrorCode.FORBIDDEN,"forbidden")).when(access).requireAdmin(2L);
        AdminAccountService service=new AdminAccountService(store,access,users,mock(AvatarStorageService.class));
        assertThrows(BusinessException.class, () -> service.getRegistration(2L));
        assertThrows(BusinessException.class, () -> service.setRegistration(2L,false));
        assertThrows(BusinessException.class, () -> service.previewDeletion(2L,3L));
        assertThrows(BusinessException.class, () -> service.deleteUser(2L,3L));
        verifyNoInteractions(store,users);
    }

    @Test void selfAndWhitelistedAdminCannotBeDeleted() {
        AdminAccountStore store=mock(AdminAccountStore.class);
        AdminAccessService access=mock(AdminAccessService.class);
        UserMapper users=mock(UserMapper.class);
        when(users.lockPlanningOwner(anyLong())).thenAnswer(call -> call.getArgument(0));
        when(users.findUserById(anyLong())).thenReturn(new User());
        when(access.isAdminAccount(3L)).thenReturn(true);
        AdminAccountService service=new AdminAccountService(store,access,users,mock(AvatarStorageService.class));
        assertEquals(ErrorCode.FORBIDDEN,assertThrows(BusinessException.class, () -> service.deleteUser(1L,1L)).getCode());
        assertEquals(ErrorCode.FORBIDDEN,assertThrows(BusinessException.class, () -> service.deleteUser(1L,3L)).getCode());
        verifyNoInteractions(store);
    }

    @Test void accountGraphFailureDoesNotDeleteAvatarOrWriteSuccessfulAudit() {
        AdminAccountStore store=mock(AdminAccountStore.class);
        UserMapper users=mock(UserMapper.class);
        AvatarStorageService avatars=mock(AvatarStorageService.class);
        when(users.lockPlanningOwner(3L)).thenReturn(3L);
        when(users.findUserById(3L)).thenReturn(new User());
        when(store.deleteUserGraph(3L)).thenThrow(new IllegalStateException("synthetic database failure"));
        AdminAccountService service=new AdminAccountService(store,mock(AdminAccessService.class),users,avatars);
        assertThrows(IllegalStateException.class, () -> service.deleteUser(1L,3L));
        verify(store,never()).audit(any(),any(),any());
        verifyNoInteractions(avatars);
    }

    @Test void managedAvatarIsRemovedOnlyAfterSuccessfulCommit() {
        AdminAccountStore store=mock(AdminAccountStore.class);
        UserMapper users=mock(UserMapper.class);
        AvatarStorageService avatars=mock(AvatarStorageService.class);
        User user=new User(); user.setAvatarUrl("/uploads/avatars/synthetic.png");
        when(users.lockPlanningOwner(3L)).thenReturn(3L);
        when(users.findUserById(3L)).thenReturn(user);
        when(store.deleteUserGraph(3L)).thenReturn(1);
        TransactionSynchronizationManager.initSynchronization();
        try {
            var result=new AdminAccountService(store,mock(AdminAccessService.class),users,avatars).deleteUser(1L,3L);
            assertTrue(result.success()); assertEquals(1,result.dissolvedTeamCount());
            verifyNoInteractions(avatars);
            verify(store).audit(1L,3L,"user_delete");
            TransactionSynchronizationManager.getSynchronizations().forEach(sync -> sync.afterCommit());
            verify(avatars).deleteIfManaged("/uploads/avatars/synthetic.png");
        } finally { TransactionSynchronizationManager.clearSynchronization(); }
    }
}
