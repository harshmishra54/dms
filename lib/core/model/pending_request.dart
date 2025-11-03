import 'package:isar/isar.dart';

part 'pending_request.g.dart';

@collection
class PendingRequest {
  Id id = Isar.autoIncrement;

  late String method;
  late String endpoint;
  String? body;
  String? token; // ✅ store token snapshot
  DateTime? createdAt; // ✅ for sync ordering
}
