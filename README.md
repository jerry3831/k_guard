# README


## Extracted Frontend Comments

The following descriptive comments were extracted from the `lib/` directory:

### `lib/core/constants/api_constants.dart`

```dart
// ── CHANGE THIS to match your environment ──────────────────────────
//
// Option A: Android emulator (most common during development)
```

```dart
//
// Option B: Physical device on same Wi-Fi as dev machine
```

```dart
//
// Option C: iOS simulator
```

```dart
//
// Option D: Production
```

```dart
// ───────────────────────────────────────────────────────────────────
```

```dart
// ── Scan history (PostgreSQL-backed) ─────────────────────────────────────
```

```dart
/// Returns the DELETE endpoint for a specific scan: DELETE /scans/:id
```

```dart
// ── Auth endpoints ─────────────────────────────────────────────────
```

```dart
// ── Scanner / scans endpoints ───────────────────────────────────────
```

```dart
// ── Timeout durations (used when building Dio in main.dart) ────────
// These are defined here so they are easy to adjust in one place.
```

### `lib/core/error/auth_exceptions.dart`

```dart
/// Base class for all authentication-related exceptions.
```

```dart
/// The device cannot reach the auth server.
```

```dart
/// The server rejected the credentials.
```

```dart
/// The email is already registered.
```

```dart
/// The account was not found.
```

```dart
/// The local session token has expired.
```

```dart
/// The server returned an unexpected error.
```

```dart
/// Thrown by datasources when INSERT violates a unique email constraint.
/// Maps to HTTP 409 from the PostgreSQL backend.
```

### `lib/core/error/exceptions.dart`

```dart
/// Base class for all scanner-related exceptions.
```

```dart
/// Thrown when the device cannot reach the server.
```

```dart
/// Thrown when the server returns a non-200 response.
```

```dart
/// Thrown when the user denies camera/storage permission.
```

### `lib/core/theme/app_colors.dart`

```dart
// ── Brand primary colors (From Image) ───────────────────────────────────
```

```dart
// ── Custom Dark Theme Colors (From Image) ────────────────────────────────
```

```dart
// ── Dashboard / History header ───────────────────────────────────────────
```

```dart
// ── Scan Currency button fill ────────────────────────────────────────────
```

```dart
// ── Scanner page (dark) ─────────────────────────────────────────────────
```

```dart
// ── Result page / general light background ───────────────────────────────
```

```dart
// ── Home / History page background ──────────────────────────────────────
// Slightly warm off-white — the body below the teal header
```

```dart
// ── Verdict colours ──────────────────────────────────────────────────────
```

```dart
// ── Text ─────────────────────────────────────────────────────────────────
```

```dart
// ── Misc ─────────────────────────────────────────────────────────────────
```

### `lib/core/utils/validators.dart`

```dart
/// Validates an email address.
///
/// Rules:
/// - The username part (before @) must not be purely numeric.
/// - The domain must be one of: gmail.com, yahoo.com, ac.mw, rbm.mw
```

```dart
// The negative lookahead (?!\d+@) ensures the local part is not all digits.
```

```dart
/// Validates a password.
///
/// Rules:
/// - At least 8 characters long
/// - At least one numeral (0-9)
/// - At least one symbol
```

### `lib/features/auth/data/datasources/auth_local_datasource.dart`

```dart
/// Fixed local datasource.
///
/// BUGS FIXED vs the previous version:
///
/// 1. SharedPreferences.getInstance() CALLED ON EVERY OPERATION
///    The old implementation called SharedPreferences.getInstance() inside
///    getCachedUser(), cacheUser(), clearCache(), getRememberMe(), and
///    setRememberMe() — five separate async calls per auth operation.
///    SharedPreferences.getInstance() reads from disk on first call and
///    can be slow. On some Android devices it blocks for 1–3 seconds.
///    Fixed by initialising once and caching the instance.
///
/// 2. NO TIMEOUT ON SharedPreferences.getInstance()
///    If the preferences file is corrupted or the platform channel is
///    busy, getInstance() can hang indefinitely. Fixed with a 5s timeout.
///
/// 3. EXCEPTION SWALLOWED IN getCachedUser()
///    The old code caught all exceptions and silently called clearCache().
///    If clearCache() itself throws (because getInstance() fails), that
///    exception would propagate uncaught and crash the app at startup.
///    Fixed with a try/catch around clearCache() as well.
```

```dart
// ── Singleton SharedPreferences instance ──────────────────────────
// Initialised once. All methods await this same Future.
```

```dart
// ── getCachedUser ────────────────────────────────────────────────
```

```dart
// Cache is unreadable or timed out — clear it so the user can re-login cleanly.
```

```dart
// clearCache failed too — preferences may be inaccessible.
```

```dart
// ── cacheUser ────────────────────────────────────────────────────
```

```dart
// This MUST propagate exceptions upward.
// If caching fails, AuthRepositoryImpl should know so it can handle
// it — not silently drop the error and leave the user on a loading screen.
```

```dart
// ── clearCache ───────────────────────────────────────────────────
```

```dart
// ── getRememberMe ─────────────────────────────────────────────────
```

```dart
// ── setRememberMe ─────────────────────────────────────────────────
```

### `lib/features/auth/data/datasources/auth_remote_datasource.dart`

