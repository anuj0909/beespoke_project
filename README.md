# StyleSwipe 🛍️

Flutter challenge submission for Beespoke Round 2 — built with GetX, `http`, and `sqflite`.

---

## 📁 Folder Structure (MVC)

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart        ← All colours in one place
│   │   └── app_styles.dart        ← Text styles, theme, decorations, spacing
│   ├── utils/
│   │   ├── logger.dart            ← Debug-only AppLogger (debug/info/warn/error)
│   │   └── validators.dart        ← URL validation, price/rating helpers, timeAgo
│   ├── services/
│   │   ├── api_service.dart       ← http-based network layer with typed errors
│   │   └── local_storage_service.dart ← sqflite CRUD for 3 tables
│   ├── routing/
│   │   └── app_router.dart        ← GetX named routes + transition definitions
│   └── bindings/
│       └── app_binding.dart       ← Registers all 3 controllers as permanents
│
├── models/                        ← M in MVC
│   ├── product.dart               ← fromJson / toMap / fromMap
│   ├── preference.dart            ← liked/disliked enum + SQLite serialisation
│   └── browsing_history_item.dart ← history entry + timeAgo / displayUrl
│
├── controllers/                   ← C in MVC
│   ├── product_controller.dart    ← API fetch, cache fallback, search, filter
│   ├── preference_controller.dart ← like/dislike toggle, SQLite persistence
│   └── browser_controller.dart    ← WebView lifecycle + URL history tracking
│
└── views/                         ← V in MVC
    ├── splash/
    │   └── splash_screen.dart     ← Animated splash, DB init
    ├── product_feed/
    │   ├── product_feed_screen.dart ← Grid, search, category chips
    │   └── widgets/
    │       ├── product_card.dart
    │       └── like_button.dart   ← LikeDislikeButtons + LikeButton variants
    ├── product_detail_webview/
    │   └── product_webview_screen.dart ← WebView + progress + nav bar
    ├── browsing_history/
    │   ├── browsing_history_screen.dart ← History list + swipe-to-delete
    │   └── widgets/
    │       └── history_tile.dart
    ├── preferences/
    │   └── preferences_screen.dart ← Liked/Disliked tabs
    └── shared/
        ├── loading_view.dart      ← Shimmer skeleton grid
        ├── error_view.dart        ← Error + retry
        └── empty_view.dart        ← Empty state with icon + CTA
```

---

## 🏗️ Architecture: MVC + GetX

- **Models** are pure Dart classes: `fromJson`, `toMap`, `fromMap`, no framework coupling.
- **Controllers** extend `GetxController`, hold reactive `.obs` state, call services.
- **Views** call `Get.find<Controller>()` and wrap reactive sections in `Obx(() => ...)`.
- **Services** are plain singletons (`ApiService.instance`, `LocalStorageService.instance`) — no GetX dependency, fully testable.
- `AppBinding` registers all three controllers as **permanent** so they survive route changes and share state app-wide.

---

## 🧠 State Management: GetX

**Why GetX?**

| Need | GetX solution |
|---|---|
| Reactive UI rebuilds | `.obs` + `Obx(() => ...)` — only the smallest widget rebuilds |
| Dependency injection | `Get.put()` / `Get.find()` — no BuildContext required |
| Navigation | `Get.toNamed('/route', arguments: data)` — clean, typed |
| Snackbars/dialogs | `Get.snackbar()` / `Get.defaultDialog()` — one liner |
| Controller lifecycle | `onInit()` / `onClose()` — automatic |

**Controller responsibilities:**

| Controller | Single Responsibility |
|---|---|
| `ProductController` | Fetch from API → cache fallback → search/filter |
| `PreferenceController` | Toggle liked/disliked → persist to SQLite → expose counts |
| `BrowserController` | Manage WebViewController → track page history → CRUD |

---

## 💾 Data Persistence: sqflite

**Why sqflite?**

- Structured, relational data needs per-row queries (e.g. "get preference for product 5")
- `UPSERT` semantics for preferences (same product can change state)
- `ORDER BY visitedAt DESC` for history
- Batch insert for product caching
- Trivially testable — `DatabaseHelper` is a singleton, easily mockable

**Three tables:**

```sql
products (id PK, title, price, description, category, image, rating, ratingCount, cachedAt)
preferences (productId PK, type INT, productTitle, productImage, productPrice, createdAt)
browsing_history (id AUTOINCREMENT, url, pageTitle, productId, productTitle, visitedAt)
```

---

## 📦 Dependencies

| Package | Version | Purpose |
|---|---|---|
| `get` | ^4.6.6 | State, DI, routing |
| `http` | ^1.2.1 | Network requests |
| `sqflite` + `path` | ^2.3.2 | SQLite storage |
| `webview_flutter` | ^4.7.0 | In-app browser |
| `cached_network_image` | ^3.3.1 | Image caching + placeholders |
| `shimmer` | ^3.0.0 | Skeleton loading |
| `flutter_animate` | ^4.5.0 | Entry animations |
| `google_fonts` | ^6.2.1 | Poppins typography |

---

## 🚀 Setup

```bash
git clone https://github.com/YOUR_USERNAME/styleswipe.git
cd styleswipe
flutter pub get
flutter run

