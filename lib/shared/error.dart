class Error implements Exception {
  String cause;
  Error(this.cause);
  @override
  String toString() {
    return "$cause";
  }
}
