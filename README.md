<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/brand/devoda-logo-dark.svg">
    <img src="docs/brand/devoda-logo.svg" alt="Devoda" height="72">
  </picture>
</p>

<p align="center">
  <b>Where can I get drinking water nearby?</b><br>
  A map of public wells, water pumps, water vending machines and Invincibility Points — built to be easy to use at any age.
</p>

<p align="center">
  <a href="#-key-features"><img alt="Platform: iOS and Android" src="https://img.shields.io/badge/platform-iOS%20%C2%B7%20Android-0A6CCB?style=for-the-badge"></a>
  <a href="#-key-features"><img alt="Languages: English and Ukrainian" src="https://img.shields.io/badge/languages-EN%20%C2%B7%20UK-12222F?style=for-the-badge"></a>
</p>

<p align="center">
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white">
  <img alt="Dart" src="https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white">
  <img alt="Riverpod" src="https://img.shields.io/badge/Riverpod-2-0A6CCB">
  <img alt="GoRouter" src="https://img.shields.io/badge/GoRouter-17-18B6E6">
  <img alt="Mapbox" src="https://img.shields.io/badge/Mapbox-000000?logo=mapbox&logoColor=white">
  <img alt="Supabase" src="https://img.shields.io/badge/Supabase-3FCF8E?logo=supabase&logoColor=white">
  <img alt="PostgreSQL" src="https://img.shields.io/badge/PostgreSQL-4169E1?logo=postgresql&logoColor=white">
  <img alt="OpenStreetMap" src="https://img.shields.io/badge/OpenStreetMap-7EBC6F?logo=openstreetmap&logoColor=white">
  <img alt="Material 3" src="https://img.shields.io/badge/Material%203-757575?logo=materialdesign&logoColor=white">
  <img alt="iOS" src="https://img.shields.io/badge/iOS-000000?logo=apple&logoColor=white">
  <img alt="Android" src="https://img.shields.io/badge/Android-3DDC84?logo=android&logoColor=black">
</p>

A modern Flutter app for finding and adding public wells, water pumps, water vending machines and Invincibility Points. The map is built on the Mapbox Maps SDK, while the backend and authentication run on Supabase. The interface is designed for users of every age, including older people (large controls, high contrast).

---

## 🚀 Key Features

- **Interactive Mapbox map:** Thousands of points render quickly thanks to geo-clustering at the Mapbox style level (Symbol/Circle layers).
- **Custom widget markers:** Marker cards are rendered on the fly by an off-screen raster renderer ([WidgetToImage](lib/core/utils/widget_to_image.dart)) for maximum performance.
- **Animated water-drop loader:** A custom map loading indicator shaped like a drop of water, built with `CustomPainter` and sine-wave liquid motion.
- **Two languages (localization):** The app's base language is **English**, and you can switch to Ukrainian instantly right from the home screen.
- **Secure sign-in (Phone + OTP):** Sign in with your phone number using the `pinput` package (the smart input field automatically recognizes and formats Ukrainian `+380` numbers and US `+1 800` test numbers).
- **Reports and feedback:** Report the state of a water source (e.g. "No water", "Broken"). Reports are stored in Supabase and are deleted in cascade when the point is deleted.
- **Offline mode:** Points are cached in local storage (`SharedPreferences`), and map tiles for a selected area can be downloaded for offline use.

---

## 🛠 Tech Stack

