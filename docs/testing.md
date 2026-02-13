## Test Checklist

### 1. Mobile App

| Scenario | Steps | Expected Result |
| --- | --- | --- |
| Authorization | Enter valid email/password, sign in | Snackbar confirms success, user lands on BaseView, token saved in SharedPreferences. |
| Theme switcher | Settings -> toggle dark mode | Theme switches instantly and persists after restart. |
| Offline catalog | Turn off network -> open app -> browse catalog | Offline banner appears, products load from SQLite cache, filters still work locally. |
| Offline cart | Disable network -> add product -> restart | Product remains in cart (read from cache), total is correct. |
| Favorites | Tap heart on product -> open Favorites tab | Item displayed, untapping removes it. |
| Profile update | Open Profile -> Edit profile -> Save | Updated username/email/name is persisted and shown in Profile and Settings. |
| Password update | Open Profile -> Change password | Password changes when current password is correct. |

### 2. API / Backend

1. Run backend:
   - Local: `./mvnw spring-boot:run`
   - Docker: `docker compose up --build -d`
2. Open `http://localhost:8080/swagger`.
3. Verify auth and user endpoints:
   - Register/login
   - `GET /api/v1/users/me`
   - `PUT /api/v1/users/me`
   - `PUT /api/v1/users/me/password`
4. Verify catalog/cart/favorites:
   - Product CRUD + filters
   - Favorites add/remove/list
   - Cart add/update/remove/list
5. Verify security:
   - `POST /api/v1/products` without ADMIN -> `403`.
   - `PUT /api/v1/users/{id}/role` without ADMIN -> `403`.
   - `GET /api/v1/cart/{userId}` with mismatched token user -> `403`.

### 3. Automated Tests

- Backend command: `./mvnw test`
- Flutter command: `flutter test`
- Current status:
  - Last backend run: `2026-02-13`, `BUILD SUCCESS`, `Tests run: 12, Failures: 0, Errors: 0`.
  - Last flutter run: `2026-02-13`, `All tests passed` (`forgot_password_controller_test`, `forgot_password_view_test`).
  - `BackendApplicationTests` uses `test` profile (H2 in-memory DB).
  - `UserServiceTests` and `ProductServiceTests` cover core business flows.
  - `SecurityIntegrationTests` cover role checks and access isolation:
    - USER cannot create product (`403`).
    - USER cannot update role (`403`).
    - USER cannot access another user's cart/favorites (`403`).
    - ADMIN can create product (`200`).
  - `ValidationIntegrationTests` cover request validation and error format:
    - invalid `POST /api/v1/users/register` -> `400` with field-level `details`.
    - invalid `POST /api/v1/users/login` -> `400` with field-level `details`.
  - Flutter tests cover:
    - email/token/password validation rules in forgot-password controller;
    - forgot-password screen fields/buttons render correctly.

### 4. Seed Verification

- Admin seed:
  - Enable `APP_ADMIN_SEED_ENABLED=true`
  - Login with `APP_ADMIN_EMAIL` / `APP_ADMIN_PASSWORD`
- Product seed:
  - Enable `APP_PRODUCTS_SEED_ENABLED=true`
  - Ensure initial catalog appears on fresh database

### 5. E2E Role Scenarios

1. Login as `USER`:
   - Can browse products.
   - Cannot create/update/delete product (`403`).
2. Login as `ADMIN`:
   - Can perform product CRUD.
   - Can update user role via admin endpoint or admin UI role form.
3. Token isolation:
   - Accessing another user's cart/favorites with valid token returns `403`.
