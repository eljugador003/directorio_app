/// Usuario de JSONPlaceholder (`/users`).
///
/// `fromJson` lee la respuesta de la API y `toJson` genera el mismo formato,
/// por eso un favorito guardado en el telefono se vuelve a leer igual que si
/// viniera del servidor.
class User {
  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.website,
    required this.companyName,
    required this.companyCatchPhrase,
    required this.street,
    required this.suite,
    required this.city,
  });

  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String website;
  final String companyName;
  final String companyCatchPhrase;
  final String street;
  final String suite;
  final String city;

  factory User.fromJson(Map<String, dynamic> json) {
    final company = json['company'] as Map<String, dynamic>? ?? const {};
    final address = json['address'] as Map<String, dynamic>? ?? const {};
    return User(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      website: json['website'] as String? ?? '',
      companyName: company['name'] as String? ?? '',
      companyCatchPhrase: company['catchPhrase'] as String? ?? '',
      street: address['street'] as String? ?? '',
      suite: address['suite'] as String? ?? '',
      city: address['city'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'username': username,
        'email': email,
        'phone': phone,
        'website': website,
        'company': {
          'name': companyName,
          'catchPhrase': companyCatchPhrase,
        },
        'address': {
          'street': street,
          'suite': suite,
          'city': city,
        },
      };

  /// Iniciales para el avatar (p. ej. "Leanne Graham" -> "LG").
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  String get fullAddress =>
      [street, suite, city].where((part) => part.isNotEmpty).join(', ');
}
