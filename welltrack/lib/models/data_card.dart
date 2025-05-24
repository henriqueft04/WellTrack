import 'package:flutter/material.dart';

class DataCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;

  const DataCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32),
        const SizedBox(height: 4),

        // Só mostramos o valor aqui — mas ele é formatado fora
        Text(
          _formattedValue(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        Text(label),
      ],
    );
  }

  // A formatação simples para mostrar corretamente, 
  //mas ainda temos acesso ao double (por causa de StatsPage)
  String _formattedValue() {
    if (label.toLowerCase() == 'distance') {
      return "${value.toStringAsFixed(1)} km";
    } else {
      return value.toInt().toString();
    }
  }
}
