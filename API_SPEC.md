# API спецификация

## Base URL

```
https://api.totallynotacloud.com/api/v1
```

## Общие эндпойнты

### Автентификация

#### POST `/auth/register`

Регистрация нового пользователя

**Request:**
```json
{
  "email": "user@example.com",
  "username": "username",
  "password": "securepassword123"
}
```

**Response (200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid-string",
    "email": "user@example.com",
    "username": "username",
    "createdAt": "2026-01-02T11:00:00Z",
    "storageUsed": 0,
    "storageLimit": 10737418240
  }
}
```

#### POST `/auth/login`

Вход пользователя

**Request:**
```json
{
  "email": "user@example.com",
  "password": "securepassword123"
}
```

**Response (200):** При успех - то же как `/auth/register`

#### POST `/auth/logout`

Выход пользователя

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "success": true
}
```

#### GET `/auth/me`

Получить текущего пользователя

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "id": "uuid-string",
  "email": "user@example.com",
  "username": "username",
  "createdAt": "2026-01-02T11:00:00Z",
  "storageUsed": 1024000,
  "storageLimit": 10737418240
}
```

### Файлы

#### GET `/files`

Получить список файлов

**Headers:**
```
Authorization: Bearer <token>
```

**Query Parameters:**
```
?folderId=<optional_folder_id>
?limit=20
?offset=0
```

**Response (200):**
```json
{
  "files": [
    {
      "id": "file-uuid",
      "name": "document.pdf",
      "size": 2500000,
      "mimeType": "application/pdf",
      "uploadedAt": "2026-01-02T11:00:00Z",
      "updatedAt": "2026-01-02T11:00:00Z",
      "isDirectory": false,
      "parentId": "parent-uuid"
    }
  ],
  "total": 150,
  "limit": 20,
  "offset": 0
}
```

#### POST `/files/upload`

Загрузить файл

**Headers:**
```
Authorization: Bearer <token>
Content-Type: multipart/form-data
```

**Form Data:**
```
file: <binary_data>
parentId: <optional_parent_id>
```

**Response (201):**
```json
{
  "id": "file-uuid",
  "name": "document.pdf",
  "size": 2500000,
  "mimeType": "application/pdf",
  "url": "https://storage.totallynotacloud.com/file-uuid",
  "uploadedAt": "2026-01-02T11:00:00Z"
}
```

#### DELETE `/files/:id`

Удалить файл

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "success": true,
  "freedSpace": 2500000
}
```

#### PATCH `/files/:id`

Переименовать файл

**Headers:**
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Request:**
```json
{
  "name": "new-name.pdf"
}
```

**Response (200):**
```json
{
  "id": "file-uuid",
  "name": "new-name.pdf",
  "updatedAt": "2026-01-02T11:00:00Z"
}
```

#### POST `/files/folder`

Создать папку

**Headers:**
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Request:**
```json
{
  "name": "My Folder",
  "parentId": "<optional_parent_id>"
}
```

**Response (201):**
```json
{
  "id": "folder-uuid",
  "name": "My Folder",
  "size": 0,
  "mimeType": "application/x-folder",
  "isDirectory": true,
  "uploadedAt": "2026-01-02T11:00:00Z",
  "updatedAt": "2026-01-02T11:00:00Z"
}
```

### Хранилище

#### GET `/storage/usage`

Получить информацию о стореже

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "used": 1024000,
  "limit": 10737418240,
  "remaining": 10736394240,
  "percentUsed": 9.5
}
```

## Коды ошибок

| Код | Описание |
|---|---|
| 200 | OK |
| 201 | Created |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 409 | Conflict (file exists) |
| 413 | Payload Too Large |
| 429 | Too Many Requests |
| 500 | Internal Server Error |

## Осыбленности

### Авторизация

- Они используют JWT токены в заголовке `Authorization: Bearer <token>`
- Токен вытекает через 24 часа
- Refresh token доставляется как HttpOnly cookie

### Правила доступа

- Только авторизованные пользователи могут загружать файлы
- Пользователи могут видеть только свои файлы
- Пользователи не могут превышать слід а квоты

### Нагружение

- Максимальный размер файла: 5GB
- Максимально загружек в секунду: 5
- Оптимистическая работа multipart upload для больших файлов

## Полезные ссылки

- [JWT RFC 7519](https://tools.ietf.org/html/rfc7519)
- [RESTful API Best Practices](https://restfulapi.net/)
- [HTTP Status Codes](https://httpwg.org/specs/rfc7231.html#status.codes)

## Ноты для разработки

- Все timestamp в ISO 8601 формате
- UUID v4 для всех ID
- Каосльные чтения доступные по ссылке
- Content-Type всегда `application/json` кроме POST upload

---

**Обратите внимание**: На стадии разработки - детали API могут измениться
