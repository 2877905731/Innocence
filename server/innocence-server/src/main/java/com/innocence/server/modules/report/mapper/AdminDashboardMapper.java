package com.innocence.server.modules.report.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface AdminDashboardMapper {
    @Select("select count(*) from app_user")
    long countUsers();

    @Select("select count(*) from app_user where status = 1")
    long countAvailableUsers();

    @Select("select count(*) from study_team where status = 1")
    long countActiveTeams();

    @Select("select count(*) from report_record where status = 'pending'")
    long countPendingReports();

    @Select("select coalesce(sum(duration_seconds), 0) from study_timer_record " +
            "where actual_end_time >= current_date() and actual_end_time < current_date() + interval 1 day")
    long todayStudySeconds();
}
