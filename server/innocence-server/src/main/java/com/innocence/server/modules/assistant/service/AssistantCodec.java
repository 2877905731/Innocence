package com.innocence.server.modules.assistant.service;

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.MapperFeature;
import org.springframework.stereotype.Component;

@Component
public class AssistantCodec {
    private final ObjectMapper mapper;
    public AssistantCodec(ObjectMapper mapper) {
        this.mapper = mapper.copy()
                .disable(MapperFeature.ALLOW_COERCION_OF_SCALARS)
                .disable(DeserializationFeature.ACCEPT_FLOAT_AS_INT)
                .enable(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES)
                .enable(DeserializationFeature.FAIL_ON_NULL_FOR_PRIMITIVES)
                .enable(DeserializationFeature.FAIL_ON_TRAILING_TOKENS)
                .enable(JsonParser.Feature.STRICT_DUPLICATE_DETECTION);
    }
    public <T> T read(String json, Class<T> type) {
        if (json == null || json.length() > 262144) throw AssistantException.invalid("助手数据过大或缺失。");
        try { return mapper.readValue(json, type); }
        catch (Exception error) { throw AssistantException.invalid("助手数据字段或格式不正确。"); }
    }
    public String write(Object value) {
        try { return mapper.writeValueAsString(value); }
        catch (Exception error) { throw new IllegalStateException("Assistant serialization failed."); }
    }
    public void validateBody(String json) {
        try {
            var value = mapper.readTree(json);
            if (value == null || !value.isObject() || (value.has("editedItems") && value.get("editedItems").isNull()))
                throw AssistantException.invalid("editedItems可省略，不能为null。");
        } catch (AssistantException error) { throw error; }
        catch (Exception error) { throw AssistantException.invalid("助手请求格式不正确。"); }
    }
}
