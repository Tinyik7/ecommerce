## Test Checklist

### 1. Mobile App

| Scenario | Steps | Expected Result |
| --- | --- | --- |
| Authorization | Enter valid email/password, sign in | Snackbar confirms success, user lands on BaseView, token saved in SharedPreferences. |
| Theme switcher | Settings в†’ toggle dark mode | Theme switches instantly and persists after restart. |
| Offline catalog | Turn off network в†’ open app в†’ browse catalog | Offline banner appears, products load from SQLite cache, filters still work locally. |
| Offline cart | Disable network в†’ add product в†’ restart | Product remains in cart (read from cache), total is correct. |
| Favorites | Tap heart on product в†’ open Favorites tab | Item displayed, untapping removes it. |

### 2. API / Backend

1. Run `./mvnw -f backend/pom.xml spring-boot:run` (JDK 17 + PostgreSQL required).  
2. Open `http://localhost:8080/swagger` to verify endpoints.  
3. Import `docs/postman/ecommerce_api.postman_collection.json` and execute:
   - Registration / Login (Postman script stores JWT in environment).  
   - Product CRUD with filters (`query`, `minPrice`, `category`).  
   - Favorites and Cart flows (add/update/delete items).  
4. Test file upload (`POST /products/with-image`):
   - `form-data`: `product` (JSON string), `image` (file).  
   - After request ensure file appears under `/uploads` and accessible via `http://localhost:8080/uploads/<name>`.
5. Error handling checks:
   - Duplicate email в†’ `409 Conflict`.  
   - `/me` without token в†’ `401 Unauthorized`.  
   - Update/delete non-existent product в†’ `404 Not Found`.

### 3. Documentation / Demo

- Update presentation with screenshots of the new filters, admin panel, and profile detail flow (`docs/project_overview.md`).  
- During defense demonstrate offline operation, catalog filters, and admin CRUD.  
- Show Postman scripts and SQLite cache (`ecommerce_cache.db`) as evidence for API/DB tests. 

### 4. Security / Seeds (Backend)

- `POST /api/v1/products` without `ADMIN` token -> `403 Forbidden`.
- `PUT /api/v1/users/{id}/role` without `ADMIN` token -> `403 Forbidden`.
- `GET /api/v1/cart/{userId}` with mismatched token user -> `403 Forbidden`.
- If `APP_ADMIN_SEED_ENABLED=true`, login with admin credentials.
- If `APP_PRODUCTS_SEED_ENABLED=true`, verify initial products exist.


