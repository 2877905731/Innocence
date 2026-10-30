FROM eclipse-temurin:21-jre-jammy
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /app/data/uploads/avatars \
    && chown -R 10001:10001 /app
WORKDIR /app
COPY --chown=10001:10001 backend/server.jar /app/server.jar
USER 10001:10001
EXPOSE 8080
ENTRYPOINT ["java", "-Xms96m", "-Xmx320m", "-Xss512k", "-XX:MaxMetaspaceSize=128m", "-XX:MaxDirectMemorySize=32m", "-XX:ReservedCodeCacheSize=64m", "-XX:+ExitOnOutOfMemoryError", "-jar", "/app/server.jar"]
