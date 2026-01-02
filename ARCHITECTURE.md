# Smart Store - Clean Architecture Structure

## 📁 Project Structure

This project follows **Clean Architecture** principles with a **feature-based** folder structure. Each feature is organized into three main layers: **Domain**, **Data**, and **Presentation**.

```
lib/
├── core/                          # Core utilities and constants
│   ├── constants/                 # App-wide constants
│   │   ├── app_constants.dart
│   │   └── enums.dart
│   ├── data/                      # Core data utilities
│   │   └── database_helper.dart   # SQLite database helper
│   ├── errors/                    # Error handling
│   │   └── failures.dart
│   └── utils/                     # Utility functions
│       ├── currency_utils.dart
│       ├── date_utils.dart
│       └── result.dart
│
├── features/                      # Feature modules
│   ├── products/                  # Product management feature
│   │   ├── domain/                # Business logic layer
│   │   │   ├── product.dart       # Product entity
│   │   │   └── product_repository.dart  # Repository interface
│   │   ├── data/                  # Data layer
│   │   │   ├── product_model.dart       # Data model
│   │   │   └── product_repository_impl.dart  # Repository implementation
│   │   └── presentation/          # UI layer
│   │       ├── product_controller.dart
│   │       ├── product_provider.dart
│   │       ├── screens/
│   │       │   ├── products_screen.dart
│   │       │   ├── add_product_screen.dart
│   │       │   └── product_details_screen.dart
│   │       └── widgets/
│   │           └── product_card.dart
│   │
│   ├── prices/                    # Price tracking feature
│   │   ├── domain/
│   │   │   ├── price.dart
│   │   │   └── price_repository.dart
│   │   ├── data/
│   │   │   ├── price_model.dart
│   │   │   └── price_repository_impl.dart
│   │   └── presentation/
│   │       ├── price_controller.dart
│   │       └── price_provider.dart
│   │
│   ├── alerts/                    # Alerts & notifications feature
│   │   ├── domain/
│   │   │   ├── alert.dart
│   │   │   └── alert_repository.dart
│   │   ├── data/
│   │   │   ├── alert_model.dart
│   │   │   └── alert_repository_impl.dart
│   │   └── presentation/
│   │       ├── alert_controller.dart
│   │       ├── alert_provider.dart
│   │       ├── alert_service.dart
│   │       └── screens/
│   │           └── alerts_screen.dart
│   │
│   ├── settings/                  # App settings feature
│   │   ├── domain/
│   │   │   ├── settings.dart
│   │   │   └── settings_repository.dart
│   │   ├── data/
│   │   │   ├── settings_model.dart
│   │   │   └── settings_repository_impl.dart
│   │   └── presentation/
│   │       ├── settings_controller.dart
│   │       ├── settings_provider.dart
│   │       └── screens/
│   │           └── settings_screen.dart
│   │
│   ├── barcode/                   # Barcode scanning feature
│   │   └── presentation/
│   │       ├── barcode_controller.dart
│   │       └── screens/
│   │           └── barcode_scanner_screen.dart
│   │
│   ├── backup/                    # Backup & restore feature
│   │   ├── domain/
│   │   │   └── backup_repository.dart
│   │   ├── data/
│   │   │   └── backup_repository_impl.dart
│   │   └── presentation/
│   │       └── backup_controller.dart
│   │
│   └── dashboard/                 # Dashboard feature
│       └── presentation/
│           └── dashboard_screen.dart
│
├── shared/                        # Shared resources across features
│   ├── presentation/
│   │   ├── theme/                 # App theme
│   │   │   └── app_theme.dart
│   │   └── widgets/               # Reusable widgets
│   │       └── common/
│   │           ├── error_widget.dart
│   │           ├── gradient_container.dart
│   │           ├── loading_widget.dart
│   │           └── stat_card.dart
│   └── providers/                 # Shared providers
│       └── repositories_provider.dart
│
└── main.dart                      # App entry point
```

## 🏗️ Architecture Layers

### 1. **Domain Layer** (`domain/`)
- Contains **business entities** and **repository interfaces**
- Pure Dart code with no dependencies on Flutter or external packages
- Defines the **business rules** and **contracts**

**Example:**
```dart
// Entity
class Product {
  final String id;
  final String name;
  final double price;
  // ...
}

// Repository Interface
abstract class ProductRepository {
  Future<List<Product>> getAllProducts();
  Future<void> addProduct(Product product);
  // ...
}
```

### 2. **Data Layer** (`data/`)
- Implements **repository interfaces** from the domain layer
- Contains **data models** that extend domain entities
- Handles data sources (database, API, etc.)

**Example:**
```dart
// Data Model
class ProductModel extends Product {
  ProductModel({required super.id, required super.name, ...});
  
  factory ProductModel.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }
}

// Repository Implementation
class ProductRepositoryImpl implements ProductRepository {
  @override
  Future<List<Product>> getAllProducts() async {
    // Database or API calls
  }
}
```

### 3. **Presentation Layer** (`presentation/`)
- Contains **UI screens**, **widgets**, **controllers**, and **providers**
- Uses **Riverpod** for state management
- Depends on domain layer for business logic

**Structure:**
- `screens/` - Full-page screens
- `widgets/` - Feature-specific reusable widgets
- `*_controller.dart` - Business logic controllers
- `*_provider.dart` - Riverpod providers

## 📦 Features

### Products
Manage product inventory with CRUD operations, price tracking, and barcode scanning.

### Prices
Track price history and changes for products over time.

### Alerts
Set up and manage notifications for low stock, price changes, etc.

### Settings
Configure app preferences, currency, language, and other settings.

### Barcode
Scan product barcodes for quick product lookup and addition.

### Backup
Backup and restore app data.

### Dashboard
Main overview screen showing statistics and quick actions.

## 🔄 Data Flow

```
UI (Presentation) 
    ↓ (user action)
Controller
    ↓ (calls)
Repository Interface (Domain)
    ↓ (implemented by)
Repository Implementation (Data)
    ↓ (accesses)
Data Source (Database/API)
    ↓ (returns)
Data Model (Data)
    ↓ (maps to)
Entity (Domain)
    ↓ (updates)
Provider (Presentation)
    ↓ (rebuilds)
UI (Presentation)
```

## 🎯 Benefits of This Architecture

1. **Separation of Concerns**: Each layer has a clear responsibility
2. **Testability**: Easy to unit test business logic independently
3. **Maintainability**: Changes in one layer don't affect others
4. **Scalability**: Easy to add new features without affecting existing ones
5. **Reusability**: Shared components are centralized
6. **Independence**: Domain layer is independent of frameworks

## 📝 Naming Conventions

- **Entities**: `Product`, `Price`, `Alert`
- **Models**: `ProductModel`, `PriceModel`, `AlertModel`
- **Repositories**: `ProductRepository`, `ProductRepositoryImpl`
- **Controllers**: `ProductController`, `PriceController`
- **Providers**: `productProvider`, `priceProvider`
- **Screens**: `ProductsScreen`, `AddProductScreen`

## 🚀 Getting Started

1. **Domain First**: Define your entities and repository interfaces
2. **Data Layer**: Implement repositories and create data models
3. **Presentation**: Build UI screens and wire up with providers

## 📚 Additional Resources

- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture](https://resocoder.com/2019/08/27/flutter-tdd-clean-architecture-course-1-explanation-project-structure/)
- [Riverpod Documentation](https://riverpod.dev/)

---

**Last Updated**: December 2025