* **Framework:** Flutter (iOS / Android)
* **State management:** [Riverpod](https://riverpod.dev) (providers are declared **manually** only, without code generation — `@riverpod` and `build_runner` are not used).
* **Database & Auth:** [Supabase](https://supabase.com) (PostgreSQL, GoTrue Auth, Realtime).
* **Navigation:** [GoRouter](https://pub.dev/packages/go_router) with declarative rules and Auth Guards.
* **Styling:** Vanilla Flutter (Material 3).

---

## 📁 Project Architecture

The project is split into isolated features (`features/`) and a shared core (`core/`). Each feature is organized into layers:
```text
lib/
├── core/                         # Code shared across the app
│   ├── l10n/                     # Localization (AppLocalizations)
│   ├── theme/                    # Design system (colors, fonts)
│   ├── services/                 # Global services (Supabase, Location)
│   └── widgets/                  # Shared UI components (AppButton, loaders)
│
└── features/                     # Business features of the app
    ├── auth/                     # Sign-in, OTP code verification
    ├── map/                      # Map logic, marker rendering, filters
    ├── onboarding/               # Tutorial slides on first launch
    ├── reports/                  # Reports on the state of water sources
    └── resilience/               # Invincibility Points
```

Layers inside a feature:
1. `models/` — plain Dart models (hand-written `fromJson`/`toJson`, `copyWith`, `operator ==` and `hashCode`).
2. `services/` — stateless Supabase queries.
3. `controllers/` — `Notifier` / `AsyncNotifier` (UI state management).
4. `presentation/` — pages (`pages/`) and components (`widgets/`).

---

## ⚙️ Local Setup

### 1. Environment variables (.env)
Create a `.env` file in the project root and fill it in (see `.env.example` for examples):
```ini
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key
MAPBOX_PUBLIC_TOKEN=pk.your-mapbox-public-token
MAPBOX_STYLE_URL=mapbox://styles/your-username/your-style-id
```
> ⚠️ **Important:** Make sure there are no stray characters or Cyrillic letters (e.g. `ф`) at the end of `MAPBOX_STYLE_URL`, otherwise Mapbox returns a 404 error and the map won't load.

### 2. Mapbox Downloads Token (for iOS/Android builds)
To download the native Mapbox SDK, add a secret token (in `sk.***` format, with the `DOWNLOADS:READ` scope):
- **Android:** in `~/.gradle/gradle.properties`:
  ```properties
  MAPBOX_DOWNLOADS_TOKEN=sk.your_secret_token
  ```
- **iOS:** in `~/.netrc`:
  ```text
  machine api.mapbox.com
    login mapbox
    password sk.your_secret_token
  ```

---

## 🗄 Database Structure & RLS (Supabase SQL)

For the app to work correctly, the Supabase database needs the following tables, relations, security policies (RLS) and triggers.

### 1. `water_points` table (water sources)
```sql
CREATE TABLE public.water_points (
  id bigint GENERATED BY DEFAULT AS IDENTITY (START WITH 400) NOT NULL,
  osm_id text NULL,
  amenity text NULL,
  name text NULL,
  wheelchair text NULL,
  fee text NULL,
  access text NULL,
  opening_hours text NULL,
  region text NOT NULL DEFAULT 'manual'::text,
  tags jsonb NOT NULL DEFAULT '{}'::jsonb,
  type text NOT NULL,
  status text NOT NULL DEFAULT 'active'::text,
  latitude double precision NOT NULL,
  longitude double precision NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  
  CONSTRAINT water_points_pkey PRIMARY KEY (id)
);

-- Enable RLS
ALTER TABLE public.water_points ENABLE ROW LEVEL SECURITY;

-- Allow SELECT for everyone (guests and signed-in users)
CREATE POLICY "Allow select for everyone" 
  ON public.water_points FOR SELECT 
  USING (status IN ('active', 'reported'));

-- Allow INSERT for signed-in users only
CREATE POLICY "Allow insert for authenticated users" 
  ON public.water_points FOR INSERT 
  TO authenticated 
  WITH CHECK (true);
```

### 2. `report` table (reports on the state of sources)
```sql
CREATE TABLE public.report (
  id bigserial NOT NULL,
  point_id bigint NOT NULL,
  user_id uuid NULL DEFAULT auth.uid(),
  admin_id uuid NULL,
  reported_condition text NOT NULL,
  description text NULL,
  status public.report_status NOT NULL DEFAULT 'new'::report_status,
  reviewed_at timestamp with time zone NULL,
  resolution_note text NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  
  CONSTRAINT report_pkey PRIMARY KEY (id),
  -- Delete reports in cascade when the water point is deleted
  CONSTRAINT report_point_id_fkey FOREIGN KEY (point_id) REFERENCES public.water_points (id) ON DELETE CASCADE,
  CONSTRAINT report_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES auth.users (id) ON DELETE SET NULL,
  CONSTRAINT report_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users (id) ON DELETE SET NULL
) TABLESPACE pg_default;

-- Indexes
CREATE INDEX IF NOT EXISTS report_point_id_idx ON public.report USING btree (point_id);
CREATE INDEX IF NOT EXISTS report_status_idx ON public.report USING btree (status);
CREATE INDEX IF NOT EXISTS report_user_id_idx ON public.report USING btree (user_id);

-- RLS setup
ALTER TABLE public.report ENABLE ROW LEVEL SECURITY;

-- Everyone can read reports
CREATE POLICY "Allow select for everyone" 
  ON public.report FOR SELECT 
  USING (true);

-- Reports can only be created when signed in, under your own UID
CREATE POLICY "Allow insert for authenticated users" 
  ON public.report FOR INSERT 
  TO authenticated 
  WITH CHECK (auth.uid() = user_id);
```

### 3. Trigger that updates a point's status when it is reported
When a report is added to the `report` table, the status of the matching water source automatically changes to `reported`.

**Trigger function:**
```sql
CREATE OR REPLACE FUNCTION public.on_report_insert()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  -- Update the source's status in the water_points table
  update public.water_points 
  set status = 'reported' 
  where id = new.point_id;
  
  return new;
end;
$function$;
```

**Creating the trigger:**
```sql
CREATE TRIGGER on_report_insert
AFTER INSERT ON public.report
FOR EACH ROW
EXECUTE FUNCTION on_report_insert();
```

---

## 🧑‍💻 Useful Developer Commands

- **Format code:** `dart format .`
- **Analyze the project:** `flutter analyze`
- **Run in development mode:** `flutter run`
- **Generate iOS configuration (SPM):** `flutter build ios --config-only`

---

## 🎨 Development Standards & Code Rules

To keep the project clean and parallel development simple, the following rules apply (see [AGENTS.md](AGENTS.md) for details):

### 1. Riverpod without code generation
* All providers are declared **manually** (`Provider`, `NotifierProvider`, `AsyncNotifierProvider`).
* Code generators (such as `build_runner` or `@riverpod`) are **strictly forbidden**. This prevents merge conflicts in generated `.g.dart` files.

### 2. Data model requirements
Every model must implement:
- A `copyWith` method, to keep state immutable.
- Overrides of `operator ==` and `hashCode` for value equality, which prevents unnecessary UI rebuilds.
- A `toString()` method for convenient logging and debugging.
- A constant initial value, `static const ... empty`.

### 3. UI rules
* **Reuse:** Use the shared components in `lib/core/widgets/` (e.g. `AppButton`, loaders, text fields).
* **Clean build methods:** Don't write large nested widget trees. If a file grows past 300–400 lines, extract sub-elements into separate `ConsumerWidget` / `StatelessWidget` classes in `presentation/widgets/`.
* **No business logic in the UI:** Widgets may only call controllers and fire simple UI triggers. All calculations, validation and formatting belong in controllers (`Controller`) or services (`Service`).
* **Modals:** All bottom sheets must be opened only through the shared utility method `AppModal.showBottomSheet`.

### 4. Navigation (GoRouter)
* **Decentralized:** Each page declares its route as a static `route` getter inside its own class. The main router (`lib/core/router/app_router.dart`) only imports and registers them.
* **Navigate by name:** Use `context.goNamed(...)` instead of raw string paths.
* **Authorization:** Access restrictions (Auth Guards) are configured reactively at the level of `GoRouter`'s own guards, without imperative checks inside screens.
