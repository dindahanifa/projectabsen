// To parse this JSON data:
//
//     final trainingListResponse = trainingListResponseFromJson(jsonString);

import 'dart:convert';

List<TrainingModel> trainingListFromJson(String str) =>
    List<TrainingModel>.from(json.decode(str)["data"].map((x) => TrainingModel.fromJson(x)));

TrainingModel trainingDetailFromJson(String str) =>
    TrainingModel.fromJson(json.decode(str)["data"]);

String trainingModelToJson(TrainingModel data) => json.encode(data.toJson());

class TrainingModel {
  final int id;
  final String title;
  final String? description;
  final int? participantCount;
  final String? standard;
  final int? duration;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Unit>? units;
  final List<Activity>? activities;

  TrainingModel({
    required this.id,
    required this.title,
    this.description,
    this.participantCount,
    this.standard,
    this.duration,
    required this.createdAt,
    required this.updatedAt,
    this.units,
    this.activities,
  });

  factory TrainingModel.fromJson(Map<String, dynamic> json) => TrainingModel(
        id: json["id"],
        title: json["title"] ?? '',
        description: json["description"],
        participantCount: json["participant_count"],
        standard: json["standard"],
        duration: json["duration"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        units: json["units"] != null
            ? List<Unit>.from(json["units"].map((x) => Unit.fromJson(x)))
            : [],
        activities: json["activities"] != null
            ? List<Activity>.from(json["activities"].map((x) => Activity.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "participant_count": participantCount,
        "standard": standard,
        "duration": duration,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "units": units?.map((x) => x.toJson()).toList(),
        "activities": activities?.map((x) => x.toJson()).toList(),
      };
}

class Unit {
  final int id;
  final String name;

  Unit({required this.id, required this.name});

  factory Unit.fromJson(Map<String, dynamic> json) => Unit(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

class Activity {
  final int id;
  final String name;

  Activity({required this.id, required this.name});

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
