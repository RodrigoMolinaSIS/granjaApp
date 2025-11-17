import 'package:flutter/material.dart';

class FoodListScreen extends StatelessWidget {
  final List<Map<String, String>> platos = [
    {'nombre': 'Plato 1', 'endpoint': 'comida1'},
    {'nombre': 'Plato 2', 'endpoint': 'comida2'},
    {'nombre': 'Plato 3', 'endpoint': 'comida3'},
    {'nombre': 'Plato 4', 'endpoint': 'comida4'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comida'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Selecciona un plato para ver estadísticas',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: platos.length,
                itemBuilder: (context, index) {
                  final plato = platos[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.restaurant, color: Colors.orangeAccent),
                      title: Text(plato['nombre']!),
                      subtitle: Text('Ver nivel de comida'),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/stats',
                        arguments: plato['endpoint'],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.white,
              ),
              child: Text('Inicio'),
            ),
          ],
        ),
      ),
    );
  }
}