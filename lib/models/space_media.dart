import 'package:hive/hive.dart';

part 'space_media.g.dart';

// TODO: se funziona provare a cancellare space_media.g.dart e tutti i campi che non servono
// tenendo quindi solo date e hdImageUrl

@HiveType(typeId: 0)
class SpaceMedia {
  @HiveField(0)
  final DateTime date;
  @HiveField(1)
  final String type;
  @HiveField(2)
  final String url;
  @HiveField(3)
  final String hdImageUrl;
  @HiveField(4)
  final String description;
  @HiveField(5)
  final String title;
  @HiveField(6)
  final String credits;

  SpaceMedia({
    required this.date,
    required this.type,
    required this.url,
    required this.description,
    required this.title,
    required this.credits,
    required this.hdImageUrl,
  });
}
