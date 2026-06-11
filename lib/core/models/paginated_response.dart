class PaginatedResponse<T> {
  final List<T> items;
  final String? nextCursor;
  final bool hasMore;

  PaginatedResponse({
    required this.items,
    this.nextCursor,
    required this.hasMore,
  });
}
