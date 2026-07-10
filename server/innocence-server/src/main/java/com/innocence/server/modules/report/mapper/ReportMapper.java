package com.innocence.server.modules.report.mapper;

import com.innocence.server.modules.report.domain.ActivePunishmentRow;
import com.innocence.server.modules.report.domain.AdminUserDetailRow;
import com.innocence.server.modules.report.domain.AdminUserPunishmentRow;
import com.innocence.server.modules.report.domain.AdminUserReportRow;
import com.innocence.server.modules.report.domain.AdminUserSearchRow;
import com.innocence.server.modules.report.domain.PunishmentRecord;
import com.innocence.server.modules.report.domain.ReportAuditRecord;
import com.innocence.server.modules.report.domain.ReportDetailRow;
import com.innocence.server.modules.report.domain.ReportListItemRow;
import com.innocence.server.modules.report.domain.ReportRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;

@Mapper
public interface ReportMapper {

    void insertReportRecord(ReportRecord reportRecord);

    ReportRecord findReportById(@Param("reportId") Long reportId);

    ReportRecord findReportByUserAndTarget(
            @Param("reportUserId") Long reportUserId,
            @Param("reportType") String reportType,
            @Param("targetId") Long targetId
    );

    List<ReportListItemRow> findReports(
            @Param("status") String status,
            @Param("reportType") String reportType,
            @Param("limit") Integer limit
    );

    ReportDetailRow findReportDetail(@Param("reportId") Long reportId);

    List<ReportAuditRecord> findAuditHistory(@Param("reportId") Long reportId);

    int updateReportHandled(
            @Param("reportId") Long reportId,
            @Param("status") String status,
            @Param("handledUserId") Long handledUserId,
            @Param("handledTime") LocalDateTime handledTime
    );

    void insertAuditRecord(ReportAuditRecord record);

    void insertPunishmentRecord(PunishmentRecord record);

    ActivePunishmentRow findActivePunishment(
            @Param("userId") Long userId,
            @Param("punishmentType") String punishmentType,
            @Param("now") LocalDateTime now
    );

    List<AdminUserSearchRow> searchUsers(
            @Param("keyword") String keyword,
            @Param("limit") Integer limit
    );

    AdminUserDetailRow findAdminUserDetail(@Param("userId") Long userId);

    List<AdminUserReportRow> findReportsByTargetUserId(
            @Param("userId") Long userId,
            @Param("limit") Integer limit
    );

    List<AdminUserPunishmentRow> findPunishmentsByUserId(
            @Param("userId") Long userId,
            @Param("statusFilter") String statusFilter,
            @Param("now") LocalDateTime now,
            @Param("limit") Integer limit
    );

    AdminUserPunishmentRow findPunishmentById(@Param("punishmentId") Long punishmentId);

    int liftPunishment(
            @Param("punishmentId") Long punishmentId,
            @Param("handledTime") LocalDateTime handledTime
    );
}
