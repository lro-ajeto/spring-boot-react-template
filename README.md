# React + Spring Boot starter

This project demonstrates how to integrate a modern React front end with a Spring Boot back end in a single repository. The Maven build compiles the Java application and, through the `frontend-maven-plugin`, installs Node.js, builds the React application, and packages the resulting static assets into the Spring Boot jar.

## Project structure

```
├── frontend/                 # React application (Vite)
│   ├── package.json          # Front-end dependencies and scripts
│   └── src/                  # React source code
├── pom.xml                   # Spring Boot project definition with React build integration
└── src/
    ├── main/java             # Spring Boot source code
    ├── main/resources        # Application resources
    └── test/java             # Automated tests
```

## Prerequisites

- Java 21+
- Maven 3.9+ (the repo ships with a lightweight `mvnw` script that configures proxies automatically)
- Node.js 18+ (optional for local front-end development; Maven will download its own version during the build)

## Running the application

1. **Install front-end dependencies** (required only for local front-end development):

   ```bash
   cd frontend
   npm install
   ```

2. **Run the full-stack application with Maven**:
   
   Linux:
   ```bash
   ./mvnw spring-boot:run
   ```
   
   Windows:
   ```bash
   .\mvnw.cmd spring-boot:run
   ```

   Maven will build the React application and copy the compiled assets into `src/main/resources/static`, allowing Spring Boot to serve them alongside the API.

3. **Develop the React app independently**:

   ```bash
   cd frontend
   npm install
   npm run dev
   ```

   The development server proxies API requests to Spring Boot at `http://localhost:8080`.

4. **Run tests**:

   ```bash
   ./mvnw test
   ```

## Containerized workflow

If you prefer running the stack without installing Java or Node locally, you can build and run the application through Docker.

1. **Build the production image**:

   ```bash
   docker build -t spring-boot-react-template .
   ```

   This command performs the full Maven build (including the React assets) inside the container and produces a lightweight run
time image.

2. **Start the application with Docker Compose**:

   ```bash
   docker compose up --build
   ```

   The service is exposed on <http://localhost:8080>. Docker Compose will rebuild the image automatically when source files change.

3. **Stop the container**:

   ```bash
   docker compose down
   ```

## Available endpoints

- `GET /api/greeting` &mdash; returns a simple greeting with a timestamp.
- `GET /` &mdash; serves the React single-page application. Unknown routes are forwarded to `index.html` (excluding `/api/**`).

## Building a production jar

To build the executable jar that contains both the Spring Boot application and the compiled React assets, run:

```bash
./mvnw clean package
```

The resulting artifact is located in `target/spring-boot-react-template-0.0.1-SNAPSHOT.jar`.
