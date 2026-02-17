/// Enum for user roles in the app
enum Role {
  /// The merchant who owns a store
  /// Can manage products and assign workers
  storeOwner(label: 'صاحب المتجر'),

  /// The assistant or staff of a store
  /// Can only update the expiry date of products
  /// Can explore products
  worker(label: 'موظف'),

// when user signup first time
  guest(label: 'زائر');

  final String label;

  // ignore: sort_constructors_first
  const Role({required this.label});

  static Role fromString(String role) {
    return Role.values.byName(role);
  }
}
