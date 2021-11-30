class CrudResponse {
  final String? data;
  final String? error;
  final bool isOnline;

  const CrudResponse({
    this.data,
    this.error,
    this.isOnline = true,
  });
}
