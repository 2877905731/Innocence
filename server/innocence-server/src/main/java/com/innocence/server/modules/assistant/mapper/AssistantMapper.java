package com.innocence.server.modules.assistant.mapper;

import org.apache.ibatis.annotations.*;

@Mapper
public interface AssistantMapper {
    @Select("SELECT COUNT(*) FROM app_user WHERE id=#{owner} AND status=1")
    int activeOwner(@Param("owner") long owner);
    @Select("SELECT COUNT(*) FROM assistant_document WHERE user_id=#{owner} AND kind='request' AND create_time>DATE_SUB(NOW(),INTERVAL 1 MINUTE)")
    int recentRequests(@Param("owner") long owner);
    @Select("SELECT COUNT(*) FROM assistant_document WHERE user_id=#{owner} AND kind='request' AND create_time>DATE_SUB(NOW(),INTERVAL 1 DAY)")
    int dailyRequests(@Param("owner") long owner);
    @Select("SELECT COUNT(*) FROM assistant_document WHERE user_id=#{owner} AND kind=#{kind} AND document_id=#{id} AND create_time<DATE_SUB(NOW(),INTERVAL 30 DAY)")
    int expired(@Param("owner") long owner, @Param("kind") String kind, @Param("id") String id);
    @Select("SELECT COUNT(*) FROM assistant_document WHERE user_id=#{owner} AND kind='request' AND document_id=#{id} AND create_time<DATE_SUB(NOW(),INTERVAL 20 SECOND)")
    int abandonedRequest(@Param("owner") long owner, @Param("id") String id);
    @Delete("DELETE FROM assistant_document WHERE kind<>'execution' AND create_time<DATE_SUB(NOW(),INTERVAL 7 DAY)")
    int pruneDrafts();
    @Update("UPDATE assistant_document SET payload_json=JSON_OBJECT('hash',JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$.hash')),'status','expired') WHERE kind='execution' AND create_time<DATE_SUB(NOW(),INTERVAL 30 DAY) AND JSON_EXTRACT(payload_json,'$.execution') IS NOT NULL")
    int redactExpiredExecutions();
    @Insert("INSERT IGNORE INTO assistant_document(user_id,kind,document_id,payload_json) VALUES(#{owner},#{kind},#{id},#{json})")
    int claim(@Param("owner") long owner, @Param("kind") String kind, @Param("id") String id, @Param("json") String json);
    @Select("SELECT payload_json FROM assistant_document WHERE user_id=#{owner} AND kind=#{kind} AND document_id=#{id}")
    String read(@Param("owner") long owner, @Param("kind") String kind, @Param("id") String id);
    @Select("SELECT payload_json FROM assistant_document WHERE user_id=#{owner} AND kind=#{kind} AND document_id=#{id} FOR UPDATE")
    String lock(@Param("owner") long owner, @Param("kind") String kind, @Param("id") String id);
    @Update("UPDATE assistant_document SET payload_json=#{json} WHERE user_id=#{owner} AND kind=#{kind} AND document_id=#{id}")
    int update(@Param("owner") long owner, @Param("kind") String kind, @Param("id") String id, @Param("json") String json);
}