# Release APK
flutter build apk --release
```

**Requirements:** Flutter 3.19+, Dart 3.0+, Android minSdkVersion 21

---

## 🔄 Data Flow

```
App launch
  → SplashScreen (2.2s) → LocalStorageService.instance.database (init SQLite)
  → ProductFeedScreen (AppBinding registers controllers)
  → ProductController.onInit() → API fetch → cache to SQLite on success
                               → load from SQLite on ApiException
  → PreferenceController.onInit() → load all preferences from SQLite into RxMap

User taps ❤️ on card
  → PreferenceController.like(product)
  → SQLite UPSERT (or DELETE if toggling off)
  → _preferenceMap[productId] updated → all Obx() watching isLiked(id) rebuild

User taps product card
  → Get.toNamed('/webview', arguments: {product})
  → BrowserController.initWebView() creates WebViewController
  → onPageFinished → JS title extraction → _recordHistory() → SQLite INSERT
  → historyItems.insert(0, item) → HistoryScreen Obx() rebuilds

User opens History tab
  → Reads historyItems RxList (already in memory from controller)
  → Swipe-to-dismiss → deleteHistoryItem → SQLite DELETE + list update
```

---

## ⚡ Error Handling

| Scenario | Behaviour |
|---|---|
| No internet on launch | Falls back to SQLite cache + snackbar |
| No cache + no internet | Error screen with retry button |
| `SocketException` | Caught in `ApiService._handleResponse()` → friendly message |
| `400/404/500` HTTP codes | Specific messages per status code |
| WebView load error | Snackbar with `error.description` |
| Empty search | Empty state with "Clear search" CTA |
| Empty liked/disliked tab | Empty state with "Browse Feed" CTA |

---

## ✅ What I Would Improve With More Time

1. **Product Detail screen** — a native Flutter detail page showing full description, rating breakdown, and "Add to Cart" mock before opening WebView
2. **Tinder-style swipe cards** — `flutter_card_swiper` + swipe right = like, swipe left = dislike
3. **Unit tests** — `ProductController`, `PreferenceController`, and `LocalStorageService` are all independently testable; would write 20+ tests
4. **Pagination** — FakeStoreAPI supports `?limit=` and `?offset=`; implement infinite scroll
5. **Dark mode** — `AppStyles.theme` is structured to easily add a `darkTheme`
6. **Proper product pages** — FakeStoreAPI doesn't serve browsable HTML per product; in production would use brand/retailer URLs or a rich Flutter detail page
7. **Image Hero animations** — `Hero` tag between feed card and webview header
8. **Search debounce** — 300ms `Timer` debounce to avoid filtering on every keystroke
9. **Offline indicator banner** — persistent banner when `isOffline.value == true`

---

## ⏱️ Time Spent

| Task | Time |
|---|---|
| Folder structure + pubspec | 20 min |
| Core: colors, styles, logger, validators | 40 min |
| ApiService (http) + LocalStorageService (sqflite) | 50 min |
| Models: Product, Preference, BrowsingHistoryItem | 30 min |
| Controllers: Product, Preference, Browser | 60 min |
| Views: Splash, Feed, WebView | 60 min |
| Views: History, Preferences, Shared widgets | 50 min |
| Routing + Binding | 20 min |
| README | 30 min |
| **Total** | **~6 hours** |

---

## 📬 Submission

Submitted to: viswas@beespoke.ai