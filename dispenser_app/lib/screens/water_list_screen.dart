import 'package:flutter/material.dart';

class WaterListScreen extends StatelessWidget {
  final List<Map<String, String>> vasos = [
    {'nombre': 'Vaso 1', 'endpoint': 'vaso1'},
    {'nombre': 'Vaso 2', 'endpoint': 'vaso2'},
    {'nombre': 'Vaso 3', 'endpoint': 'vaso3'},
    {'nombre': 'Vaso 4', 'endpoint': 'vaso4'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agua'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Selecciona un vaso para ver estadísticas',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: vasos.length,
                itemBuilder: (context, index) {
                  final vaso = vasos[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.water_drop, color: Colors.blueAccent),
                      title: Text(vaso['nombre']!),
                      subtitle: Text('Ver nivel de agua'),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/stats',
                        arguments: vaso['endpoint'],
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
                backgroundColor: Colors.blueAccent,
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