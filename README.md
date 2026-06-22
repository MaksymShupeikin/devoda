# Devoda — карта точек с водой 💧

Flutter-приложение для поиска и добавления бьюветов, водокачек и автоматов с
водой. Карта на Mapbox, данные в Supabase. Дизайн крупный и светлый — удобный
для старшего поколения.

## Возможности

- **Карта с метками сразу при запуске.** Метки рисуются из GeoJSON-источника
  (не Point Annotation), с простой кластеризацией.
- **Метка как Flutter-виджет.** Карточка-маркер рисуется виджетом и
  растеризуется в изображение для Mapbox (`lib/core/utils/widget_to_image.dart`).
- **Онбординг** при первом запуске с простыми объяснениями.
- **Детали точки** по нажатию + кнопка маршрута через стандартное приложение
  карт (Apple Maps / Google Maps).
- **Добавление точки** (пока моковое: сохраняется локально и в кэш; позже —
  через авторизацию по номеру телефона).
- **Офлайн.** Скачивание области карты вокруг локации + кэш меток в
  SharedPreferences.
- **Фильтры** по типу точки.

## Архитектура

Riverpod (ручные провайдеры, без кодогенерации) + Supabase, послойная
структура `core/` и `features/` — см. `AGENTS.md`.

## Настройка

### 1. Переменные окружения

Скопируйте `.env.example` в `.env` и заполните токены (Supabase + Mapbox public
token). Файл `.env` подключён как ассет в `pubspec.yaml`.

### 2. Mapbox secret download token (обязательно для сборки)

Нативный Mapbox SDK скачивается из приватного Maven/SPM и требует **секретный**
токен со scope `DOWNLOADS:READ` (формат `sk.****`). Публичный `pk.****` для
этого не подходит.

- **Android:** добавьте в `~/.gradle/gradle.properties`:
  ```
  MAPBOX_DOWNLOADS_TOKEN=sk.ваш_секретный_токен
  ```
- **iOS:** добавьте в `~/.netrc`:
  ```
  machine api.mapbox.com
    login mapbox
    password sk.ваш_секретный_токен
  ```

### 3. Supabase

Таблица `public.point` с колонками `latitude` / `longitude` (double),
`amenity` (OSM-значения: `drinking_water`, `water_point`, `vending_machine`),
`type`, `status`, `tags` и т.д.

Включите RLS-политику, разрешающую анонимное чтение активных точек, например:

```sql
alter table public.point enable row level security;

create policy "anon read active points"
  on public.point for select
  to anon
  using (status = 'active');
```

### 4. Запуск

```bash
flutter pub get
flutter run
```
