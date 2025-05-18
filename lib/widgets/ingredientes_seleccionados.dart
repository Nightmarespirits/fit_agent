import 'package:flutter/material.dart';
import 'package:fit_agent/widgets/seleccion_ingredientes.dart';

class IngredientesSeleccionados extends StatelessWidget {
  final List<Ingrediente> ingredientes;
  final Function(Ingrediente) onRemoveIngrediente;
  final VoidCallback onGenerarReceta;

  const IngredientesSeleccionados({
    super.key,
    required this.ingredientes,
    required this.onRemoveIngrediente,
    required this.onGenerarReceta,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ingredientes seleccionados:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ingredientes.isEmpty
                ? const Center(
                    child: Text(
                      'No hay ingredientes seleccionados',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: ingredientes.length,
                    itemBuilder: (context, index) {
                      final ingrediente = ingredientes[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        leading: Image.network(
                          ingrediente.imagen,
                          width: 30,
                          height: 30,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image_not_supported);
                          },
                        ),
                        title: Text(ingrediente.nombre),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => onRemoveIngrediente(ingrediente),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: ingredientes.isEmpty ? null : onGenerarReceta,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'GENERAR RECETA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
