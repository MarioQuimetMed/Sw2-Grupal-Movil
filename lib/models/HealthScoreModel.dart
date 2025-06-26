// To parse this JSON data, do
//
//     final heatlhScore = heatlhScoreFromJson(jsonString);

import 'dart:convert';

HeatlhScore heatlhScoreFromJson(String str) =>
    HeatlhScore.fromJson(json.decode(str));

String heatlhScoreToJson(HeatlhScore data) => json.encode(data.toJson());

class HeatlhScore {
  Scores scores;
  int totalScore;
  String healthLevel;

  HeatlhScore({
    required this.scores,
    required this.totalScore,
    required this.healthLevel,
  });

  factory HeatlhScore.fromJson(Map<String, dynamic> json) => HeatlhScore(
        scores: Scores.fromJson(json["scores"]),
        totalScore: json["totalScore"],
        healthLevel: json["healthLevel"],
      );

  Map<String, dynamic> toJson() => {
        "scores": scores.toJson(),
        "totalScore": totalScore,
        "healthLevel": healthLevel,
      };
}

class Scores {
  double balancePositivo;
  double pagoFacturasATiempo;
  double ahorrosLiquidos;
  double deudaSostenible;
  double planificacion;

  Scores({
    required this.balancePositivo,
    required this.pagoFacturasATiempo,
    required this.ahorrosLiquidos,
    required this.deudaSostenible,
    required this.planificacion,
  });

  factory Scores.fromJson(Map<String, dynamic> json) => Scores(
        balancePositivo: json["balancePositivo"]?.toDouble(),
        pagoFacturasATiempo: json["pagoFacturasATiempo"]?.toDouble(),
        ahorrosLiquidos: json["ahorrosLiquidos"]?.toDouble(),
        deudaSostenible: json["deudaSostenible"]?.toDouble(),
        planificacion: json["planificacion"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "balancePositivo": balancePositivo,
        "pagoFacturasATiempo": pagoFacturasATiempo,
        "ahorrosLiquidos": ahorrosLiquidos,
        "deudaSostenible": deudaSostenible,
        "planificacion": planificacion,
      };
}
