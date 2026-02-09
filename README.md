# Flutter E-commerce App

Flutter client + Spring Boot backend for e-commerce flows: auth, products, favorites, cart, admin operations.

## Project Structure

- Flutter app: `lib/`
- Backend (Spring Boot): `Bэckend/`
- Documentation: `docs/`

## Backend Quick Start (Docker)

```bash
cd Bэckend
docker compose up --build -d
```

Backend URL: `http://localhost:8080`

## Backend Environment Variables

- `APP_JWT_SECRET` (required for production)
- `SPRING_DATASOURCE_URL`
- `SPRING_DATASOURCE_USERNAME`
- `SPRING_DATASOURCE_PASSWORD`
- `APP_ADMIN_SEED_ENABLED` (`true/false`)
- `APP_ADMIN_EMAIL`
- `APP_ADMIN_PASSWORD`
- `APP_ADMIN_USERNAME`
- `APP_PRODUCTS_SEED_ENABLED` (`true/false`)

## Security Model

- Authentication: JWT bearer token.
- Authorization:
  - Public: register/login, health, swagger, product read.
  - `ADMIN` only: product write (`POST/PUT/DELETE`), role updates.
  - Authenticated user only: cart/favorites/profile endpoints.
- User isolation:
  - Cart/favorites enforce `path userId == token userId`.

## Main API Endpoints

- Auth:
  - `POST /api/v1/users/register`
  - `POST /api/v1/users/login`
  - `GET /api/v1/users/me`
- Profile:
  - `PUT /api/v1/users/me`
  - `PUT /api/v1/users/me/password`
- Roles (admin):
  - `PUT /api/v1/users/{id}/role`
- Products:
  - `GET /api/v1/products`
  - `POST /api/v1/products` (admin)
  - `PUT /api/v1/products/{id}` (admin)
  - `DELETE /api/v1/products/{id}` (admin)

## Run Tests

```bash
cd Bэckend
./mvnw test
```

Test profile uses H2 in-memory DB: `Bэckend/src/test/resources/application-test.properties`.

## Flutter

```bash
flutter pub get
flutter run
```

For Android emulator host mapping, run with:

```bash
flutter run --dart-define=USE_ANDROID_EMULATOR_HOST=true
```
