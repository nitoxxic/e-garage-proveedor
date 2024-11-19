class adminGarage {
  String? idAdmin;
  String? idGarage;

  adminGarage({required this.idAdmin, required this.idGarage});

  Map<String, dynamic> toFirestore() {
    return {
      if (idAdmin != null) "idAdmin": idAdmin,
      if (idGarage != null) "idGarage": idGarage,
    };
  }
}