```dart
/// All HTTP calls related to authentication.
/// Maps every possible server response and Dio error to a typed
/// [AuthException] so the repository never sees raw HTTP details.
///
/// BACKEND DATABASE (PostgreSQL):
///   The server behind these endpoints uses a PostgreSQL database with the
///   following table for user accounts:
///
///   CREATE TABLE users (
///     id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
///     full_name      VARCHAR(255) NOT NULL,
///     email          VARCHAR(255) UNIQUE NOT NULL,
///     password_hash  TEXT NOT NULL,    -- bcrypt via crypt()
///     avatar_url     TEXT,
///     created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

```dart
///
///   Password hashing is done server-side with bcrypt (pgcrypto extension).
///   The Flutter client NEVER handles raw password hashes — only plain-text
///   passwords over HTTPS, which the server hashes before storage.
```

```dart
// ── Sign in ─────────────────────────────────────────────────────────────
// SQL query on the PostgreSQL backend (Node/Django/Laravel/etc):
//
//   SELECT id, full_name, email, created_at, avatar_url
//   FROM users
//   WHERE email = $1
```

```dart
//
// The backend hashes the incoming password with bcrypt and compares it to
// the stored hash. It then issues a JWT and returns it alongside the user row.
//
// Expected response shape:
//   {
//     "user": { "id": "uuid", "full_name": "...", "email": "...",
//               "created_at": "ISO8601", "avatar_url": "..." },
//     "token": "eyJhbGciOi..."
//   }
```

```dart
// Return model with session token attached
```

```dart
// ── Register ─────────────────────────────────────────────────────────────
// SQL on the PostgreSQL backend:
//
//   INSERT INTO users (id, full_name, email, password_hash, created_at)
//   VALUES (gen_random_uuid(), $1, $2, crypt($3, gen_salt('bf')), NOW())
```

```dart
//
// 'bf' = bcrypt with default cost 10. The plain-text password NEVER touches
// the database — only the bcrypt hash is stored.
//
// Expected response shape (201 Created):
//   {
//     "user": { "id": "uuid", "full_name": "...", "email": "...",
//               "created_at": "ISO8601" },
//     "token": "eyJhbGciOi..."
//   }
```

```dart
// ── Forgot password ───────────────────────────────────────────────────────
// SQL on the PostgreSQL backend:
//
//   INSERT INTO password_reset_tokens (user_id, token, expires_at)
//   SELECT id, encode(gen_random_bytes(32), 'hex'), NOW() + INTERVAL '1 hour'
//   FROM users WHERE email = $1
//   ON CONFLICT (user_id) DO UPDATE
```

```dart
//
// The backend emails this token to the user. When the user clicks the link:
//
//   UPDATE users SET password_hash = crypt($new_password, gen_salt('bf'))
//   WHERE id = (
//     SELECT user_id FROM password_reset_tokens
//     WHERE token = $token AND expires_at > NOW()
```

```dart
// We return void regardless of whether the email was found —
// this is intentional to prevent email enumeration attacks.
```

```dart
// ── Sign out ──────────────────────────────────────────────────────────────
// SQL on the PostgreSQL backend (token blacklist table):
//
//   INSERT INTO revoked_tokens (token, revoked_at)
```

```dart
//
// Alternatively, if using short-lived JWTs (≤15 min) with refresh tokens:
//
```

```dart
// Sign-out errors are non-fatal — the local session is cleared
// regardless of whether the server call succeeds.
```

```dart
// ── Delete Account ────────────────────────────────────────────────────────
```

```dart
// ── Change password ───────────────────────────────────────────────────────
```

```dart
// ── Error mapping ─────────────────────────────────────────────────────────
```

### `lib/features/auth/data/datasources/auth_sqlite_datasource.dart`

```dart
/// Cross-platform SQLite datasource.
///
/// CHANGE FROM PREVIOUS VERSION — DATABASE PATH RESOLUTION:
///
/// The previous version called getDatabasesPath() unconditionally.
/// That function is implemented by the sqflite Android/iOS plugin and
/// returns the correct app-private database directory on mobile.
///
/// On Linux/Windows/macOS, getDatabasesPath() is provided by
/// sqflite_common_ffi and returns the current working directory by
/// default — which is fine for a POC but can vary by launch context.
///
/// This version uses a helper that:
///   • On Android/iOS  → getDatabasesPath()  (unchanged behaviour)
///   • On Linux        → ~/.local/share/currencyguard/  (XDG standard)
///   • On Windows      → %APPDATA%\currencyguard\
///   • On macOS        → ~/Library/Application Support/currencyguard/
///
/// This makes the database location predictable and persistent across
/// runs regardless of which directory the app is launched from.
```

```dart
// ── Singleton with Completer lock ────────────────────────────────────
```

```dart
// ── Cross-platform path resolution ────────────────────────────────────
```

```dart
/// Returns the directory where the database file should be stored,
/// creating it if it does not already exist.
```

```dart
// Mobile: use sqflite's built-in path (app-private data directory)
```

```dart
// Desktop: use a platform-appropriate application data directory
```

```dart
// XDG Base Directory spec: ~/.local/share/<app>
```

```dart
// Windows: %APPDATA%\currencyguard
```

```dart
// macOS: ~/Library/Application Support/currencyguard
```

```dart
// Fallback: current working directory
```

```dart
// Create the directory if it does not exist
```

```dart
// ── Database open ─────────────────────────────────────────────────────
```

```dart
// Future migrations: if (oldVersion < 2) { ... }
```

```dart
// ── Password hashing ──────────────────────────────────────────────────
```

```dart
// ── createUser ────────────────────────────────────────────────────────
```

```dart
// ── getUserByEmail ────────────────────────────────────────────────────
```

```dart
// ── Helpers ───────────────────────────────────────────────────────────
```

```dart
/// Typed exception so AuthRepositoryImpl can map it precisely.
```

### `lib/features/auth/data/models/app_user_model.dart`

```dart
/// Data-layer model for the SQLite proof-of-concept.
///
/// KEY DIFFERENCE FROM THE REMOTE VERSION:
///   [passwordHash] is added here so the repository can verify the
///   password without exposing it to the domain layer.
///   The domain [AppUser] never carries the hash — only this model does.
```

```dart
// ── Remote API JSON → model ──────────────────────────────────────────────
// Called when parsing the PostgreSQL-backed REST API response.
// Expected JSON shape:
//   { "id": "uuid", "full_name": "...", "email": "...",
//     "created_at": "ISO8601", "avatar_url": "..." }
```

```dart
// ── SQLite row → model (legacy — kept for reference) ────────────────────
// Was used when auth was backed by local SQLite.
```

```dart
// ── SharedPreferences cache ───────────────────────────────────────────────
```

```dart
// Password hash is NEVER persisted to SharedPreferences
```

```dart
// passwordHash intentionally excluded — never cache it
```

### `lib/features/auth/data/repositories/auth_repository_impl.dart`

```dart
/// AuthRepositoryImpl backed by a PostgreSQL REST API.
///
/// ARCHITECTURE:
///   _remote  → Dio-based datasource that talks to the PostgreSQL backend
///   _local   → SharedPreferences cache for persisting the session locally
///
/// FLOW:
///   register() / signIn()  → call _remote → cache result in _local
///   getCurrentUser()       → read from _local (offline-capable)
///   signOut()              → call _remote to revoke token → clear _local
///
/// OFFLINE FALLBACK:
///   If the remote call fails with AuthNetworkException and a cached session
///   exists, signIn() returns the cached user. This allows the app to remain
///   usable when the server is temporarily unreachable.
```

```dart
// ── Register ─────────────────────────────────────────────────────
```

```dart
// 1. Create the user via the PostgreSQL-backed REST API
//    Server-side SQL:
//      INSERT INTO users (id, full_name, email, password_hash, created_at)
//      VALUES (gen_random_uuid(), $1, $2, crypt($3, gen_salt('bf')), NOW())
```

```dart
// 2. Cache session — non-fatal: user was created on the server.
//    If caching is slow or fails, return immediately.
```

```dart
// ── Sign in ──────────────────────────────────────────────────────
```

```dart
// Call the PostgreSQL-backed REST API
//   Server-side SQL:
//     SELECT id, full_name, email, created_at, avatar_url
//     FROM users
//     WHERE email = $1
```

```dart
// Network failure — try the cached session as a fallback.
// Guard against slow local storage by timing out the cached read.
```

```dart
// No cached session with matching email — rethrow the network error
```

```dart
// Same offline fallback as AuthNetworkException.
```

```dart
// Cache the session (token is already embedded in the model).
// Do not let a slow SharedPreferences write block login.
```

```dart
// ── Sign in as Guest ──────────────────────────────────────────────
```

```dart
// We should NOT cache the guest session locally.
// Guest sessions should be ephemeral so that the next time the app launches,
// the user is shown the landing page.
```

```dart
// ── Forgot password ───────────────────────────────────────────────
```

```dart
// Delegates to the PostgreSQL-backed REST API
//   Server-side SQL:
//     INSERT INTO password_reset_tokens (user_id, token, expires_at)
//     SELECT id, encode(gen_random_bytes(32), 'hex'), NOW() + INTERVAL '1 hour'
//     FROM users WHERE email = $1
//     ON CONFLICT (user_id) DO UPDATE
```

```dart
// ── Sign out ──────────────────────────────────────────────────────
```

```dart
// 1. Attempt to revoke the token on the server
//    Server-side SQL:
//      INSERT INTO revoked_tokens (token, revoked_at)
```

```dart
// Server-side revocation is best-effort — sign-out proceeds
```

```dart
// 2. Clear local session regardless of server response
```

```dart
// Call remote data source to delete the account
```

```dart
// Clear the local session just like sign out
```

```dart
// ── getCurrentUser ────────────────────────────────────────────────
```

```dart
// ── getCurrentUser ────────────────────────────────────────────────
```

```dart
// If the cached user is a guest, clear the cache and return null.
// Guest sessions should not persist across app restarts.
```

```dart
// ── persistSession / clearSession ────────────────────────────────
```

```dart
// ── Dev logging helper ────────────────────────────────────────────
```

```dart
// Replace with a proper logger in production (e.g. package:logger)
```

### `lib/features/auth/domain/entities/app_user.dart`

```dart
/// Represents the authenticated user within the domain layer.
/// Pure Dart — no framework or serialization dependencies here.
```

```dart
/// Display-friendly first name only.
```

### `lib/features/auth/domain/repositories/auth_repository.dart`

```dart
/// Contract that every auth backend (REST + SQL, Firebase, mock) must satisfy.
/// The BLoC only ever calls methods on this interface — it never touches Dio,
/// SQLite, or SharedPreferences directly.
```

```dart
/// Signs in with [email] and [password].
/// Returns the authenticated [AppUser] on success.
/// Throws [AuthException] on failure.
```

```dart
/// Signs in automatically as a guest.
/// Returns the generated guest [AppUser].
```

```dart
/// Registers a new account.
/// Returns the newly created [AppUser] on success.
```

```dart
/// Sends a password-reset email/OTP to [email].
```

```dart
/// Signs out the current user and clears any persisted session.
```

```dart
/// Deletes the current user's account and all associated data.
```

```dart
/// Changes the current user's password.
```

```dart
/// Returns the currently authenticated user from the local session,
/// or null if no session exists.
```

```dart
/// Persists [rememberMe] preference and session token to local storage.
```

```dart
/// Clears all locally persisted auth data.
```

### `lib/features/auth/domain/usecases/auth_usecases.dart`

```dart
// ─── SignInUseCase ────────────────────────────────────────────────────────────
```

```dart
// ─── SignInAsGuestUseCase ─────────────────────────────────────────────────────
```

```dart
// ─── RegisterUseCase ──────────────────────────────────────────────────────────
```

```dart
// ─── ForgotPasswordUseCase ────────────────────────────────────────────────────
```

```dart
// ─── SignOutUseCase ───────────────────────────────────────────────────────────
```

```dart
// ─── DeleteAccountUseCase ────────────────────────────────────────────────────
```

```dart
// ─── GetCurrentUserUseCase ────────────────────────────────────────────────────
```

```dart
// ─── ChangePasswordUseCase ────────────────────────────────────────────────────
```

```dart
// ─── Shared validators ────────────────────────────────────────────────────────
```

### `lib/features/auth/presentation/providers/auth_bloc.dart`

```dart
/// Fixed AuthBloc.
///
/// BUGS FIXED vs the previous version:
///
/// 1. NO TIMEOUT — STUCK IN AuthLoading FOREVER
///    If any use case awaits a Future that never completes (e.g. SQLite
///    or SharedPreferences hanging), the BLoC stays in AuthLoading
///    indefinitely — the spinner runs forever.
///    Fixed: every handler wraps its use case call in a 15-second timeout.
///    On timeout, AuthFailure(isOffline: true) is emitted so the user
///    sees a clear message and can retry.
///
/// 2. ArgumentError FROM USE CASE NOT MAPPED TO AuthFailure(isOffline:false)
///    RegisterUseCase and SignInUseCase throw ArgumentError for validation
///    failures (empty name, password mismatch, invalid email). The old
///    catch chain had `on ArgumentError` but it was AFTER `catch (_)` in
///    some compiler orderings, meaning validation errors showed as generic
///    "An unexpected error occurred." Fixed by ensuring ArgumentError is
///    caught explicitly before the generic catch.
///
/// 3. AuthAppStarted EMITS AuthLoading BEFORE getCurrentUser()
///    This was unnecessary — users saw a flash of the loading spinner on
///    every app launch even when no async work had started. Changed to
///    emit AuthChecking (which shows the splash) and only emit
///    AuthLoading when an actual network/DB operation is in progress.
///
/// 4. LISTENER REBUILDS MISSING AuthAuthenticated WHEN WRAPPED IN BlocBuilder
///    The RegisterScreen and LoginScreen use BlocConsumer (builder +
///    listener). When AuthLoading is emitted the builder rebuilds —
///    if the widget tree is rebuilt mid-transition, the listener can
///    miss the AuthAuthenticated state. Fixed by using BlocConsumer
///    correctly: listenWhen ensures we only navigate on AuthAuthenticated,
///    and buildWhen excludes navigation states from triggering rebuilds.
```

```dart
// Maximum time any single auth operation may take before we give up
```

```dart
// ── AuthAppStarted ───────────────────────────────────────────────
```

```dart
// Stay in AuthChecking (splash) while we read the local session.
// Do NOT emit AuthLoading here — it would show the spinner on
// every cold launch, even when session read takes <100ms.
```

```dart
// Any error reading the session → show login screen
```

```dart
// ── AuthSignInRequested ──────────────────────────────────────────
```

```dart
// ── AuthGuestSignInRequested ─────────────────────────────────────
```

```dart
// ── AuthRegisterRequested ────────────────────────────────────────
```

```dart
// ── AuthForgotPasswordRequested ──────────────────────────────────
```

```dart
// ── AuthSignOutRequested ─────────────────────────────────────────
```

```dart
// Sign out must always succeed from the user's perspective.
// If clearing the session fails, we still navigate to login.
```

```dart
// ── AuthDeleteAccountRequested ───────────────────────────────────
```

```dart
// ── AuthChangePasswordRequested ──────────────────────────────────
```

### `lib/features/auth/presentation/providers/auth_event.dart`

```dart
/// App launched — check for an existing local session.
```

```dart
/// Request to permanently delete the current user's account.
```

### `lib/features/auth/presentation/providers/auth_state.dart`

```dart
/// Splash screen — checking for a persisted session.
```

```dart
/// No session found or user signed out.
```

```dart
/// A network/form operation is in progress.
```

```dart
/// Successfully authenticated.
```

```dart
/// True when the user was restored from local cache (offline mode).
```

```dart
/// An operation failed.
```

```dart
/// True when the failure was caused by no internet connection.
```

```dart
/// Password-reset email sent successfully.
```

### `lib/features/auth/presentation/screens/forgot_password_screen.dart`

```dart
/// Two-step forgot password screen:
///   Step 1 — email entry
///   Step 2 — confirmation that the reset email was sent
///
/// Designed to match the CurrencyGuard teal/white aesthetic.
```

```dart
// ── Confirmation view ──────────────────────────────────────────
```

```dart
// ── Email entry view ───────────────────────────────────────────
```

```dart
// Teal header with back button
```

```dart
// Error / offline banner
```

```dart
// ─── Confirmation view ────────────────────────────────────────────────────────
```

```dart
// Success icon
```

```dart
// Resend option — fires a new BLoC event
```

### `lib/features/auth/presentation/screens/landing_screen.dart`

```dart
// ── Top Row (Logo & Sign In) ──────────────────────────────────
```

```dart
// ── Center Content ────────────────────────────────────────────
// Sizable shield with bold MK and checkmark badge
```

```dart
// Thematic background dots - varying sizes and opacities
```

```dart
// Extra dots for more density
```

```dart
// Shield
```

```dart
// Golden mk
```

```dart
// Top right checkmark badge
```

```dart
// Headline text
```

```dart
// Subtitle
```

```dart
// ── Bottom Action Buttons ─────────────────────────────────────
```

```dart
// Organic floating distance (-15 to 15 pixels)
```

```dart
// Randomize starting position
```

```dart
// Map 0.0 - 1.0 to -1.0 - 1.0 for full range of motion
```

### `lib/features/auth/presentation/screens/login_screen.dart`

```dart
/// Fixed LoginScreen — same BlocConsumer corrections as RegisterScreen.
```

### `lib/features/auth/presentation/screens/register_screen.dart`

```dart
/// Fixed RegisterScreen.
///
/// BUGS FIXED vs the previous version:
///
/// 1. BlocListener WRAPPED INSIDE BlocBuilder — MISSED TRANSITIONS
///    The original used BlocConsumer, which is correct, BUT the listener
///    only fired on `AuthAuthenticated`. When `AuthLoading` was emitted,
///    BlocBuilder rebuilt the entire widget tree. This can cause the
///    BlocListener subscription to be briefly interrupted on some Flutter
///    versions, causing it to miss the immediately following
///    `AuthAuthenticated` emission.
///
///    Fix: use `listenWhen` and `buildWhen` to cleanly separate concerns:
///      - `buildWhen`: only rebuilds the form UI for Loading/Failure states
///      - `listenWhen`: only triggers navigation logic for Authenticated
///    This ensures the listener is never rebuilt while the authenticated
///    state is being emitted.
///
/// 2. FORM STAYS SUBMITTABLE DURING AuthLoading
///    The old button checked `isLoading` but the TextFields remained
///    enabled. A user could edit fields and tap Create Account multiple
///    times while the DB was working, dispatching duplicate events.
///    Fixed: ignore all form interactions while AuthLoading is active.
///
/// 3. NO ERROR CLEARED ON RETRY
///    If a registration failed with AuthFailure, the error banner stayed
///    visible. If the user corrected their input and resubmitted, the
///    banner disappeared only after the next AuthLoading emission — but
///    on fast devices this caused a flicker. Fixed with explicit state
///    transition handling in buildWhen.
```

```dart
// ── listenWhen: only care about navigation-triggering states ───
```

```dart
// Replace entire stack — user should not be able to back into
// registration after successfully creating an account.
```

```dart
// ── buildWhen: rebuild form for loading/failure/initial only ───
```

```dart
// Teal header
```

```dart
// Error banner — only shown on AuthFailure
```

```dart
// Terms checkbox
```

### `lib/features/auth/presentation/screens/registration_success_screen.dart`

```dart
// App Name
```

```dart
// Success Icon
```

```dart
// Success Text
```

```dart
// Sign In Button
```

### `lib/features/auth/presentation/widgets/auth_widgets.dart`

```dart
// ─── Teal header shared by all auth screens ───────────────────────────────────
```

```dart
// Shield logo
```

```dart
// ─── White card body container ────────────────────────────────────────────────
```

```dart
// ─── Labelled text field ──────────────────────────────────────────────────────
```

```dart
// ─── Primary teal button ──────────────────────────────────────────────────────
```

```dart
// ─── Error banner ─────────────────────────────────────────────────────────────
```

### `lib/features/history/data/repositories/scan_history_repository_impl.dart`

```dart
/// Delegates scan history operations to:
///   _scanRepo       — for reading scan history (which now hits PostgreSQL)
///   _historyRemote  — for delete operations directly against the backend
///
/// Server-side PostgreSQL table:
///   scan_history (id, user_id, denomination, currency_code, ...)
```

```dart
/// Permanently removes a scan from the PostgreSQL backend.
///
/// Server-side SQL:
///   DELETE FROM scan_history
```

### `lib/features/history/domain/repositories/scan_history_repository.dart`

```dart
/// Contract for reading and mutating scan history.
/// Implemented once in the data layer and shared across features.
```

```dart
/// Returns all scans, newest first.
```

```dart
/// Permanently removes the scan with [id] from storage.
```

### `lib/features/history/domain/usecases/delete_scan_usecase.dart`

```dart
/// Permanently removes a single scan from history by its id.
```

### `lib/features/history/domain/usecases/get_scan_history_usecase.dart`

```dart
/// Fetches the complete scan history from the repository.
```

### `lib/features/history/presentation/providers/history_bloc.dart`

```dart
/// Manages the full lifecycle of the history screen:
///   Initial → Loading → LoadSuccess (filter/search applied reactively)
///
/// Filtering and searching are done in-memory — no extra network calls.
/// The BLoC holds the full list and re-derives [displayedScans] on every
/// filter or search change, keeping the UI perfectly in sync.
```

```dart
// ─── Event handlers ──────────────────────────────────────────────────────
```

```dart
// Preserve current filter/search during refresh.
```

```dart
// Deletion failed silently — keep current state intact.
```

```dart
// ─── Helpers ─────────────────────────────────────────────────────────────
```

```dart
/// Applies [filter] then [query] to [all]. Pure function — no side effects.
```

```dart
// Step 1 — verdict filter
```

```dart
// Step 2 — text search (currency label OR serial number)
```

### `lib/features/history/presentation/providers/history_event.dart`

```dart
/// Fired on screen init and pull-to-refresh.
```

```dart
/// User typed in the search bar.
```

```dart
/// User tapped a filter tab.
```

```dart
/// User pulled down to refresh.
```

```dart
/// User deleted a single scan entry.
```

```dart
/// Maps filter to the verdict it accepts, or null for "all".
```

### `lib/features/history/presentation/providers/history_state.dart`

```dart
/// The full unfiltered list, kept for re-filtering without another fetch.
```

```dart
/// The list after applying [activeFilter] and [searchQuery].
```

```dart
/// Aggregate counts always derived from the full list.
```

### `lib/features/history/presentation/screens/history_screen.dart`

```dart
/// Redesigned history screen matching the Figma design:
///
///  - Same dashboardTeal header as HomeScreen
///  - "Scan History" title + subtitle
///  - Four FULL-WIDTH stat chips: Total | Valid | Suspect | Fake
///    They span the entire header width with equal flex
///  - White search bar pinned below header
///  - Horizontal filter tabs
///  - Scan list items (no outer card — matches Figma)
///  - MWK currency throughout
```

```dart
// ── Teal header ───────────────────────────────────────────
```

```dart
// ── Sticky search bar ─────────────────────────────────────
```

```dart
// ── Filter tabs ───────────────────────────────────────────
```

```dart
// ── List ──────────────────────────────────────────────────
```

```dart
// ─── Header ────────────────────────────────────────────────────────────────
```

```dart
// ── Full-width stat chips row ────────────────────────────────
// Uses Expanded inside a Row so all four chips share width equally,
// spanning the full header width. Matches Figma precisely.
```

```dart
// ─── Sliver list ───────────────────────────────────────────────────────────
```

```dart
// ─── Full-width stat chip ─────────────────────────────────────────────────────
// Semi-transparent teal tile, label on top, value below — spans equal width.
```

```dart
// ─── History scan row ─────────────────────────────────────────────────────────
// White card per item with swipe-to-delete. Shows MWK denomination.
```

```dart
// Verdict icon
```

```dart
// Label + serial
```

```dart
// MWK denomination
```

```dart
// Verdict badge
```

```dart
// Date/time + confidence bar
```

```dart
// Confidence bar
```

```dart
// ─── Verdict badge ────────────────────────────────────────────────────────────
```

```dart
// ─── Sticky search bar delegate ───────────────────────────────────────────────
```

```dart
// ─── Empty + error views ──────────────────────────────────────────────────────
```

```dart
// ─── Bottom nav (reused from home) ───────────────────────────────────────────
```

### `lib/features/history/presentation/widgets/history_filter_tabs.dart`

```dart
/// Horizontally scrollable filter tab row matching the Figma design.
/// The active tab is rendered as a filled teal pill; inactive tabs are
/// plain text with no background.
```

### `lib/features/history/presentation/widgets/history_scan_card.dart`

```dart
/// A single scan card in the history list. Matches the Figma design:
/// - Left: verdict icon circle
/// - Centre: currency label, serial number, date/time row
/// - Right: verdict badge + confidence bar
/// Supports swipe-to-delete via [onDismissed].
```

```dart
// ── Top row: icon + label + badge ───────────────────────────
```

```dart
// Verdict icon
```

```dart
// Currency label + serial
```

```dart
// Verdict badge chip
```

```dart
// ── Bottom row: date/time + confidence bar ──────────────────
```

```dart
// Confidence bar + label
```

```dart
// ─── Verdict badge ────────────────────────────────────────────────────────────
```

### `lib/features/history/presentation/widgets/history_stats_bar.dart`

```dart
/// The four compact stat chips displayed inside the teal header:
/// Total · Valid · Suspect · Fake
```

### `lib/features/home/data/repositories/history_repository_impl.dart`

```dart
/// Derives dashboard stats from the shared scan history managed by
/// [ScanRepositoryImpl].  In production, replace with Hive/SQLite queries.
```

### `lib/features/home/domain/entities/dashboard_stats.dart`

```dart
/// A lightweight snapshot of the user's scan statistics shown on the home page.
```

### `lib/features/home/domain/repositories/history_repository.dart`

```dart
/// Contract for accessing historical scan data.
/// Implemented in the data layer; shared between home and history features.
```

### `lib/features/home/domain/usecases/get_dashboard_stats_usecase.dart`

```dart
/// Aggregates scan history into a single [DashboardStats] snapshot.
```

### `lib/features/home/domain/usecases/get_recent_scans_usecase.dart`

```dart
/// Returns the N most recent scans for the dashboard feed.
```

### `lib/features/home/presentation/providers/home_event.dart`

```dart
/// Fired on screen init and on pull-to-refresh.
```

```dart
/// Fired when the user pulls down to refresh.
```

### `lib/features/home/presentation/providers/home_state.dart`

```dart
// userName is no longer stored here — the HomeScreen reads it directly
// from AuthBloc so it always reflects the live auth state.
```

### `lib/features/home/presentation/screens/home_screen.dart`

```dart
// Matched from the design image
```

```dart
// ── Teal header + overlapping cards ──────────────────────
```

```dart
// ── Recent Scans section ──────────────────────────────────
```

```dart
// Teal background with rounded bottom corners
```

```dart
// Content
```

```dart
// Theme toggle button
```

```dart
// User profile image (implemented as an initials avatar)
```

```dart
// Decorative background shapes removed as requested
// Content
```

```dart
// Section header row
```

```dart
// Scan rows
```

```dart
// Icon in soft square
```

```dart
// Label
```

```dart
// Value
```

### `lib/features/home/presentation/widgets/recent_scan_item.dart`

```dart
/// A single scan row in the "Recent Scans" list on the home page.
```

```dart
// Verdict icon
```

```dart
// Currency info
```

```dart
// Timestamp
```

### `lib/features/home/presentation/widgets/stats_card.dart`

```dart
/// One card in the 2×2 stats grid on the home page.
```

```dart
// Using a distinct, much lighter blue to ensure it stands out clearly
// against the dark header (AppColors.darkBlueSurface).
```

### `lib/features/scanner/data/datasources/scan_history_remote_datasource.dart`

```dart
/// Remote datasource for persisting scan history to the PostgreSQL backend.
///
/// BACKEND DATABASE (PostgreSQL):
///   The server stores scan results in the following table:
///
///   CREATE TABLE scan_history (
///     id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
///     user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
///     denomination        TEXT NOT NULL,
///     currency_code       TEXT NOT NULL DEFAULT 'MWK',
///     confidence_score    DOUBLE PRECISION NOT NULL,
///     verdict             TEXT NOT NULL CHECK (verdict IN ('authentic','suspicious','counterfeit')),
///     serial_number       TEXT NOT NULL,
///     verification_source TEXT NOT NULL DEFAULT 'Cloud ResNet-50',
///     image_url           TEXT,
///     scanned_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

