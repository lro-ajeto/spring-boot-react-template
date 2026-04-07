# Build stage: compile the Spring Boot application and bundled React assets
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app

# Copy pom first to take advantage of Docker layer caching for dependencies
COPY pom.xml ./
COPY frontend/package.json frontend/package.json
COPY frontend/package-lock.json frontend/package-lock.json

# Pre-fetch Maven and npm dependencies (will also download the Node runtime via the frontend-maven-plugin)
RUN mvn -B -DskipTests dependency:go-offline

# Copy the full project and build the executable jar with bundled front-end assets
COPY . ./
RUN mvn -B -DskipTests package

# Runtime stage: lightweight JRE to run the packaged application
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Copy the fat jar produced by the build stage
COPY --from=build /app/target/*.jar app.jar

# Expose the default Spring Boot port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
