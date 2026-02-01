# Movie Browse

A movie discovery app using The Movie Database (TMDB) API with Clean Architecture and feature-first structure.

## Setup

1. **Get a TMDB API key**
   - Sign up at [themoviedb.org](https://www.themoviedb.org/signup)
   - Go to [API Settings](https://www.themoviedb.org/settings/api)
   - Create an API key and copy your **API Read Access Token** (v4) for Bearer auth

2. **Configure the app**
   - Open `lib/core/constants/api_constants.dart`
   - Replace `YOUR_TMDB_API_KEY` with your API key (if using query-param auth)
   - Replace `YOUR_TMDB_READ_ACCESS_TOKEN` with your Read Access Token (v4)

## Running

```bash
flutter pub get
flutter run
```

## Project Structure

```
lib/
├── core/           # API client, constants, errors, storage
├── features/
│   ├── movies/     # Discover movies list
│   ├── movie_detail/
│   └── person_detail/
└── main.dart
```

## Architecture

- **flutter_bloc** – state management
- **dartz** – `Either<Failure, T>` for error handling
- **Clean Architecture** – data, domain, presentation per feature
