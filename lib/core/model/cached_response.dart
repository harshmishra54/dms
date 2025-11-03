import 'package:isar/isar.dart';

part 'cached_response.g.dart';

@collection
class CachedResponse {
  Id id = Isar.autoIncrement;

  late String endpoint;
  String? data;           // store JSON string
  DateTime updatedAt = DateTime.now();
}