```dart
///
///   The user_id is resolved server-side from the JWT Bearer token.
///   The client never sends user_id explicitly — the server extracts it
///   from the authenticated session.
```

```dart
/// Persists a completed scan to the backend.
```

```dart
/// Returns all scans for the authenticated user, newest first.
```

```dart
/// Permanently removes a scan by its id.
```

```dart
// ── saveScan ─────────────────────────────────────────────────────────────
// SQL on the PostgreSQL backend:
//
//   INSERT INTO scan_history
//     (id, user_id, denomination, currency_code, confidence_score,
//      verdict, serial_number, verification_source, image_url, scanned_at)
```

```dart
// ── getScanHistory ───────────────────────────────────────────────────────
// SQL on the PostgreSQL backend:
//
//   SELECT id, denomination, currency_code, confidence_score,
//          verdict, serial_number, verification_source,
//          image_url, scanned_at
//   FROM scan_history
//   WHERE user_id = $jwt_user_id
```

```dart
//
// Expected response shape:
//   {
//     "scans": [
//       { "id": "uuid", "denomination": "500", "currency_code": "MWK",
//         "confidence_score": 0.98, "verdict": "authentic",
//         "serial_number": "MK7f2a...", "timestamp": "ISO8601",
//         "verification_source": "Cloud ResNet-50",
//         "image_local_path": null },
//       ...
//     ]
//   }
```

