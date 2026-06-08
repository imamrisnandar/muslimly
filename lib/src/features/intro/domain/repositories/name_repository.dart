abstract interface class NameRepository {
  Future<void> saveName(String name);
  Future<String?> getName();
}
