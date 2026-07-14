class Remedy {
  final int id;
  final String name;
  final String description;
  final int quantity;
  final String hour;
  final int user;

  Remedy({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.hour,
    required this.user,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'quantity': quantity,
      'hour': hour,
      'user': user,
    };
  }

  factory Remedy.fromMap(Map<String, dynamic> map) {
    return Remedy(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      quantity: map['quantity'],
      hour: map['hour'],
      user: map['user'],
    );
  }
}