```dart
// ── deleteScan ───────────────────────────────────────────────────────────
// SQL on the PostgreSQL backend:
//
//   DELETE FROM scan_history
```

```dart
//
// The AND user_id clause ensures users can only delete their own scans.
```

```dart
// ── Error mapping ─────────────────────────────────────────────────────────
```

### `lib/features/scanner/data/datasources/scan_remote_datasource.dart`

```dart
/// Sends the image to the remote ML inference endpoint and returns a parsed
/// [CurrencyNoteModel].  All Dio-specific code is isolated here so the rest
/// of the app never imports Dio directly.
```

### `lib/features/scanner/data/models/currency_note_model.dart`

```dart
/// Data-layer model: extends [CurrencyNote] and adds JSON (de)serialization.
/// The ML backend is expected to return a payload matching [fromJson].
```

```dart
/// Convert a domain [CurrencyNote] entity to a model for persistence.
/// Used when saving a scan result to the PostgreSQL backend.
```

```dart
// Server returns a value between 0 and 1
```

### `lib/features/scanner/data/repositories/scan_repository_impl.dart`

```dart
/// Concrete implementation of [ScanRepository].
/// Coordinates between:
///   _remoteDataSource   — ML inference endpoint (sends image, gets prediction)
///   _historyDataSource  — PostgreSQL-backed scan history (CRUD operations)
///
/// All exceptions from datasources are caught here and re-thrown as domain
/// [ScanException]s so the BLoC never has to know about Dio or HTTP.
```

