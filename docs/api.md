## 1. Общие сведения

- Бэкенд: Spring Boot 3.5.7 + PostgreSQL, JWT авторизация.  
- Swagger UI: `http://localhost:8080/swagger` (добавлен springdoc).  
- OpenAPI JSON: `http://localhost:8080/api/docs`.  
- Postman коллекция: `docs/postman/ecommerce_api.postman_collection.json`.

## 2. Пользователи (`/api/v1/users`)

| Метод | URL | Описание |
| --- | --- | --- |
| `POST` | `/register` | Тело `{ "name": "", "email": "", "password": "" }` → создает пользователя, возвращает id и username. |
| `POST` | `/login` | Возвращает JWT + профиль. |
| `GET` | `/me` | Требует `Authorization: Bearer <token>`, отдаёт id/email/username. |

### Пример логина

```http
POST /api/v1/users/login
Content-Type: application/json

{
  "email": "demo@echoes.app",
  "password": "password"
}
```

Ответ:

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "id": 1,
  "email": "demo@echoes.app",
  "username": "Demo User"
}
```

## 3. Каталог (`/api/v1/products`)

| Метод | Описание |
| --- | --- |
| `GET /api/v1/products` | Поддерживает `query`, `category`, `minPrice`, `maxPrice`, `minRating`, `inStock`, `onlyFavorites`, `page`, `size`, `sortBy=name|price|rating|createdAt`, `sortDir=asc|desc`. Возвращает `PageResponse` (`items`, `totalElements`, ...). |
| `GET /api/v1/products/{id}` | Карточка с расширенными полями. |
| `POST /api/v1/products` | JSON-тело `ProductRequest`, создаёт товар (для админки). |
| `POST /api/v1/products/with-image` | Множественная часть `product` (JSON строка) + `image`. Файл сохраняется в `/uploads`. |
| `PUT /api/v1/products/{id}` / `{id}/with-image` | Полное обновление. |
| `DELETE /api/v1/products/{id}` | Удаление. |

### Пример фильтрации

```
GET /api/v1/products?query=sneakers&category=shoes&minPrice=50&sortBy=price&sortDir=asc
```

Ответ (сокращён):

```json
{
  "items": [
    {
      "id": 12,
      "name": "City Sneakers",
      "price": 59.99,
      "rating": 4.8,
      "category": "Shoes",
      "inStock": true,
      "image": "/uploads/12_city.png"
    }
  ],
  "totalElements": 3,
  "totalPages": 1,
  "page": 0,
  "size": 20,
  "hasNext": false
}
```

## 4. Избранное (`/api/v1/favorites`)

| Метод | URL | Описание |
| --- | --- | --- |
| `GET` | `/{userId}` | Возвращает готовый список `ProductResponse`, нет необходимости делать N запросов. |
| `POST` | `/{userId}/add` | Тело `{ "productId": 5 }`. |
| `DELETE` | `/{userId}/remove/{productId}` | Удаляет товар из избранного. |

## 5. Корзина (`/api/v1/cart`)

| Метод | URL | Описание |
| --- | --- | --- |
| `GET` | `/{userId}` | Возвращает `CartResponse` (итоговая сумма + список `CartItemResponse` с вложенным `ProductResponse`). |
| `POST` | `/{userId}/add` | `{ "productId": 4, "quantity": 1 }`. |
| `PUT` | `/{userId}/update/{productId}` | Обновление количества. |
| `DELETE` | `/{userId}/remove/{productId}` | Удалить по productId. |
| `DELETE` | `/item/{itemId}` | Удаление по itemId. |
| `DELETE` | `/{userId}/clear` | Очистка корзины. |

### Ответ

```json
{
  "cartId": 2,
  "userId": 1,
  "total": 139.98,
  "items": [
    {
      "itemId": 11,
      "quantity": 2,
      "product": {
        "id": 5,
        "name": "Luna Hoodie",
        "price": 69.99,
        "size": "M",
        "image": "http://localhost:8080/uploads/hoodie.png"
      }
    }
  ]
}
```

## 6. Тестирование API

1. **Swagger** — быстро проверить контракт, отправить multipart, увидеть схему DTO.  
2. **Postman** — коллекция в `docs/postman` содержит среды `Local` (порт 8080), примеры для авторизации (скрипт автоматически кладёт JWT в переменную).  
3. **Flutter** — `HomeController` логирует результат `testConnection()` при старте, чтобы убедиться, что API доступен.  
4. **Jackson/Validation** — `ProductRequest`/`GlobalExceptionHandler` возвращают структурированные ошибки (`status`, `message`, `details`).

## 7. Асинхронность и оптимизация обмена

- Клиент использует `http` + `Future`/`async`, прогресс-бары и Offline fallback.  
- Локальный кеш (`sqflite`) уменьшает количество сетевых вызовов и позволяет показывать каталог/корзину без сети.  
- На бэкенде фильтрация реализована на уровне БД (`JpaSpecificationExecutor`), поэтому на клиент уходит уже готовая выборка.



