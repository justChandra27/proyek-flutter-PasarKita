enum ProcessingPhase {
  none,
  locked,
  orderCreated,
  itemsCreated,
  committed;

  bool get needsRollback => this != committed;
}