```dart
/// Persists a completed scan to the PostgreSQL backend.
///
/// Server-side SQL:
///   INSERT INTO scan_history
///     (id, user_id, denomination, currency_code, confidence_score,
///      verdict, serial_number, verification_source, image_url, scanned_at)
```

```dart
/// Returns the full scan history from PostgreSQL, newest first.
///
/// Server-side SQL:
///   SELECT * FROM scan_history
///   WHERE user_id = $jwt_user_id
```

### `lib/features/scanner/domain/entities/currency_note.dart`

```dart
/// Represents the result of a scanned currency note.
/// Pure Dart — no framework dependencies.
```

```dart
// currencyCode is kept for data integrity but display always uses MWK
// since this is a Malawian Kwacha detection application.
```

```dart
/// Display label always shows MWK for Malawian Kwacha.
/// e.g. "MWK 500" or "MWK 1,000"
```

```dart
/// Confidence as a percentage string, e.g. "99.8%"
```

```dart
/// Shortened serial for display, e.g. "MK7f2a...8E5"
```

### `lib/features/scanner/domain/repositories/scan_repository.dart`

```dart
/// The contract that both the remote API datasource and any local/mock
/// datasource must satisfy.  The BLoC only ever talks to this interface.
```

```dart
/// Sends [imageFiles] to the ML backend and returns a [CurrencyNote] result.
/// Throws a [ScanException] on network or server errors.
```

