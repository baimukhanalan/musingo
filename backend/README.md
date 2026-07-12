# Muslingo backend

PocketBase provides local authentication, progress synchronization, and the
leaderboard. Schema changes live in `pb_migrations`; server-owned progress
logic lives in `pb_hooks`.

```bash
tools/pocketbase/pocketbase serve \
  --dir=backend/pb_data \
  --migrationsDir=backend/pb_migrations \
  --hooksDir=backend/pb_hooks \
  --http=127.0.0.1:8090
```

`backend/pb_data` contains runtime data and must not be committed or shipped in
the client application. No superuser credentials are required by the app.
