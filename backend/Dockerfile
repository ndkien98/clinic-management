# ========================================================
# Dockerfile Backend Java 17 + Spring Boot 3 for Render/Cloud
# ========================================================
# syntax=docker/dockerfile:1

# Stage 1: Build mã nguồn Java
FROM maven:3.9.9-eclipse-temurin-17-alpine AS builder
WORKDIR /app

# Cache Maven .m2 giữa các lần build
COPY pom.xml .
RUN mvn dependency:go-offline -B || true

# Copy mã nguồn backend và đóng gói JAR
COPY src ./src
RUN mvn clean package -DskipTests -B

# Stage 2: Runtime Image siêu nhẹ
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Cài đặt curl để hỗ trợ healthcheck
RUN apk add --no-cache curl

# Copy file jar từ builder stage
COPY --from=builder /app/target/*.jar app.jar

ENV SERVER_PORT=8080 \
    CORS_ALLOWED_ORIGINS=*

EXPOSE 8080

ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar"]
