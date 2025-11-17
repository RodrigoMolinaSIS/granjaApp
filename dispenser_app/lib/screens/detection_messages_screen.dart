
import 'package:flutter/material.dart';

class DetectionMessagesScreen extends StatelessWidget {
  final List<_Msg> messages = [
    _Msg(text: 'Plato 1 30% de alimento', time: '10:35'),
    _Msg(text: 'Se detectó animal: perro', time: '10:25', isAlert: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mensajes')),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final m = messages[index];

                    final container = Container(
                      margin: EdgeInsets.symmetric(vertical:6),
                      decoration: BoxDecoration(
                        color: m.isAlert ? Colors.red.shade200 : Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(m.text),
                          SizedBox(width: 12),
                          Text(m.time, style: TextStyle(fontSize:12)),
                        ],
                      ),
                    );

                    return Align(
                      alignment: Alignment.centerRight,
                      child: m.isAlert
                          ? GestureDetector(onTap: () => Navigator.pushNamed(context, '/detections'), child: container)
                          : container,
                    );
                  }
              ),
            ),
            ElevatedButton(onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/')), child: Text('Inicio')),
          ],
        ),
      ),
    );
  }
}

class _Msg {
  final String text;
  final String time;
  final bool isAlert;
  _Msg({required this.text, required this.time, this.isAlert=false});
}
