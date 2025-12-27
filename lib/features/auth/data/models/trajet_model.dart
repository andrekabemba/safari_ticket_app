class TrajetModel {
  final int id;
  final String depart;
  final String arrivee;
  final double prix;
  final String heure;

  TrajetModel({
    required this.id,
    required this.depart,
    required this.arrivee,
    required this.prix,
    required this.heure,
  });

  factory TrajetModel.fromJson(Map<String, dynamic> json) => TrajetModel(
    id: json['id'],
    depart: json['depart'],
    arrivee: json['arrivee'],
    prix: json['prix'].toDouble(),
    heure: json['heure_depart'],
  );
}

class TicketModel {
  final int id;
  final String nomPassager;
  final String depart;
  final String arrivee;
  final String heure;
  final double prix;

  TicketModel({
    required this.id,
    required this.nomPassager,
    required this.depart,
    required this.arrivee,
    required this.heure,
    required this.prix,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) => TicketModel(
    id: json['id'],
    nomPassager: json['nom'],
    depart: json['trajets']['depart'],
    arrivee: json['trajets']['arrivee'],
    heure: json['trajets']['heure_depart'],
    prix: json['trajets']['prix'].toDouble(),
  );
}
