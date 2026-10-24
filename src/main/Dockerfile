
FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /app
COPY pom.xml .
COPY src ./src

RUN mvn clean package -DskipTests

FROM eclipse-temurin:17-jre

WORKDIR /app

COPY --from=builder /app/target/univ-electionsystem.war ./app.war
COPY --from=builder /app/target/dependency/webapp-runner.jar ./webapp-runner.jar

CMD ["sh", "-c", "java -jar webapp-runner.jar --port ${PORT:-8080} app.war"]

