/// Enum for user roles in the app
enum Role {
  /// The app developer or platform owner
  /// Can add store owners and manage the platform
  systemAdmin,

  /// The merchant who owns a store
  /// Can manage products and assign workers
  storeOwner,

  /// The assistant or staff of a store
  /// Can only update the expiry date of products
  /// Can explore products
  worker,

// when user signup first time
  guest,
}
