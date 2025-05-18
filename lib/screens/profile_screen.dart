import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fit_agent/widgets/custom_bottom_navigation.dart';
import 'package:fit_agent/themes/app_theme.dart';
import 'package:fit_agent/models/user.dart';
import 'package:fit_agent/services/user_service.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late UserProfile _user;
  bool _isEditing = false;
  bool _isLoading = true;
  bool _saving = false;
  
  // Para manejo de imagen
  final ImagePicker _picker = ImagePicker();
  String? _imagePath;
  File? _imageFile;

  // Controladores
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  DateTime? _fechaNacimiento;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }
  
  // Obtener la imagen de perfil
  ImageProvider? _getProfileImage() {
    if (_imagePath != null) {
      return FileImage(File(_imagePath!));
    } else if (_user.fotoPerfil != null && _user.fotoPerfil!.isNotEmpty) {
      if (_user.fotoPerfil!.startsWith('http')) {
        return NetworkImage(_user.fotoPerfil!);
      } else {
        return FileImage(File(_user.fotoPerfil!));
      }
    }
    return null;
  }

  Future<void> _loadUser() async {
    final user = await UserService.loadUser();
    setState(() {
      _user = user;
      _nombreController.text = user.nombre;
      _emailController.text = user.email;
      _alturaController.text = user.altura?.toString() ?? '';
      _pesoController.text = user.peso?.toString() ?? '';
      _fechaNacimiento = user.fechaNacimiento;
      _isLoading = false;
    });
  }

  // Calcular edad
  int? get _edad {
    if (_fechaNacimiento == null) return null;
    final hoy = DateTime.now();
    int edad = hoy.year - _fechaNacimiento!.year;
    if (hoy.month < _fechaNacimiento!.month || (hoy.month == _fechaNacimiento!.month && hoy.day < _fechaNacimiento!.day)) {
      edad--;
    }
    return edad;
  }

  // Calcular IMC
  double? get _imc {
    final altura = double.tryParse(_alturaController.text.replaceAll(',', '.'));
    final peso = double.tryParse(_pesoController.text.replaceAll(',', '.'));
    if (altura == null || peso == null || altura <= 0) return null;
    return peso / ((altura / 100) * (altura / 100));
  }

  String get _interpretacionIMC {
    final imc = _imc;
    if (imc == null) return '';
    if (imc < 18.5) return 'Bajo peso';
    if (imc < 25) return 'Normal';
    if (imc < 30) return 'Sobrepeso';
    return 'Obesidad';
  }

  // Método para seleccionar una imagen
  Future<void> _seleccionarImagen() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
      );
      
      if (pickedFile != null) {
        setState(() {
          _imagePath = pickedFile.path;
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al seleccionar imagen')),
      );
    }
  }
  
  Future<void> _guardarPerfil() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _saving = true; });
    final user = UserProfile(
      nombre: _nombreController.text.trim(),
      email: _emailController.text.trim(),
      fechaNacimiento: _fechaNacimiento,
      altura: double.tryParse(_alturaController.text.replaceAll(',', '.')),
      peso: double.tryParse(_pesoController.text.replaceAll(',', '.')),
      fotoPerfil: _imagePath ?? _user.fotoPerfil,
      vegetariano: _user.vegetariano,
      vegano: _user.vegano,
      sinGluten: _user.sinGluten,
      sinLactosa: _user.sinLactosa,
      alergias: _user.alergias,
      nivelCalorico: _user.nivelCalorico,
      tiempoMaximoPreparacion: _user.tiempoMaximoPreparacion,
    );
    await UserService.saveUser(user);
    setState(() {
      _user = user;
      _isEditing = false;
      _saving = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil guardado correctamente')),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _alturaController.dispose();
    _pesoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: AppTheme.verdeMedio,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() { _isEditing = !_isEditing; });
            },
            tooltip: _isEditing ? 'Cancelar' : 'Editar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto de perfil
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppTheme.verdeMedio,
                      backgroundImage: _getProfileImage(),
                      child: (_user.fotoPerfil == null && _imagePath == null) ? const Icon(
                        Icons.person,
                        size: 80,
                        color: AppTheme.blanco,
                      ) : null,
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _seleccionarImagen,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.naranjaAccion,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            padding: const EdgeInsets.all(6),
                            child: const Icon(Icons.photo_camera, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  _user.nombre.isEmpty ? 'Usuario' : _user.nombre,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _user.email.isEmpty ? 'usuario@ejemplo.com' : _user.email,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Datos Personales', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 16),
                      _buildEditableField(
                        controller: _nombreController,
                        label: 'Nombre',
                        icon: Icons.person_outline,
                        enabled: _isEditing,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Ingrese su nombre' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildEditableField(
                        controller: _emailController,
                        label: 'Correo electrónico',
                        icon: Icons.email_outlined,
                        enabled: _isEditing,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Ingrese su email' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildDateField(
                        label: 'Fecha de nacimiento',
                        icon: Icons.cake_outlined,
                        date: _fechaNacimiento,
                        enabled: _isEditing,
                        onTap: _isEditing ? () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _fechaNacimiento ?? DateTime(2000, 1, 1),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() { _fechaNacimiento = picked; });
                          }
                        } : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildEditableField(
                              controller: _alturaController,
                              label: 'Altura (cm)',
                              icon: Icons.height_outlined,
                              enabled: _isEditing,
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                final val = double.tryParse(v!.replaceAll(',', '.'));
                                if (val == null || val < 100 || val > 250) return 'Altura inválida';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildEditableField(
                              controller: _pesoController,
                              label: 'Peso (kg)',
                              icon: Icons.monitor_weight_outlined,
                              enabled: _isEditing,
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                final val = double.tryParse(v!.replaceAll(',', '.'));
                                if (val == null || val < 30 || val > 300) return 'Peso inválido';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Botón de guardar cambios (solo visible en modo edición)
              if (_isEditing)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _guardarPerfil,
                      icon: _saving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.save),
                      label: const Text('Guardar cambios'),
                    ),
                  ),
                ),
              
              const SizedBox(height: 18),
              // IMC y edad
              Row(
                children: [
                  Expanded(
                    child: Card(
                      color: AppTheme.verdeClaro,
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(Icons.cake, color: AppTheme.verdeOscuro),
                            const SizedBox(height: 6),
                            Text('Edad', style: TextStyle(fontWeight: FontWeight.w600)),
                            Text(_edad?.toString() ?? '--', style: const TextStyle(fontSize: 20)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      color: AppTheme.azulSuave,
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(Icons.monitor_heart, color: AppTheme.azulBoton),
                            const SizedBox(height: 6),
                            Text('IMC', style: TextStyle(fontWeight: FontWeight.w600)),
                            Text(_imc == null ? '--' : _imc!.toStringAsFixed(1), style: const TextStyle(fontSize: 20)),
                            Text(_interpretacionIMC, style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Preferencias
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Preferencias', style: Theme.of(context).textTheme.titleMedium),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, 'preferences');
                            },
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Editar'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (_user.vegetariano) _buildPrefChip('Vegetariano', Icons.eco),
                          if (_user.vegano) _buildPrefChip('Vegano', Icons.spa),
                          if (_user.sinGluten) _buildPrefChip('Sin gluten', Icons.no_food),
                          if (_user.sinLactosa) _buildPrefChip('Sin lactosa', Icons.icecream),
                          ..._user.alergias.map((a) => _buildPrefChip(a, Icons.warning)),
                          if (!_user.vegetariano && !_user.vegano && !_user.sinGluten && !_user.sinLactosa && _user.alergias.isEmpty)
                            const Text('Sin preferencias específicas'),
                          
                          // Mostrar mensaje informativo si no hay preferencias seleccionadas pero el usuario puede editarlas
                          if (!_user.vegetariano && !_user.vegano && !_user.sinGluten && !_user.sinLactosa && _user.alergias.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Haz clic en "Editar" para configurar tus preferencias dietéticas',
                                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: AppTheme.grisTexto),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 2),
    );
  }

  Widget _buildEditableField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: enabled ? Colors.white : AppTheme.grisClaro,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required IconData icon,
    DateTime? date,
    bool enabled = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: enabled ? Colors.white : AppTheme.grisClaro,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        child: Text(
          date == null ? 'Sin definir' : DateFormat('dd/MM/yyyy').format(date),
          style: TextStyle(
            color: enabled ? Colors.black87 : AppTheme.grisTexto,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPrefChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, color: AppTheme.verdeMedio, size: 18),
      label: Text(label),
      backgroundColor: AppTheme.verdeClaro.withOpacity(0.7),
      labelStyle: const TextStyle(fontWeight: FontWeight.w500),
    );
  }
}

