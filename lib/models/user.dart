class UserProfile {
  String nombre;
  String email;
  DateTime? fechaNacimiento;
  double? altura; // en cm
  double? peso;   // en kg
  String? fotoPerfil; // URL o ruta de la imagen de perfil
  
  // Preferencias dietéticas
  bool vegetariano;
  bool vegano;
  bool sinGluten;
  bool sinLactosa;
  List<String> alergias;
  
  // Preferencias adicionales
  String nivelCalorico; // Bajo, Medio, Alto
  double tiempoMaximoPreparacion; // en minutos

  UserProfile({
    required this.nombre,
    required this.email,
    this.fechaNacimiento,
    this.altura,
    this.peso,
    this.fotoPerfil,
    this.vegetariano = false,
    this.vegano = false,
    this.sinGluten = false,
    this.sinLactosa = false,
    List<String>? alergias,
    this.nivelCalorico = 'Medio',
    this.tiempoMaximoPreparacion = 30.0,
  }) : alergias = alergias ?? [];

  factory UserProfile.empty() => UserProfile(
    nombre: '',
    email: '',
    fechaNacimiento: null,
    altura: null,
    peso: null,
    fotoPerfil: null,
    vegetariano: false,
    vegano: false,
    sinGluten: false,
    sinLactosa: false,
    alergias: [],
    nivelCalorico: 'Medio',
    tiempoMaximoPreparacion: 30.0,
  );

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'email': email,
    'fechaNacimiento': fechaNacimiento?.toIso8601String(),
    'altura': altura,
    'peso': peso,
    'fotoPerfil': fotoPerfil,
    'vegetariano': vegetariano,
    'vegano': vegano,
    'sinGluten': sinGluten,
    'sinLactosa': sinLactosa,
    'alergias': alergias,
    'nivelCalorico': nivelCalorico,
    'tiempoMaximoPreparacion': tiempoMaximoPreparacion,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    nombre: json['nombre'] ?? '',
    email: json['email'] ?? '',
    fechaNacimiento: json['fechaNacimiento'] != null
      ? DateTime.tryParse(json['fechaNacimiento'])
      : null,
    altura: (json['altura'] as num?)?.toDouble(),
    peso: (json['peso'] as num?)?.toDouble(),
    fotoPerfil: json['fotoPerfil'],
    vegetariano: json['vegetariano'] ?? false,
    vegano: json['vegano'] ?? false,
    sinGluten: json['sinGluten'] ?? false,
    sinLactosa: json['sinLactosa'] ?? false,
    alergias: List<String>.from(json['alergias'] ?? []),
    nivelCalorico: json['nivelCalorico'] ?? 'Medio',
    tiempoMaximoPreparacion: (json['tiempoMaximoPreparacion'] as num?)?.toDouble() ?? 30.0,
  );
}
