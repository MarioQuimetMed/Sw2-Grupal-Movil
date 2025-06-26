// To parse this JSON data, do
//
//     final suggestionsGet = suggestionsGetFromJson(jsonString);

import 'dart:convert';

SuggestionsGet suggestionsGetFromJson(String str) =>
    SuggestionsGet.fromJson(json.decode(str));

String suggestionsGetToJson(SuggestionsGet data) => json.encode(data.toJson());

class SuggestionsGet {
  List<String> suggestions;

  SuggestionsGet({
    required this.suggestions,
  });

  factory SuggestionsGet.fromJson(Map<String, dynamic> json) => SuggestionsGet(
        suggestions: List<String>.from(json["suggestions"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "suggestions": List<dynamic>.from(suggestions.map((x) => x)),
      };
}
