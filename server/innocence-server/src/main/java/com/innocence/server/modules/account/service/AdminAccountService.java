package com.innocence.server.modules.account.service;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import com.innocence.server.modules.account.domain.User;
import com.innocence.server.modules.account.mapper.AdminAccountStore;
import com.innocence.server.modules.account.mapper.UserMapper;
import com.innocence.server.modules.report.service.AdminAccessService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

@Service
public class AdminAccountService {
    public record RegistrationPolicy(boolean enabled) { }
    public record DeletionPreview(Long userId, boolean deletable, String reason, int ownedTeamCount) { }
    public record DeletionResult(Long userId, boolean success, int dissolvedTeamCount) { }
    private final AdminAccountStore store;
    private final AdminAccessService access;
    private final UserMapper users;
    private final AvatarStorageService avatars;
    public AdminAccountService(AdminAccountStore store, AdminAccessService access, UserMapper users, AvatarStorageService avatars) {
        this.store=store; this.access=access; this.users=users; this.avatars=avatars;
    }

    @Transactional(readOnly = true)
    public RegistrationPolicy getRegistration(Long actor) {
        access.requireAdmin(actor);
        return new RegistrationPolicy(store.registrationEnabled(false));
    }

    @Transactional
    public RegistrationPolicy setRegistration(Long actor, boolean enabled) {
        access.requireAdmin(actor);
        boolean previous=store.lockRegistrationForChange();
        if (previous != enabled) {
            store.setRegistrationEnabled(enabled, actor);
            store.audit(actor, null, enabled ? "registration_open" : "registration_close");
        }
        return new RegistrationPolicy(enabled);
    }

    @Transactional(readOnly = true)
    public DeletionPreview previewDeletion(Long actor, Long target) {
        access.requireAdmin(actor);
        requireUser(target);
        String reason = protectedReason(actor, target);
        return new DeletionPreview(target, reason.isEmpty(), reason, store.ownedTeamCount(target));
    }

    @Transactional
    public DeletionResult deleteUser(Long actor, Long target) {
        access.requireAdmin(actor);
        if (target == null || target <= 0 || users.lockPlanningOwner(target) == null) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "用户不存在");
        }
        User user = requireUser(target);
        String reason = protectedReason(actor, target);
        if (!reason.isEmpty()) throw new BusinessException(ErrorCode.FORBIDDEN, reason);
        int teams = store.deleteUserGraph(target);
        store.audit(actor, target, "user_delete");
        // Filesystem cleanup follows the database commit, never a transaction rollback.
        TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
            @Override public void afterCommit() { avatars.deleteIfManaged(user.getAvatarUrl()); }
        });
        return new DeletionResult(target, true, teams);
    }

    private User requireUser(Long id) {
        User user=id == null || id <= 0 ? null : users.findUserById(id);
        if (user == null) throw new BusinessException(ErrorCode.NOT_FOUND, "用户不存在");
        return user;
    }
    private String protectedReason(Long actor, Long target) {
        if (target.equals(actor)) return "不能删除当前登录的管理员账号";
        if (access.isAdminAccount(target)) return "不能删除白名单管理员账号";
        return "";
    }
}