```dart
/// Persists a completed scan to local storage / remote history.
```

```dart
/// Returns the full scan history, newest first.
```

### `lib/features/scanner/domain/usecases/perform_scan_usecase.dart`

```dart
/// Single-responsibility use case: takes an image file, delegates to the
/// repository, and returns the result.  Contains zero UI or framework code.
```

### `lib/features/scanner/presentation/providers/scanner_bloc.dart`

```dart
/// Orchestrates the full scanner flow:
///   Idle → Analyzing → Success | Failure
///             ↑                      ↓
///           Reset ←──────────────────┘
///
/// Dependencies are injected so the bloc is unit-testable without any
/// Flutter widgets or real network calls.
```

```dart
// ─── Event Handlers ──────────────────────────────────────────────────────
```

```dart
// Revert to success — saving failed but the result is still valid.
```

```dart
// ─── Helpers ─────────────────────────────────────────────────────────────
```

### `lib/features/scanner/presentation/providers/scanner_event.dart`

```dart
/// All events that can be dispatched to [ScannerBloc].
```

```dart
/// User tapped the shutter button — [imageFile] is the captured photo.
```

```dart
/// User picked an image from their gallery / file manager.
```

```dart
/// User removed an image from the staging area.
```

```dart
/// User wants to clear all staged images.
```

