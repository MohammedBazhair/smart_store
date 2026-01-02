# Update imports script for clean architecture refactoring

$replacements = @{
    # Domain entities
    "import '../../../domain/entities/product.dart'" = "import '../../domain/product.dart'"
    "import '../../domain/entities/product.dart'" = "import '../../../products/domain/product.dart'"
    "import 'package:smart_store/domain/entities/product.dart'" = "import 'package:smart_store/features/products/domain/product.dart'"
    
    "import '../../../domain/entities/price.dart'" = "import '../../domain/price.dart'"
    "import '../../domain/entities/price.dart'" = "import '../../../prices/domain/price.dart'"
    "import 'package:smart_store/domain/entities/price.dart'" = "import 'package:smart_store/features/prices/domain/price.dart'"
    
    "import '../../../domain/entities/alert.dart'" = "import '../../domain/alert.dart'"
    "import '../../domain/entities/alert.dart'" = "import '../../../alerts/domain/alert.dart'"
    "import 'package:smart_store/domain/entities/alert.dart'" = "import 'package:smart_store/features/alerts/domain/alert.dart'"
    
    "import '../../../domain/entities/settings.dart'" = "import '../../domain/settings.dart'"
    "import '../../domain/entities/settings.dart'" = "import '../../../settings/domain/settings.dart'"
    "import 'package:smart_store/domain/entities/settings.dart'" = "import 'package:smart_store/features/settings/domain/settings.dart'"
    
    # Domain repositories
    "import '../../../domain/repositories/product_repository.dart'" = "import '../../domain/product_repository.dart'"
    "import '../../domain/repositories/product_repository.dart'" = "import '../../../products/domain/product_repository.dart'"
    "import 'package:smart_store/domain/repositories/product_repository.dart'" = "import 'package:smart_store/features/products/domain/product_repository.dart'"
    
    "import '../../../domain/repositories/price_repository.dart'" = "import '../../domain/price_repository.dart'"
    "import '../../domain/repositories/price_repository.dart'" = "import '../../../prices/domain/price_repository.dart'"
    "import 'package:smart_store/domain/repositories/price_repository.dart'" = "import 'package:smart_store/features/prices/domain/price_repository.dart'"
    
    "import '../../../domain/repositories/alert_repository.dart'" = "import '../../domain/alert_repository.dart'"
    "import '../../domain/repositories/alert_repository.dart'" = "import '../../../alerts/domain/alert_repository.dart'"
    "import 'package:smart_store/domain/repositories/alert_repository.dart'" = "import 'package:smart_store/features/alerts/domain/alert_repository.dart'"
    
    "import '../../../domain/repositories/settings_repository.dart'" = "import '../../domain/settings_repository.dart'"
    "import '../../domain/repositories/settings_repository.dart'" = "import '../../../settings/domain/settings_repository.dart'"
    "import 'package:smart_store/domain/repositories/settings_repository.dart'" = "import 'package:smart_store/features/settings/domain/settings_repository.dart'"
    
    "import '../../../domain/repositories/backup_repository.dart'" = "import '../../domain/backup_repository.dart'"
    "import '../../domain/repositories/backup_repository.dart'" = "import '../../../backup/domain/backup_repository.dart'"
    "import 'package:smart_store/domain/repositories/backup_repository.dart'" = "import 'package:smart_store/features/backup/domain/backup_repository.dart'"
    
    # Data models
    "import '../../data/models/product_model.dart'" = "import '../../../products/data/product_model.dart'"
    "import '../../../data/models/product_model.dart'" = "import '../../data/product_model.dart'"
    "import 'package:smart_store/data/models/product_model.dart'" = "import 'package:smart_store/features/products/data/product_model.dart'"
    
    "import '../../data/models/price_model.dart'" = "import '../../../prices/data/price_model.dart'"
    "import '../../../data/models/price_model.dart'" = "import '../../data/price_model.dart'"
    "import 'package:smart_store/data/models/price_model.dart'" = "import 'package:smart_store/features/prices/data/price_model.dart'"
    
    "import '../../data/models/alert_model.dart'" = "import '../../../alerts/data/alert_model.dart'"
    "import '../../../data/models/alert_model.dart'" = "import '../../data/alert_model.dart'"
    "import 'package:smart_store/data/models/alert_model.dart'" = "import 'package:smart_store/features/alerts/data/alert_model.dart'"
    
    "import '../../data/models/settings_model.dart'" = "import '../../../settings/data/settings_model.dart'"
    "import '../../../data/models/settings_model.dart'" = "import '../../data/settings_model.dart'"
    "import 'package:smart_store/data/models/settings_model.dart'" = "import 'package:smart_store/features/settings/data/settings_model.dart'"
    
    # Data repositories
    "import '../../data/repositories/product_repository_impl.dart'" = "import '../../../products/data/product_repository_impl.dart'"
    "import 'package:smart_store/data/repositories/product_repository_impl.dart'" = "import 'package:smart_store/features/products/data/product_repository_impl.dart'"
    
    "import '../../data/repositories/price_repository_impl.dart'" = "import '../../../prices/data/price_repository_impl.dart'"
    "import 'package:smart_store/data/repositories/price_repository_impl.dart'" = "import 'package:smart_store/features/prices/data/price_repository_impl.dart'"
    
    "import '../../data/repositories/alert_repository_impl.dart'" = "import '../../../alerts/data/alert_repository_impl.dart'"
    "import 'package:smart_store/data/repositories/alert_repository_impl.dart'" = "import 'package:smart_store/features/alerts/data/alert_repository_impl.dart'"
    
    "import '../../data/repositories/settings_repository_impl.dart'" = "import '../../../settings/data/settings_repository_impl.dart'"
    "import 'package:smart_store/data/repositories/settings_repository_impl.dart'" = "import 'package:smart_store/features/settings/data/settings_repository_impl.dart'"
    
    "import '../../data/repositories/backup_repository_impl.dart'" = "import '../../../backup/data/backup_repository_impl.dart'"
    "import 'package:smart_store/data/repositories/backup_repository_impl.dart'" = "import 'package:smart_store/features/backup/data/backup_repository_impl.dart'"
    
    # Presentation - Controllers
    "import '../controllers/product_controller.dart'" = "import '../../../products/presentation/product_controller.dart'"
    "import '../../presentation/controllers/product_controller.dart'" = "import '../../../products/presentation/product_controller.dart'"
    "import 'package:smart_store/presentation/controllers/product_controller.dart'" = "import 'package:smart_store/features/products/presentation/product_controller.dart'"
    
    "import '../controllers/price_controller.dart'" = "import '../../../prices/presentation/price_controller.dart'"
    "import '../../presentation/controllers/price_controller.dart'" = "import '../../../prices/presentation/price_controller.dart'"
    "import 'package:smart_store/presentation/controllers/price_controller.dart'" = "import 'package:smart_store/features/prices/presentation/price_controller.dart'"
    
    "import '../controllers/alert_controller.dart'" = "import '../../../alerts/presentation/alert_controller.dart'"
    "import '../../presentation/controllers/alert_controller.dart'" = "import '../../../alerts/presentation/alert_controller.dart'"
    "import 'package:smart_store/presentation/controllers/alert_controller.dart'" = "import 'package:smart_store/features/alerts/presentation/alert_controller.dart'"
    
    "import '../controllers/settings_controller.dart'" = "import '../../../settings/presentation/settings_controller.dart'"
    "import '../../presentation/controllers/settings_controller.dart'" = "import '../../../settings/presentation/settings_controller.dart'"
    "import 'package:smart_store/presentation/controllers/settings_controller.dart'" = "import 'package:smart_store/features/settings/presentation/settings_controller.dart'"
    
    "import '../controllers/barcode_controller.dart'" = "import '../../../barcode/presentation/barcode_controller.dart'"
    "import '../../presentation/controllers/barcode_controller.dart'" = "import '../../../barcode/presentation/barcode_controller.dart'"
    "import 'package:smart_store/presentation/controllers/barcode_controller.dart'" = "import 'package:smart_store/features/barcode/presentation/barcode_controller.dart'"
    
    "import '../controllers/backup_controller.dart'" = "import '../../../backup/presentation/backup_controller.dart'"
    "import '../../presentation/controllers/backup_controller.dart'" = "import '../../../backup/presentation/backup_controller.dart'"
    "import 'package:smart_store/presentation/controllers/backup_controller.dart'" = "import 'package:smart_store/features/backup/presentation/backup_controller.dart'"
    
    # Presentation - Providers
    "import '../providers/product_provider.dart'" = "import '../../../products/presentation/product_provider.dart'"
    "import '../../presentation/providers/product_provider.dart'" = "import '../../../products/presentation/product_provider.dart'"
    "import 'package:smart_store/presentation/providers/product_provider.dart'" = "import 'package:smart_store/features/products/presentation/product_provider.dart'"
    
    "import '../providers/price_provider.dart'" = "import '../../../prices/presentation/price_provider.dart'"
    "import '../../presentation/providers/price_provider.dart'" = "import '../../../prices/presentation/price_provider.dart'"
    "import 'package:smart_store/presentation/providers/price_provider.dart'" = "import 'package:smart_store/features/prices/presentation/price_provider.dart'"
    
    "import '../providers/alert_provider.dart'" = "import '../../../alerts/presentation/alert_provider.dart'"
    "import '../../presentation/providers/alert_provider.dart'" = "import '../../../alerts/presentation/alert_provider.dart'"
    "import 'package:smart_store/presentation/providers/alert_provider.dart'" = "import 'package:smart_store/features/alerts/presentation/alert_provider.dart'"
    
    "import '../providers/settings_provider.dart'" = "import '../../../settings/presentation/settings_provider.dart'"
    "import '../../presentation/providers/settings_provider.dart'" = "import '../../../settings/presentation/settings_provider.dart'"
    "import 'package:smart_store/presentation/providers/settings_provider.dart'" = "import 'package:smart_store/features/settings/presentation/settings_provider.dart'"
    
    "import '../providers/repositories_provider.dart'" = "import '../../../shared/providers/repositories_provider.dart'"
    "import '../../presentation/providers/repositories_provider.dart'" = "import '../../../shared/providers/repositories_provider.dart'"
    "import 'package:smart_store/presentation/providers/repositories_provider.dart'" = "import 'package:smart_store/shared/providers/repositories_provider.dart'"
    
    # Presentation - Screens
    "import '../screens/products/products_screen.dart'" = "import '../../../products/presentation/screens/products_screen.dart'"
    "import '../../presentation/screens/products/products_screen.dart'" = "import '../../../products/presentation/screens/products_screen.dart'"
    "import 'package:smart_store/presentation/screens/products/products_screen.dart'" = "import 'package:smart_store/features/products/presentation/screens/products_screen.dart'"
    
    "import '../screens/products/add_product_screen.dart'" = "import '../../../products/presentation/screens/add_product_screen.dart'"
    "import '../../presentation/screens/products/add_product_screen.dart'" = "import '../../../products/presentation/screens/add_product_screen.dart'"
    "import 'package:smart_store/presentation/screens/products/add_product_screen.dart'" = "import 'package:smart_store/features/products/presentation/screens/add_product_screen.dart'"
    
    "import '../screens/products/product_details_screen.dart'" = "import '../../../products/presentation/screens/product_details_screen.dart'"
    "import '../../presentation/screens/products/product_details_screen.dart'" = "import '../../../products/presentation/screens/product_details_screen.dart'"
    "import 'package:smart_store/presentation/screens/products/product_details_screen.dart'" = "import 'package:smart_store/features/products/presentation/screens/product_details_screen.dart'"
    
    "import '../screens/alerts/alerts_screen.dart'" = "import '../../../alerts/presentation/screens/alerts_screen.dart'"
    "import '../../presentation/screens/alerts/alerts_screen.dart'" = "import '../../../alerts/presentation/screens/alerts_screen.dart'"
    "import 'package:smart_store/presentation/screens/alerts/alerts_screen.dart'" = "import 'package:smart_store/features/alerts/presentation/screens/alerts_screen.dart'"
    
    "import '../screens/settings/settings_screen.dart'" = "import '../../../settings/presentation/screens/settings_screen.dart'"
    "import '../../presentation/screens/settings/settings_screen.dart'" = "import '../../../settings/presentation/screens/settings_screen.dart'"
    "import 'package:smart_store/presentation/screens/settings/settings_screen.dart'" = "import 'package:smart_store/features/settings/presentation/screens/settings_screen.dart'"
    
    "import '../screens/barcode/barcode_scanner_screen.dart'" = "import '../../../barcode/presentation/screens/barcode_scanner_screen.dart'"
    "import '../../presentation/screens/barcode/barcode_scanner_screen.dart'" = "import '../../../barcode/presentation/screens/barcode_scanner_screen.dart'"
    "import 'package:smart_store/presentation/screens/barcode/barcode_scanner_screen.dart'" = "import 'package:smart_store/features/barcode/presentation/screens/barcode_scanner_screen.dart'"
    
    "import '../screens/dashboard/dashboard_screen.dart'" = "import '../../../dashboard/presentation/dashboard_screen.dart'"
    "import '../../presentation/screens/dashboard/dashboard_screen.dart'" = "import '../../../dashboard/presentation/dashboard_screen.dart'"
    "import 'package:smart_store/presentation/screens/dashboard/dashboard_screen.dart'" = "import 'package:smart_store/features/dashboard/presentation/dashboard_screen.dart'"
    
    # Presentation - Services
    "import '../services/alert_service.dart'" = "import '../../../alerts/presentation/alert_service.dart'"
    "import '../../presentation/services/alert_service.dart'" = "import '../../../alerts/presentation/alert_service.dart'"
    "import 'package:smart_store/presentation/services/alert_service.dart'" = "import 'package:smart_store/features/alerts/presentation/alert_service.dart'"
    
    # Presentation - Theme
    "import '../theme/app_theme.dart'" = "import '../../../shared/presentation/theme/app_theme.dart'"
    "import '../../presentation/theme/app_theme.dart'" = "import '../../../shared/presentation/theme/app_theme.dart'"
    "import 'package:smart_store/presentation/theme/app_theme.dart'" = "import 'package:smart_store/shared/presentation/theme/app_theme.dart'"
    
    # Presentation - Widgets
    "import '../widgets/common/error_widget.dart'" = "import '../../../shared/presentation/widgets/common/error_widget.dart'"
    "import '../../presentation/widgets/common/error_widget.dart'" = "import '../../../shared/presentation/widgets/common/error_widget.dart'"
    "import 'package:smart_store/presentation/widgets/common/error_widget.dart'" = "import 'package:smart_store/shared/presentation/widgets/common/error_widget.dart'"
    
    "import '../widgets/common/loading_widget.dart'" = "import '../../../shared/presentation/widgets/common/loading_widget.dart'"
    "import '../../presentation/widgets/common/loading_widget.dart'" = "import '../../../shared/presentation/widgets/common/loading_widget.dart'"
    "import 'package:smart_store/presentation/widgets/common/loading_widget.dart'" = "import 'package:smart_store/shared/presentation/widgets/common/loading_widget.dart'"
    
    "import '../widgets/common/gradient_container.dart'" = "import '../../../shared/presentation/widgets/common/gradient_container.dart'"
    "import '../../presentation/widgets/common/gradient_container.dart'" = "import '../../../shared/presentation/widgets/common/gradient_container.dart'"
    "import 'package:smart_store/presentation/widgets/common/gradient_container.dart'" = "import 'package:smart_store/shared/presentation/widgets/common/gradient_container.dart'"
    
    "import '../widgets/common/stat_card.dart'" = "import '../../../shared/presentation/widgets/common/stat_card.dart'"
    "import '../../presentation/widgets/common/stat_card.dart'" = "import '../../../shared/presentation/widgets/common/stat_card.dart'"
    "import 'package:smart_store/presentation/widgets/common/stat_card.dart'" = "import 'package:smart_store/shared/presentation/widgets/common/stat_card.dart'"
    
    # Data - Database
    "import '../../data/database/database_helper.dart'" = "import 'package:smart_store/core/data/database_helper.dart'"
    "import '../../../data/database/database_helper.dart'" = "import 'package:smart_store/core/data/database_helper.dart'"
    "import 'package:smart_store/data/database/database_helper.dart'" = "import 'package:smart_store/core/data/database_helper.dart'"
}

# Get all Dart files in lib folder
$dartFiles = Get-ChildItem -Path "e:\Projects\smart_store\lib" -Filter "*.dart" -Recurse

foreach ($file in $dartFiles) {
    $content = Get-Content $file.FullName -Raw
    $modified = $false
    
    foreach ($old in $replacements.Keys) {
        $new = $replacements[$old]
        if ($content -match [regex]::Escape($old)) {
            $content = $content -replace [regex]::Escape($old), $new
            $modified = $true
        }
    }
    
    if ($modified) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        Write-Host "Updated: $($file.FullName)"
    }
}

Write-Host "`nImport update completed!"
