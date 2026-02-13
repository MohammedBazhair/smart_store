/// Represents the status of a user's account in the system.
enum AccountStatus {
  /// The account is fully active.
  /// The user can log in and use all features normally.
  active,

  /// The account is temporarily frozen.
  /// The user may be allowed to log in but cannot perform certain actions.
  /// Example: due to pending verification, policy review, or temporary restriction.
  frozen,

  /// The account is pending verification.
  /// The user may not be allowed to log in until the account is verified.
  pending,
}
