## 1. Технологии

- **PostgreSQL** — основная БД, `spring.jpa.hibernate.ddl-auto=update`.  
- **Flyway/миграции** не подключались (можно добавить позже), структура описана ниже.  
- **SQLite (sqflite)** — локальный кеш в приложении (`local_database_service.dart`).

## 2. ER-диаграмма (логическая)

```mermaid
erDiagram
    USERS ||--o{ CARTS : owns
    USERS ||--o{ FAVORITES : marks
    CARTS ||--o{ CART_ITEMS : contains
    PRODUCTS ||--o{ CART_ITEMS : "referenced via productId"
    PRODUCTS ||--o{ FAVORITES : "referenced via productId"
```

### Таблицы

| Таблица | Ключевые поля |
| --- | --- |
| `users` | `id`, `name`, `email (unique)`, `password` (bcrypt) |
| `products` | `id`, `name`, `description`, `price`, `rating`, `category`, `image`, `featured`, `discount`, `in_stock`, `created_at`, `updated_at` |
| `favorites` | `id`, `user_id`, `product_id` |
| `carts` | `id`, `user_id` |
| `cart_items` | `id`, `cart_id`, `product_id`, `quantity` |

## 3. CRUD-операции

- **Products** — полный CRUD + фильтры/сортировки (см. `ProductService`, `ProductSpecifications`).  
- **Favorites** — `FavoriteService` предотвращает дубли по `userId/productId`, возвращает готовые `ProductResponse`.  
- **Cart** — `CartService` формирует DTO с товарами и суммой, все эндпоинты возвращают актуальное состояние корзины.  
- **Users** — регистрация/логин/удаление (опционально) с валидацией уникальности почты.

## 4. Валидация и ошибки

- `ProductRequest` помечен `@NotBlank`, `@Min` и т.д.  
- `GlobalExceptionHandler` приводит ошибки к формату `{ status, message, details, timestamp }`.  
- Конфликты email → `409 Conflict`. Отсутствующие сущности → `404`. Невалидные данные → `400`.

## 5. Локальная БД (Flutter)

- Файл `local_database_service.dart` создаёт три таблицы: `products`, `cart_items`, `favorites`.  
- Использование:
  - При успешной загрузке каталога вызываем `cacheProducts`.
  - При работе офлайн читаем товары/корзину из SQLite.
  - Избранное синхронизируется локально, чтобы отображать сердечки без запроса к серверу.

## 6. Поиск, фильтрация, сортировка

- На бэкенде — `JpaSpecificationExecutor` с фильтрами `query`, `category`, `minPrice`, `maxPrice`, `minRating`, `inStock`, `onlyFavorites`.
- На фронте — дополнительная фильтрация + сортировки (`HomeController`), чтобы не показывать устаревшие данные из кеша.

## 7. Тестирование БД

- **API**: Postman-скрипты для CRUD-операций (`docs/postman/...`).  
- **Логи Hibernate** (`spring.jpa.show-sql=true`) — позволяют видеть фактические запросы при защите.  
- **Manual QA**: сценарии в `docs/testing.md` включают добавление/удаление товаров, проверку офлайн-кеша и повторное подключение.