```dart
/// User requested to start inference on all staged images.
```

```dart
/// User confirmed saving the result to history.
```

```dart
/// User dismissed the result and wants to scan again.
```

```dart
/// Camera flip button tapped.
```

```dart
/// Auto-focus button tapped.
```

### `lib/features/scanner/presentation/providers/scanner_state.dart`

```dart
/// All states that [ScannerBloc] can be in.
/// Each state is immutable and carries only the data its UI subtree needs.
```

```dart
/// The camera preview is live and waiting for the user to act.
```

```dart
/// The server returned a result — show the ResultCard.
```

```dart
/// Something went wrong — show an error overlay.
```

```dart
/// The save-to-history operation is in progress.
```

### `lib/features/scanner/presentation/screens/scan_result_screen.dart`

```dart
/// Result screen. Receives a [CurrencyNote] via route arguments.
/// All monetary amounts displayed as MWK (Malawian Kwacha).
```

```dart
// Verified chip
```

```dart
// Authentication details — MWK denomination
```

```dart
// Add to History button
```

```dart
// Denomination shown as MWK
```

### `lib/features/scanner/presentation/screens/scan_screen.dart`

```dart
/// The main scanner screen. Matches the Figma dark-themed design:
/// - Full-screen camera preview as background
/// - Teal corner-bracket viewfinder centred on screen
/// - "Position currency within frame" hint bubble
/// - Flip / Focus / Auto control row
/// - Large teal capture button + upload button
/// - Bottom navigation bar (Scan tab active)
```

```dart
// Lock orientation to portrait for consistent framing.
```

```dart
// Navigate to the result screen, passing the result.
```

```dart
// ── 1. Camera preview (full bleed) ──────────────────────────
```

```dart
// ── 2. Dark gradient vignette ───────────────────────────────
```

```dart
// ── 3. Viewfinder + hint ────────────────────────────────────
```

```dart
// ── 4. Controls at the bottom ───────────────────────────────
```

```dart
// ── 5. Loading overlay while analyzing ──────────────────────
```

```dart
// ─── AppBar ──────────────────────────────────────────────────────────────
```

```dart
// ─── Camera preview ──────────────────────────────────────────────────────
```

```dart
// ─── Viewfinder ──────────────────────────────────────────────────────────
```

```dart
// Hint bubble
```

