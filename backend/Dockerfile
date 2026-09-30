# ========================================================
# Dockerfile Backend Java 17 + Spring Boot 3 for Render/Cloud
# ========================================================
# syntax=docker/dockerfile:1

# Stage 1: Build mã nguồn Java
FROM maven:3.9.9-eclipse-temurin-17 AS builder
WORKDIR /app

# Cache Maven .m2 giữa các lần build
COPY pom.xml .
RUN mvn dependency:go-offline -B || true

# Copy mã nguồn backend và đóng gói JAR
COPY src ./src
RUN mvn clean package -DskipTests -B

# Stage 2: Runtime hỗ trợ cả AMD64 và ARM64 (Apple Silicon)
FROM eclipse-temurin:17-jre
WORKDIR /app

# Cài đặt curl để hỗ trợ healthcheck
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

# Copy file jar từ builder stage
COPY --from=builder /app/target/*.jar app.jar

ENV SERVER_PORT=8080 \
    CORS_ALLOWED_ORIGINS=*

EXPOSE 8080

ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar"]
