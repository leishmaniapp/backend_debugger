class GenericError extends Error {
  String reason;
  GenericError(this.reason);

  @override
  String toString() => "$runtimeType: $reason";
}
