enum ModerationStatus {
  approved,
  rejected,
  pending,
  deactivated;

  bool get isActive => this == ModerationStatus.approved;

  String toJson() => name;

  static ModerationStatus fromJson(String value) {
    return ModerationStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ModerationStatus.approved,
    );
  }
}
