# SafeZone Supabase setup

This version uses Supabase for the first real vertical slice: account signup/login, profile creation, incident creation, and the shared incident feed.

## 1. Create a Supabase project
Create a project, then open **SQL Editor** and run `supabase/schema.sql`.

## 2. Get client credentials
From the Supabase project **Connect** panel, copy:
- Project URL
- Publishable key

Do **not** commit a service-role/secret key into this Flutter app.

## 3. Run SafeZone
Use Dart defines instead of hardcoding credentials:

```bash
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

On PowerShell, the same command can be kept on one line.

## 4. Email confirmation
Supabase email confirmation is usually enabled by default. When it is enabled, signup creates the account but the user must confirm the email before signing in. The database trigger still creates the SafeZone profile from the signup metadata.

## What is real in this slice
- Email/password signup
- Profile generated in `public.profiles`
- Email/password login
- Role loaded from the database
- Incident inserted into `public.incidents`
- Incident feed loaded from Supabase

## Still prototype/mock
Maps/GPS, media upload, realtime emergency dispatch, push notifications, SMS fallback, chat persistence, patrol approval/admin workflow and analytics still need implementation.
