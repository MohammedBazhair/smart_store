# Comprehensive import update script

$libPath = "e:\Projects\smart_store\lib"

# Get all Dart files
$dartFiles = Get-ChildItem -Path $libPath -Filter "*.dart" -Recurse

foreach ($file in $dartFiles) {
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    
    # Update all old-style imports to new feature-based structure
    
    # Product imports
    $content = $content -replace "import '\.\.\/\.\.\/\.\.\/domain\/entities\/product\.dart'", "import '../../domain/product.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/domain\/entities\/product\.dart'", "import '../../../products/domain/product.dart'"
    $content = $content -replace "import 'package:smart_store\/domain\/entities\/product\.dart'", "import 'package:smart_store/features/products/domain/product.dart'"
    
    $content = $content -replace "import '\.\.\/\.\.\/\.\.\/domain\/repositories\/product_repository\.dart'", "import '../../domain/product_repository.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/domain\/repositories\/product_repository\.dart'", "import '../../../products/domain/product_repository.dart'"
    $content = $content -replace "import 'package:smart_store\/domain\/repositories\/product_repository\.dart'", "import 'package:smart_store/features/products/domain/product_repository.dart'"
    
    $content = $content -replace "import '\.\.\/\.\.\/\.\.\/data\/models\/product_model\.dart'", "import '../../data/product_model.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/data\/models\/product_model\.dart'", "import '../../../products/data/product_model.dart'"
    $content = $content -replace "import 'package:smart_store\/data\/models\/product_model\.dart'", "import 'package:smart_store/features/products/data/product_model.dart'"
    
    $content = $content -replace "import '\.\.\/\.\.\/data\/repositories\/product_repository_impl\.dart'", "import '../../../products/data/product_repository_impl.dart'"
    $content = $content -replace "import 'package:smart_store\/data\/repositories\/product_repository_impl\.dart'", "import 'package:smart_store/features/products/data/product_repository_impl.dart'"
    
    # Price imports
    $content = $content -replace "import '\.\.\/\.\.\/\.\.\/domain\/entities\/price\.dart'", "import '../../domain/price.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/domain\/entities\/price\.dart'", "import '../../../prices/domain/price.dart'"
    $content = $content -replace "import 'package:smart_store\/domain\/entities\/price\.dart'", "import 'package:smart_store/features/prices/domain/price.dart'"
    
    $content = $content -replace "import '\.\.\/\.\.\/\.\.\/domain\/repositories\/price_repository\.dart'", "import '../../domain/price_repository.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/domain\/repositories\/price_repository\.dart'", "import '../../../prices/domain/price_repository.dart'"
    $content = $content -replace "import 'package:smart_store\/domain\/repositories\/price_repository\.dart'", "import 'package:smart_store/features/prices/domain/price_repository.dart'"
    
    $content = $content -replace "import '\.\.\/\.\.\/\.\.\/data\/models\/price_model\.dart'", "import '../../data/price_model.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/data\/models\/price_model\.dart'", "import '../../../prices/data/price_model.dart'"
    $content = $content -replace "import 'package:smart_store\/data\/models\/price_model\.dart'", "import 'package:smart_store/features/prices/data/price_model.dart'"
    
    $content = $content -replace "import '\.\.\/\.\.\/data\/repositories\/price_repository_impl\.dart'", "import '../../../prices/data/price_repository_impl.dart'"
    $content = $content -replace "import 'package:smart_store\/data\/repositories\/price_repository_impl\.dart'", "import 'package:smart_store/features/prices/data/price_repository_impl.dart'"
    
    # Alert imports
    $content = $content -replace "import '\.\.\/\.\.\/\.\.\/domain\/entities\/alert\.dart'", "import '../../domain/alert.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/domain\/entities\/alert\.dart'", "import '../../../alerts/domain/alert.dart'"
    $content = $content -replace "import 'package:smart_store\/domain\/entities\/alert\.dart'", "import 'package:smart_store/features/alerts/domain/alert.dart'"
    
    $content = $content -replace "import '\.\.\/\.\.\/\.\.\/domain\/repositories\/alert_repository\.dart'", "import '../../domain/alert_repository.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/domain\/repositories\/alert_repository\.dart'", "import '../../../alerts/domain/alert_repository.dart'"
    $content = $content -replace "import 'package:smart_store\/domain\/repositories\/alert_repository\.dart'", "import 'package:smart_store/features/alerts/domain/alert_repository.dart'"
    
    $content = $content -replace "import '\.\.\/\.\.\/\.\.\/data\/models\/alert_model\.dart'", "import '../../data/alert_model.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/data\/models\/alert_model\.dart'", "import '../../../alerts/data/alert_model.dart'"
    $content = $content -replace "import 'package:smart_store\/data\/models\/alert_model\.dart'", "import 'package:smart_store/features/alerts/data/alert_model.dart'"
    
    $content = $content -replace "import '\.\.\/\.\.\/data\/repositories\/alert_repository_impl\.dart'", "import '../../../alerts/data/alert_repository_impl.dart'"
    $content = $content -replace "import 'package:smart_store\/data\/repositories\/alert_repository_impl\.dart'", "import 'package:smart_store/features/alerts/data/alert_repository_impl.dart'"
    
    # Settings imports
    $content = $content -replace "import '\.\.\/\.\.\/\.\.\/domain\/entities\/settings\.dart'", "import '../../domain/settings.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/domain\/entities\/settings\.dart'", "import '../../../settings/domain/settings.dart'"
    $content = $content -replace "import 'package:smart_store\/domain\/entities\/settings\.dart'", "import 'package:smart_store/features/settings/domain/settings.dart'"
    
    $content = $content -replace "import '\.\.\/\.\.\/\.\.\/domain\/repositories\/settings_repository\.dart'", "import '../../domain/settings_repository.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/domain\/repositories\/settings_repository\.dart'", "import '../../../settings/domain/settings_repository.dart'"
    $content = $content -replace "import 'package:smart_store\/domain\/repositories\/settings_repository\.dart'", "import 'package:smart_store/features/settings/domain/settings_repository.dart'"
    
    $content = $content -replace "import '\.\.\/\.\.\/\.\.\/data\/models\/settings_model\.dart'", "import '../../data/settings_model.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/data\/models\/settings_model\.dart'", "import '../../../settings/data/settings_model.dart'"
    $content = $content -replace "import 'package:smart_store\/data\/models\/settings_model\.dart'", "import 'package:smart_store/features/settings/data/settings_model.dart'"
    
    $content = $content -replace "import '\.\.\/\.\.\/data\/repositories\/settings_repository_impl\.dart'", "import '../../../settings/data/settings_repository_impl.dart'"
    $content = $content -replace "import 'package:smart_store\/data\/repositories\/settings_repository_impl\.dart'", "import 'package:smart_store/features/settings/data/settings_repository_impl.dart'"
    
    # Backup imports
    $content = $content -replace "import '\.\.\/\.\.\/\.\.\/domain\/repositories\/backup_repository\.dart'", "import '../../domain/backup_repository.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/domain\/repositories\/backup_repository\.dart'", "import '../../../backup/domain/backup_repository.dart'"
    $content = $content -replace "import 'package:smart_store\/domain\/repositories\/backup_repository\.dart'", "import 'package:smart_store/features/backup/domain/backup_repository.dart'"
    
    $content = $content -replace "import '\.\.\/\.\.\/data\/repositories\/backup_repository_impl\.dart'", "import '../../../backup/data/backup_repository_impl.dart'"
    $content = $content -replace "import 'package:smart_store\/data\/repositories\/backup_repository_impl\.dart'", "import 'package:smart_store/features/backup/data/backup_repository_impl.dart'"
    
    # Controllers
    $content = $content -replace "import '\.\.\/controllers\/product_controller\.dart'", "import '../product_controller.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/presentation\/controllers\/product_controller\.dart'", "import '../../../products/presentation/product_controller.dart'"
    $content = $content -replace "import 'package:smart_store\/presentation\/controllers\/product_controller\.dart'", "import 'package:smart_store/features/products/presentation/product_controller.dart'"
    
    $content = $content -replace "import '\.\.\/controllers\/price_controller\.dart'", "import '../price_controller.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/presentation\/controllers\/price_controller\.dart'", "import '../../../prices/presentation/price_controller.dart'"
    $content = $content -replace "import 'package:smart_store\/presentation\/controllers\/price_controller\.dart'", "import 'package:smart_store/features/prices/presentation/price_controller.dart'"
    
    $content = $content -replace "import '\.\.\/controllers\/alert_controller\.dart'", "import '../alert_controller.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/presentation\/controllers\/alert_controller\.dart'", "import '../../../alerts/presentation/alert_controller.dart'"
    $content = $content -replace "import 'package:smart_store\/presentation\/controllers\/alert_controller\.dart'", "import 'package:smart_store/features/alerts/presentation/alert_controller.dart'"
    
    $content = $content -replace "import '\.\.\/controllers\/settings_controller\.dart'", "import '../settings_controller.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/presentation\/controllers\/settings_controller\.dart'", "import '../../../settings/presentation/settings_controller.dart'"
    $content = $content -replace "import 'package:smart_store\/presentation\/controllers\/settings_controller\.dart'", "import 'package:smart_store/features/settings/presentation/settings_controller.dart'"
    
    $content = $content -replace "import '\.\.\/controllers\/barcode_controller\.dart'", "import '../barcode_controller.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/presentation\/controllers\/barcode_controller\.dart'", "import '../../../barcode/presentation/barcode_controller.dart'"
    $content = $content -replace "import 'package:smart_store\/presentation\/controllers\/barcode_controller\.dart'", "import 'package:smart_store/features/barcode/presentation/barcode_controller.dart'"
    
    $content = $content -replace "import '\.\.\/controllers\/backup_controller\.dart'", "import '../backup_controller.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/presentation\/controllers\/backup_controller\.dart'", "import '../../../backup/presentation/backup_controller.dart'"
    $content = $content -replace "import 'package:smart_store\/presentation\/controllers\/backup_controller\.dart'", "import 'package:smart_store/features/backup/presentation/backup_controller.dart'"
    
    # Providers
    $content = $content -replace "import '\.\.\/providers\/product_provider\.dart'", "import '../product_provider.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/presentation\/providers\/product_provider\.dart'", "import '../../../products/presentation/product_provider.dart'"
    $content = $content -replace "import 'package:smart_store\/presentation\/providers\/product_provider\.dart'", "import 'package:smart_store/features/products/presentation/product_provider.dart'"
    
    $content = $content -replace "import '\.\.\/providers\/price_provider\.dart'", "import '../price_provider.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/presentation\/providers\/price_provider\.dart'", "import '../../../prices/presentation/price_provider.dart'"
    $content = $content -replace "import 'package:smart_store\/presentation\/providers\/price_provider\.dart'", "import 'package:smart_store/features/prices/presentation/price_provider.dart'"
    
    $content = $content -replace "import '\.\.\/providers\/alert_provider\.dart'", "import '../alert_provider.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/presentation\/providers\/alert_provider\.dart'", "import '../../../alerts/presentation/alert_provider.dart'"
    $content = $content -replace "import 'package:smart_store\/presentation\/providers\/alert_provider\.dart'", "import 'package:smart_store/features/alerts/presentation/alert_provider.dart'"
    
    $content = $content -replace "import '\.\.\/providers\/settings_provider\.dart'", "import '../settings_provider.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/presentation\/providers\/settings_provider\.dart'", "import '../../../settings/presentation/settings_provider.dart'"
    $content = $content -replace "import 'package:smart_store\/presentation\/providers\/settings_provider\.dart'", "import 'package:smart_store/features/settings/presentation/settings_provider.dart'"
    
    $content = $content -replace "import '\.\.\/providers\/repositories_provider\.dart'", "import '../../../shared/providers/repositories_provider.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/presentation\/providers\/repositories_provider\.dart'", "import '../../../shared/providers/repositories_provider.dart'"
    $content = $content -replace "import 'package:smart_store\/presentation\/providers\/repositories_provider\.dart'", "import 'package:smart_store/shared/providers/repositories_provider.dart'"
    
    # Screens
    $content = $content -replace "import '\.\.\/screens\/products\/products_screen\.dart'", "import '../../../products/presentation/screens/products_screen.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/presentation\/screens\/products\/products_screen\.dart'", "import '../../../products/presentation/screens/products_screen.dart'"
    $content = $content -replace "import 'package:smart_store\/presentation\/screens\/products\/products_screen\.dart'", "import 'package:smart_store/features/products/presentation/screens/products_screen.dart'"
    
    $content = $content -replace "import '\.\.\/screens\/products\/add_product_screen\.dart'", "import '../../../products/presentation/screens/add_product_screen.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/presentation\/screens\/products\/add_product_screen\.dart'", "import '../../../products/presentation/screens/add_product_screen.dart'"
    $content = $content -replace "import 'package:smart_store\/presentation\/screens\/products\/add_product_screen\.dart'", "import 'package:smart_store/features/products/presentation/screens/add_product_screen.dart'"
    
    $content = $content -replace "import '\.\.\/screens\/products\/product_details_screen\.dart'", "import '../../../products/presentation/screens/product_details_screen.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/presentation\/screens\/products\/product_details_screen\.dart'", "import '../../../products/presentation/screens/product_details_screen.dart'"
    $content = $content -replace "import 'package:smart_store\/presentation\/screens\/products\/product_details_screen\.dart'", "import 'package:smart_store/features/products/presentation/screens/product_details_screen.dart'"
    
    $content = $content -replace "import '\.\.\/screens\/alerts\/alerts_screen\.dart'", "import '../../../alerts/presentation/screens/alerts_screen.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/presentation\/screens\/alerts\/alerts_screen\.dart'", "import '../../../alerts/presentation/screens/alerts_screen.dart'"
    $content = $content -replace "import 'package:smart_store\/presentation\/screens\/alerts\/alerts_screen\.dart'", "import 'package:smart_store/features/alerts/presentation/screens/alerts_screen.dart'"
    
    $content = $content -replace "import '\.\.\/screens\/settings\/settings_screen\.dart'", "import '../../../settings/presentation/screens/settings_screen.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/presentation\/screens\/settings\/settings_screen\.dart'", "import '../../../settings/presentation/screens/settings_screen.dart'"
    $content = $content -replace "import 'package:smart_store\/presentation\/screens\/settings\/settings_screen\.dart'", "import 'package:smart_store/features/settings/presentation/screens/settings_screen.dart'"
    
    $content = $content -replace "import '\.\.\/screens\/barcode\/barcode_scanner_screen\.dart'", "import '../../../barcode/presentation/screens/barcode_scanner_screen.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/presentation\/screens\/barcode\/barcode_scanner_screen\.dart'", "import '../../../barcode/presentation/screens/barcode_scanner_screen.dart'"
    $content = $content -replace "import 'package:smart_store\/presentation\/screens\/barcode\/barcode_scanner_screen\.dart'", "import 'package:smart_store/features/barcode/presentation/screens/barcode_scanner_screen.dart'"
    
    $content = $content -replace "import '\.\.\/screens\/dashboard\/dashboard_screen\.dart'", "import '../../../dashboard/presentation/dashboard_screen.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/presentation\/screens\/dashboard\/dashboard_screen\.dart'", "import '../../../dashboard/presentation/dashboard_screen.dart'"
    $content = $content -replace "import 'package:smart_store\/presentation\/screens\/dashboard\/dashboard_screen\.dart'", "import 'package:smart_store/features/dashboard/presentation/dashboard_screen.dart'"
    
    # Services
    $content = $content -replace "import '\.\.\/services\/alert_service\.dart'", "import '../alert_service.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/presentation\/services\/alert_service\.dart'", "import '../../../alerts/presentation/alert_service.dart'"
    $content = $content -replace "import 'package:smart_store\/presentation\/services\/alert_service\.dart'", "import 'package:smart_store/features/alerts/presentation/alert_service.dart'"
    
    # Theme
    $content = $content -replace "import '\.\.\/theme\/app_theme\.dart'", "import '../../../shared/presentation/theme/app_theme.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/presentation\/theme\/app_theme\.dart'", "import '../../../shared/presentation/theme/app_theme.dart'"
    $content = $content -replace "import 'package:smart_store\/presentation\/theme\/app_theme\.dart'", "import 'package:smart_store/shared/presentation/theme/app_theme.dart'"
    
    # Widgets
    $content = $content -replace "import '\.\.\/widgets\/common\/error_widget\.dart'", "import '../../../shared/presentation/widgets/common/error_widget.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/presentation\/widgets\/common\/error_widget\.dart'", "import '../../../shared/presentation/widgets/common/error_widget.dart'"
    $content = $content -replace "import 'package:smart_store\/presentation\/widgets\/common\/error_widget\.dart'", "import 'package:smart_store/shared/presentation/widgets/common/error_widget.dart'"
    
    $content = $content -replace "import '\.\.\/widgets\/common\/loading_widget\.dart'", "import '../../../shared/presentation/widgets/common/loading_widget.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/presentation\/widgets\/common\/loading_widget\.dart'", "import '../../../shared/presentation/widgets/common/loading_widget.dart'"
    $content = $content -replace "import 'package:smart_store\/presentation\/widgets\/common\/loading_widget\.dart'", "import 'package:smart_store/shared/presentation/widgets/common/loading_widget.dart'"
    
    $content = $content -replace "import '\.\.\/widgets\/common\/gradient_container\.dart'", "import '../../../shared/presentation/widgets/common/gradient_container.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/presentation\/widgets\/common\/gradient_container\.dart'", "import '../../../shared/presentation/widgets/common/gradient_container.dart'"
    $content = $content -replace "import 'package:smart_store\/presentation\/widgets\/common\/gradient_container\.dart'", "import 'package:smart_store/shared/presentation/widgets/common/gradient_container.dart'"
    
    $content = $content -replace "import '\.\.\/widgets\/common\/stat_card\.dart'", "import '../../../shared/presentation/widgets/common/stat_card.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/presentation\/widgets\/common\/stat_card\.dart'", "import '../../../shared/presentation/widgets/common/stat_card.dart'"
    $content = $content -replace "import 'package:smart_store\/presentation\/widgets\/common\/stat_card\.dart'", "import 'package:smart_store/shared/presentation/widgets/common/stat_card.dart'"
    
    $content = $content -replace "import '\.\.\/widgets\/product\/product_card\.dart'", "import '../widgets/product_card.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/presentation\/widgets\/product\/product_card\.dart'", "import '../../../products/presentation/widgets/product_card.dart'"
    $content = $content -replace "import 'package:smart_store\/presentation\/widgets\/product\/product_card\.dart'", "import 'package:smart_store/features/products/presentation/widgets/product_card.dart'"
    
    # Database
    $content = $content -replace "import '\.\.\/\.\.\/data\/database\/database_helper\.dart'", "import 'package:smart_store/core/data/database_helper.dart'"
    $content = $content -replace "import '\.\.\/\.\.\/\.\.\/data\/database\/database_helper\.dart'", "import 'package:smart_store/core/data/database_helper.dart'"
    $content = $content -replace "import 'package:smart_store\/data\/database\/database_helper\.dart'", "import 'package:smart_store/core/data/database_helper.dart'"
    
    # Write back if modified
    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        Write-Host "Updated: $($file.FullName)"
    }
}

Write-Host "`nAll imports updated successfully!"
