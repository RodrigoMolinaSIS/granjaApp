
import 'package:flutter/material.dart';

class DetectionsScreen extends StatelessWidget {
  final List<String> detections = ['Detección 1','Detección 2','Detección 3','Detección 4'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detecciones')),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: List.generate(4, (i) {
                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/messages'),
                    child: Column(
                      children: [
                        Expanded(child: Image.asset('assets/images/camera${(i%4)+1}.png', fit: BoxFit.cover)),
                        SizedBox(height: 8),
                        Text(detections[i]),
                      ],
                    ),
                  );
                }),
              ),
            ),
            ElevatedButton(onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/')), child: Text('Inicio')),
          ],
        ),
      ),
    );
  }
}
