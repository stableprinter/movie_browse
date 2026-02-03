# Movie Browse Module

A standalone Flutter module that showcases **Clean Architecture** implementation in Flutter with comprehensive **Integration, Unit, and Widget Testing**.

This module is designed to be integrated into larger applications and handles all logic related to movie browsing and details functionality.

## Module Overview

This **Browse Module** is supplied to one team and provides the following capabilities:

- **Browse Movie Page** - Discover and browse movies with filtering and search
- **Movie Detail Page** - Complete movie information and metadata
- **Person Detail Page** - Actor/crew member information and filmography

### Deeplink Support

The module exposes a deeplink for **Movie Detail** page to allow other teams to navigate directly to specific movie details:

```
/movie:{isFavorite}:{movieId}
```

This enables seamless integration where other modules or features can link to movie details without directly depending on the browse module implementation.

### Inter-Module Communication

The module uses **MethodChannel** and **EventChannel** to communicate with other modules:

- **MethodChannel** - For synchronous method calls between modules
- **EventChannel** - For streaming events and updates to other modules

### Standalone Mode

The module includes **mock-ready** functionality to run standalone without external dependencies. This allows:

- Independent development and testing
- Running the module in isolation
- Mock implementations can be added or edited later as needed

For more real-life mock data, see: [https://github.com/stableprinter/brand](https://github.com/stableprinter/brand)

### Font Usage Policy

**To avoid any confusion or misbehavior in UI**, this project **must always use "BrandFont"** supplied from the [movie_core](https://github.com/stableprinter/movie_core) project.

**Important:**
- This module has **no right to add its own fonts** unless it's a required requirement
- All font assets are centralized in the movie_core project to ensure consistency
- Using BrandFont ensures visual consistency across all Flutter modules in the application

## Running

```bash
flutter pub get
flutter run
```

## Project Structure

```
lib/
├── core/                    # Shared infrastructure & cross-cutting concerns
│   ├── config/              # App configuration
│   ├── constants/           # API endpoints, routes, channel names
│   ├── di/                  # Dependency injection (GetIt service locator)
│   ├── errors/              # Failure types (ServerFailure, NetworkFailure)
│   └── service/             # API client, MethodChannel, EventChannel, navigation
├── features/
│   ├── movies/              # Browse movies (discover, filter, search)
│   ├── movie_detail/        # Movie detail (accessible via deeplink)
│   └── person_detail/       # Person detail (actor/crew info)
└── main.dart
```

### Feature Structure (Clean Architecture)

Each feature follows the same layered structure:

```
features/<feature_name>/
├── data/                    # Outermost layer – implementation details
│   ├── datasources/         # Remote/local data sources (API, DB)
│   │   ├── *_datasource.dart        # Abstract contract
│   │   └── *_datasource_impl.dart   # Concrete implementation
│   ├── models/              # DTOs with fromJson/toJson (extends Entity)
│   └── repositories/       # Repository implementations
│       └── *_repository_impl.dart
├── domain/                  # Innermost layer – business logic (no Flutter)
│   ├── entities/           # Pure business objects
│   ├── repositories/       # Abstract repository contracts
│   └── usecases/           # Single-responsibility business operations
└── presentation/           # UI layer – Flutter-dependent
    ├── bloc/               # State management (events, states, bloc)
    ├── pages/              # Full-screen screens
    └── widgets/            # Reusable UI components
```

### Clean Architecture: Layer Communication

**Dependency rule:** Dependencies point **inward**. Inner layers never depend on outer layers.

```
┌─────────────────────────────────────────────────────────────────┐
│  PRESENTATION (Bloc, Pages, Widgets)                             │
│  • Listens to user actions, emits UI states                     │
│  • Depends on: Domain (UseCases)                                 │
└───────────────────────────────┬─────────────────────────────────┘
                                │ calls
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│  DOMAIN (Entities, Repositories*, UseCases)                      │
│  • Pure business logic, framework-agnostic                      │
│  • Depends on: nothing (only core/errors)                        │
└───────────────────────────────┬─────────────────────────────────┘
                                │ implements
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│  DATA (Datasources, Models, RepositoryImpl)                     │
│  • Fetches data, maps to Entities, handles errors               │
│  • Depends on: Domain (Entities, Repository contracts)          │
└─────────────────────────────────────────────────────────────────┘
```

**Data flow example (Discover Movies):**

1. **UI** → User pulls to refresh → `MoviesBloc` receives `MoviesRefreshRequested`
2. **Bloc** → Calls `DiscoverMoviesUseCase(page: 1)`
3. **UseCase** → Calls `MoviesRepository.discoverMovies()`
4. **RepositoryImpl** → Calls `MoviesRemoteDatasource.discoverMovies()`
5. **DatasourceImpl** → Fetches from API, maps JSON → `MovieModel`, returns `Either<Failure, List<Movie>>`
6. **Response** flows back: Datasource → Repository → UseCase → Bloc
7. **Bloc** → `result.fold()` handles `Left(Failure)` or `Right(movies)` → emits `MoviesLoaded` or `MoviesError`
8. **UI** → Rebuilds from new state

**Error handling:** All async operations return `Either<Failure, T>` (dartz). `Left` = error, `Right` = success. Presentation uses `.fold()` to handle both.

**Dependency injection:** `core/di/service_locator.dart` wires layers via GetIt. Blocs receive UseCases; Repositories receive Datasources. Contracts (abstract classes) are registered with concrete implementations.

## Architecture

- **Clean Architecture** – data, domain, presentation layers per feature; dependency rule enforced
- **flutter_bloc** – state management
- **dartz** – `Either<Failure, T>` for error handling
- **Feature-first structure** – each feature is self-contained and modular

## Testing Showcase

This project demonstrates comprehensive testing strategies in Flutter:

- **Unit Tests** – Testing business logic, use cases, and repositories in isolation
- **Widget Tests** – Testing UI components and their interactions
- **Integration Tests** – Testing complete user flows and feature integration

Run tests with:
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## Integration Notes

- This module is designed to be integrated as a standalone package or sub-module
- Other teams can navigate to movie details using the provided deeplink pattern
- All movie browsing logic is encapsulated within this module
- Uses MethodChannel and EventChannel for inter-module communication
- Can run standalone with mock data for independent development
- **Must use BrandFont** from [movie_core](https://github.com/stableprinter/movie_core) - no custom fonts allowed unless required
