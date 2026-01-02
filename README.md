# totallynotacloud 🚀

Минималистичное приложение для хранилища файлов на SwiftUI для macOS и iOS.

## Особенности

- 🎨 Чёрный минималистичный дизайн с белыми и синими кнопками
- 📱 Нативные приложения для iOS и macOS на SwiftUI
- 🔐 Архитектура для интеграции авторизации
- 📡 Готово к интеграции с серверной частью
- 🎯 Modular архитектура MVVM

## Структура проекта

```
totallynotacloud/
├── iOS/
│   ├── totallynotacloud/
│   │   ├── App/
│   │   ├── Models/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   ├── Services/
│   │   └── Resources/
│   └── totallynotacloud.xcodeproj/
├── macOS/
│   ├── totallynotacloud-Mac/
│   ├── Models/
│   ├── Views/
│   └── ViewModels/
└── Shared/
    ├── Models/
    └── Services/
```

## Установка

1. Клонируйте репозиторий
2. Откройте `iOS/totallynotacloud.xcodeproj` в Xcode
3. Выберите целевую платформу (iOS или macOS simulator)
4. Запустите приложение (Cmd+R)

## Технологический стек

- **SwiftUI** - UI фреймворк
- **Combine** - Reactive programming
- **Swift Concurrency** - Асинхронные операции
- **CloudKit** или REST API - Синхронизация файлов

## Этапы разработки

- [x] Инициализация репозитория
- [ ] Базовая UI для iOS
- [ ] Авторизация (mock)
- [ ] Просмотр файлов (mock data)
- [ ] Загрузка файлов
- [ ] macOS версия
- [ ] Серверная часть и API
- [ ] Реальная авторизация
- [ ] Синхронизация между устройствами

## Лицензия

MIT

---

**Статус:** 🚧 В разработке