```dart
// ─── Bottom controls ─────────────────────────────────────────────────────
```

```dart
// Upload + Shutter row
```

```dart
// Upload button
```

```dart
// Main shutter button
```

```dart
// Assess or placeholder
```

```dart
// ─── Analyzing overlay ───────────────────────────────────────────────────
```

```dart
// ─── Bottom nav ──────────────────────────────────────────────────────────
```

```dart
// ─── Small private widgets ────────────────────────────────────────────────────
```

### `lib/features/scanner/presentation/widgets/camera_overlay.dart`

```dart
/// Paints the four teal corner brackets visible in the Figma scanner design.
/// Rendered on top of the camera preview using a [CustomPaint].
```

```dart
// Top-left
```

```dart
// Top-right
```

```dart
// Bottom-left
```

```dart
// Bottom-right
```

```dart
// Horizontal arm
```

```dart
// Rounded corner
```

```dart
// Vertical arm
```

### `lib/features/scanner/presentation/widgets/result_card.dart`

```dart
/// The hero card displayed at the top of the result screen.
/// Shows the verdict banner, icon, and a "Verified in Cloud" chip.
```

```dart
// Encircled icon with concentric rings
```

```dart
// Nudge the triangle icon up slightly because it's visually bottom-heavy
```

### `lib/features/settings/domain/entities/user_preferences.dart`

```dart
/// Holds all user-configurable preferences that are persisted locally.
```

### `lib/features/settings/domain/repositories/settings_repository.dart`

```dart
/// Loads the persisted [UserPreferences] from local storage.
```

```dart
/// Persists updated [UserPreferences] to local storage.
```

### `lib/features/settings/presentation/providers/settings_bloc.dart`

```dart
/// Manages preference toggles and persists every change immediately.
/// Toggle updates are optimistic — the UI reflects the new value
/// instantly and the write happens in the background.
```

```dart
/// Applies [update] optimistically, emits the new state, then persists.
```

```dart
// Persistence is best-effort; UI already reflects the change.
```

### `lib/features/settings/presentation/providers/settings_event.dart`

```dart
/// Screen opened — load persisted prefs.
```

```dart
/// User toggled a preference switch.
```

```dart
/// User confirmed sign-out from the settings screen.
```

### `lib/features/settings/presentation/screens/settings_screen.dart`

```dart
/// Settings screen. Matches the Figma design:
///  - Teal gradient header: "Settings" title + subtitle
///  - Profile card: avatar, name, email, chevron
///  - ACCOUNT group: Profile, Security, Camera Permissions
///  - PREFERENCES group: Notifications, Dark Mode, Sound Effects, Vibration
///  - Sign out row at the bottom
///  - Bottom nav (Settings tab active)
```

```dart
// ── Teal header + Profile card ──────────────────────────────
```

```dart
// ── Account section ────────────────────────────────────────
```

```dart
// ── Preferences section ────────────────────────────────────
```

```dart
// ─── Header ──────────────────────────────────────────────────────────────
```

```dart
// Flat background header
```

```dart
// Content
```

```dart
// ─── Profile card ─────────────────────────────────────────────────────────
```

```dart
// Avatar circle
```

```dart
// ─── Account group ────────────────────────────────────────────────────────
```

```dart
// ─── Preferences group ────────────────────────────────────────────────────
```

```dart
// ─── Bottom nav ───────────────────────────────────────────────────────────
```

```dart
// ─── Nav item ─────────────────────────────────────────────────────────────────
```

```dart
// ─── Change Password Dialog ───────────────────────────────────────────────────
```

```dart
// ─── Profile Dialog ─────────────────────────────────────────────────────────
```

### `lib/features/settings/presentation/widgets/settings_widgets.dart`

```dart
// ─── Section header label ─────────────────────────────────────────────────────
```

```dart
// ─── Navigation row (icon + label + chevron) ──────────────────────────────────
```

```dart
// ─── Toggle row (icon + label + Switch) ──────────────────────────────────────
```

```dart
// Text inside the track
```

```dart
// Thumb
```

```dart
// ─── White group card container ───────────────────────────────────────────────
```

```dart
/// Inserts a hairline divider between each child (not before/after).
```

### `lib/main.dart`

```dart
// ── Core ──────────────────────────────────────────────────────────────────────
```

```dart
// ── Scanner feature ───────────────────────────────────────────────────────────
```

```dart
// ── Home feature ──────────────────────────────────────────────────────────────
```

```dart
// ── History feature ───────────────────────────────────────────────────────────
```

```dart
// ── Learn feature ─────────────────────────────────────────────────────────────
```

```dart
// ── Auth feature ──────────────────────────────────────────────────────────────
```

```dart
// ── Settings feature ──────────────────────────────────────────────────────────
```

```dart
// ── Step 1: Ensure Flutter binding is initialised ─────────────────────────
// Must be called before ANY plugin or platform channel is used.
```

```dart
// ── Step 2: System UI styling ─────────────────────────────────────────────
```

```dart
// ─────────────────────────────────────────────────────────────────────────────
```

```dart
// ── Dio (shared HTTP client for all remote datasources) ─────────────────
```

```dart
// ── Scanner ─────────────────────────────────────────────────────────────
```

```dart
// ── Auth — Remote PostgreSQL API + SharedPreferences ────────────────────
```

```dart
// ── Settings ──────────────────────────────────────────────────────────────
```

```dart
// ── Dio (shared by ML scan endpoint + PostgreSQL auth/history API) ────
```

```dart
// ── Auth — PostgreSQL-backed REST API + local session cache ──────────
```

```dart
// ── Scanner (ML inference + PostgreSQL history) ───────────────────────
```

```dart
// Inject Bearer token into Dio requests automatically
```

```dart
// ── Settings ────────────────────────────────────────────────────────────
```

```dart
// ─── Theme ──────────────────────────────────────────────────────────────
```

```dart
// ─── Routing ─────────────────────────────────────────────────────────────
```

```dart
// ─── Auth gate ────────────────────────────────────────────────────────────────
```

```dart
// ─── Fallback screen ──────────────────────────────────────────────────────────
```

