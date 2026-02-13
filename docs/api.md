## API Overview

- Base URL: `http://localhost:8080`
- Swagger UI: `http://localhost:8080/swagger`
- OpenAPI JSON: `http://localhost:8080/api/docs`
- Auth: `Authorization: Bearer <token>`

## Access Rules

- Public:
  - `POST /api/v1/users/register`
  - `POST /api/v1/users/login`
  - `GET /api/v1/products`
  - `GET /api/v1/products/{id}`
  - `GET /actuator/health`
- Authenticated:
  - profile endpoints
  - cart endpoints
  - favorites endpoints
- Admin only:
  - product write endpoints (`POST/PUT/DELETE`)
  - role update endpoint

## User Endpoints

### Register
- `POST /api/v1/users/register`
- Body:
```json
{
  "username": "demo",
  "name": "Demo User",
  "email": "demo@example.com",
  "password": "Demo123!"
}
```
- Responses:
  - `200` created user payload
  - `409` email/username conflict

### Login
- `POST /api/v1/users/login`
- Body:
```json
{
  "email": "demo@example.com",
  "password": "Demo123!"
}
```
- Responses:
  - `200` token + user info
  - `401` invalid credentials

### Forgot Password (Demo Token Mode)
- `POST /api/v1/users/forgot-password`
- Body:
```json
{
  "email": "demo@example.com"
}
```
- Responses:
  - `200` generic message
  - `200` with `resetToken` when account exists (demo mode, no SMTP required)

### Reset Password by Token
- `POST /api/v1/users/reset-password`
- Body:
```json
{
  "token": "uuid-token",
  "newPassword": "Demo789!"
}
```
- Responses:
  - `200` password updated
  - `400` invalid or expired token

### Current User
- `GET /api/v1/users/me`
- Responses:
  - `200` user profile
  - `401` invalid/missing token

### Update Profile
- `PUT /api/v1/users/me`
- Body:
```json
{
  "username": "newdemo",
  "name": "New Demo",
  "email": "newdemo@example.com"
}
```
- Responses:
  - `200` updated profile
  - `401` invalid/missing token
  - `409` email/username conflict

### Change Password
- `PUT /api/v1/users/me/password`
- Body:
```json
{
  "currentPassword": "Demo123!",
  "newPassword": "Demo456!"
}
```
- Responses:
  - `200` password updated
  - `400` invalid current password
  - `401` invalid/missing token

### Update Role (Admin)
- `PUT /api/v1/users/{id}/role`
- Body:
```json
{
  "role": "ADMIN"
}
```
- Responses:
  - `200` role updated
  - `400` invalid role/body
  - `403` forbidden

## Product Endpoints

### List/Search
- `GET /api/v1/products`
- Query params:
  - `query`, `category`, `minPrice`, `maxPrice`, `minRating`, `inStock`, `onlyFavorites`
  - `page`, `size`, `sortBy(name|price|rating|createdAt)`, `sortDir(asc|desc)`

### Get by Id
- `GET /api/v1/products/{id}`

### Create (Admin)
- `POST /api/v1/products`
- Body example:
```json
{
  "name": "New Product",
  "price": 19.99,
  "quantity": 5,
  "category": "Clothing",
  "in_stock": true
}
```

### Update (Admin)
- `PUT /api/v1/products/{id}`

### Delete (Admin)
- `DELETE /api/v1/products/{id}`

## Favorites Endpoints

- `GET /api/v1/favorites/{userId}`
- `POST /api/v1/favorites/{userId}/add`
- `DELETE /api/v1/favorites/{userId}/remove/{productId}`

Note:
- `userId` in path must match user from token; otherwise `403`.

## Cart Endpoints

- `GET /api/v1/cart/{userId}`
- `POST /api/v1/cart/{userId}/add`
- `PUT /api/v1/cart/{userId}/update/{productId}`
- `DELETE /api/v1/cart/{userId}/remove/{productId}`
- `DELETE /api/v1/cart/item/{itemId}`
- `DELETE /api/v1/cart/{userId}/clear`

Note:
- `userId` in path must match user from token; otherwise `403`.

## Unified Error Format

Errors are returned via global exception handler:

```json
{
  "status": 403,
  "message": "Access denied",
  "details": null,
  "timestamp": "2026-02-10T10:00:00Z"
}
```
