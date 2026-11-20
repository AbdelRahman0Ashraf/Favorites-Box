# Assignment 3 - Offline Posts & Favorites

**Course:** Fall 2026 - Mobile Computing  
**Student:** Abdelrahman Ashraf  
**Student ID:** 23011309

A Flutter Posts app using Hive for offline caching and a separate persistent favorites box. Posts come from `https://jsonplaceholder.typicode.com/posts`.

## Features

- Fetch posts online and save them locally; reuse cached posts if the request fails.
- Add/remove favorites with outlined/filled stars and immediate reactive updates.
- Open the Favorites screen from the Posts AppBar.
- Display the same post cards on both screens.
- Display "No favorites yet" when no favorites are saved.
- Keep favorites through refreshes, cache replacement, and app restarts.
- Access Favorites even when a fresh installation has no cached posts.
- Show loading, retry, offline status, and storage error feedback.

## Run

Install Flutter, then run from the project root:

```sh
flutter create --project-name mobile_assignment_3 --platforms android,web .
flutter pub get
flutter run
```

This source package requires the first command to generate the standard Android/web runner files. After generation, add `<uses-permission android:name="android.permission.INTERNET" />` inside the root `<manifest>` element of `android/app/src/main/AndroidManifest.xml`. The source has not yet passed runtime verification in the delivery environment; screenshots and a real airplane-mode demonstration are still required before submission.

For a browser run, use `flutter run -d chrome`. Android requires a configured Android SDK and emulator or connected phone. Release Android builds include INTERNET permission in `android/app/src/main/AndroidManifest.xml`.

## Organization

```text
lib/
  main.dart                         # Initialize Hive; open both boxes
  models/post_model.dart            # Post, copy, and hand-written PostAdapter
  services/post_service.dart         # HTTP fetch and offline cache
  services/favorites_service.dart    # Favorite operations and box listenable
  screens/posts_screen.dart          # Loading/error/list; refresh; navigation
  screens/favorites_screen.dart      # Reactive favorites list and empty state
  widgets/post_card.dart             # Shared card and favorite toggle
test/storage_test.dart               # Real on-disk Hive regression tests
```

## How storage works

`postsBox` stores cached posts keyed by post ID. The API response is parsed before updating the cache. Failed requests return cached data; an empty cache produces `No Internet and No Cached Data`.

`favoritesBox` independently stores copied `Post` objects, also keyed by ID. `toggleFavorite(Post post)` saves a copy or deletes that ID, `isFavorite(int id)` checks `containsKey`, and `getFavorites()` returns the saved posts. A copy is necessary because a `HiveObject` can belong to only one box. Network refresh never writes to the favorites box.

Both screens subscribe to the service's Hive `ValueListenable`. Adding or removing a favorite updates the stars and list without a network request. The adapter uses type ID 0 and field indices 0=id, 1=title, 2=body, 3=userId, matching the lab. It is written by hand, so `build_runner` is unnecessary.

## Verification

```sh
flutter analyze
flutter test
```

The storage tests exercise copying a post already attached to `postsBox`, toggle/remove, persistence after closing/reopening Hive, independence from clearing/refetching posts, offline fallback after restart, and the first-launch error state.

### Manual offline demonstration

1. Launch online and wait for posts to load.
2. Favorite at least two posts; verify their filled stars.
3. Open Favorites and verify both posts appear.
4. Return to Posts and pull to refresh; verify the stars and Favorites remain.
5. Fully close the app, enable airplane mode, and reopen it.
6. Verify cached posts, offline status, and the saved Favorites.
7. Remove a favorite while offline; verify it disappears and stays removed after another restart.
8. Remove the remaining favorites and verify "No favorites yet".

Do not uninstall or clear app data during the persistence test; doing so intentionally removes the local database.

## Submission

Upload this entire project, including README and screenshots, to GitHub. Enter the repository URL in the course form alongside the student name and ID above.

References: [Flutter project setup](https://docs.flutter.dev/reference/create-new-app), [Hive 2.2.3](https://pub.dev/packages/hive/versions/2.2.3), [Hive Flutter 1.1.0](https://pub.dev/packages/hive_flutter/versions/1.1.0).
