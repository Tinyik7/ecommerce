# Repository Guidelines

## Project Structure & Module Organization
- Java 17, Spring Boot 3.5.x (Maven wrapper).
- Source: `src/main/java/com/echoes/flutterbackend` with layers: `controller/`, `service/`, `repository/`, `entity/`, `config/`.
- Resources: `src/main/resources` (e.g., `application.properties`).
- Tests: `src/test/java/com/echoes/flutterbackend` mirroring main packages.

## Build, Test, and Development Commands
- Windows: `mvnw clean package` (build), `mvnw test` (tests), `mvnw spring-boot:run` (run locally).
- Unix/macOS: `./mvnw clean package`, `./mvnw test`, `./mvnw spring-boot:run`.
- Artifact: `target/backend-<version>.jar` (Spring Boot fat JAR). DevTools is included for live reload during development.

## Coding Style & Naming Conventions
- Indentation: 4 spaces; line length ~120 where practical.
- Naming: Classes `PascalCase`, methods/fields `camelCase`, constants `UPPER_SNAKE_CASE`.
- Packages: lowercase; place new code under `com.echoes.flutterbackend` and follow existing layer boundaries.
- Use Lombok where already present to reduce boilerplate (getters/setters, constructors).
- Keep controllers thin; put business logic in services; repositories stay interface-based.

## Testing Guidelines
- Framework: JUnit 5 with Spring Boot Test (`spring-boot-starter-test`).
- Location: mirror main packages under `src/test/java`.
- Naming: end with `Tests` (e.g., `ProductServiceTests.java`).
- Run: `mvnw test` / `./mvnw test`. No coverage plugin is configured; add JaCoCo if coverage is required.

## Commit & Pull Request Guidelines
- Commits: imperative mood, concise; optional scope. Example: `feat(controller): add product endpoints`.
- PRs: include summary, linked issues, screenshots or sample requests if applicable, test coverage notes, and local verification steps.
- Keep changes focused; update or add tests with behavior changes.

## Security & Configuration Tips
- Database: PostgreSQL driver included. Configure via `src/main/resources/application.properties` or env vars (`SPRING_DATASOURCE_URL`, `SPRING_DATASOURCE_USERNAME`, `SPRING_DATASOURCE_PASSWORD`).
- Do not commit secrets; prefer environment-specific `application-*.properties`.
- Review `src/main/java/com/echoes/flutterbackend/config/SecurityConfig.java` when adding endpoints to ensure appropriate authorization.

## API Examples
- Get all products: `curl -s http://localhost:8080/api/v1/products`
- Get by id: `curl -s http://localhost:8080/api/v1/products/1`
- Create: `curl -X POST http://localhost:8080/api/v1/products -H "Content-Type: application/json" -d '{"name":"T-Shirt","price":19.99,"quantity":10,"image":"/img/1.png","rating":4.5,"reviews":"12","size":"M","isFavorite":false}'`
- Update: `curl -X PUT http://localhost:8080/api/v1/products/1 -H "Content-Type: application/json" -d '{"name":"T-Shirt","price":17.99,"quantity":12}'`
- Delete: `curl -X DELETE http://localhost:8080/api/v1/products/1`

## Test Coverage (JaCoCo)
- Add to `pom.xml` to generate coverage reports:
  ```xml
  <plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.12</version>
    <executions>
      <execution>
        <goals>
          <goal>prepare-agent</goal>
        </goals>
      </execution>
      <execution>
        <id>report</id>
        <phase>test</phase>
        <goals>
          <goal>report</goal>
        </goals>
      </execution>
    </executions>
  </plugin>
  ```
- After running tests, open `target/site/jacoco/index.html`.
