import 'package:flutter/material.dart';
import 'home_button.dart';
import 'info_box.dart';
import 'regulador_button.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
//import 'package:http/http.dart' as http;

class LightsScreen extends StatefulWidget {
  @override
  _LightsScreen createState() => _LightsScreen();
}

class _LightsScreen extends State<LightsScreen> {
  Map<String, dynamic>? data;
  String? jsonFile;
  bool isLoading = true;
  String errorMessage = '';

  // Variables de estado
  bool _luces1Estado = false;
  bool _luces2Estado = false;
  String _foff = 'assets/images/foff.png';
  String _fonn = 'assets/images/fonn.png';

  final String serverUrl = 'http://localhost/thermal_api'; // Usa tu IP

  @override
  void initState() {
    super.initState();
    _cargarDatosServidor();
  }

  Future<void> _cargarDatosServidor() async {
    try {
      setState(() { isLoading = true; errorMessage = ''; });

      final response = await http.get(
        Uri.parse('$serverUrl/luces_api.php'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        setState(() {
          data = jsonData;
          _luces1Estado = data?['luces1_estado'] ?? false;
          _luces2Estado = data?['luces2_estado'] ?? false;
          isLoading = false;
        });

        print('✅ Datos cargados desde servidor PHP');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }

    } catch (e) {
      print('❌ Error cargando datos: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Error conectando al servidor: $e';
      });
    }
  }

  // Guardar datos en el servidor PHP
  Future<void> _guardarCambiosServidor() async {
    try {
      // Preparar datos para enviar
      final Map<String, dynamic> nuevosDatos = {
        'luces1_estado': _luces1Estado,
        'luces2_estado': _luces2Estado,
        'ultima_actualizacion': DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('$serverUrl/api.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(nuevosDatos),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        setState(() {
          data = nuevosDatos;
        });

        print('💾 Datos guardados en servidor PHP: $nuevosDatos');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Configuración guardada en servidor'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }

    } catch (e) {
      print('❌ Error guardando datos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error conectando al servidor'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }



  // Métodos de cambio (actualizados para usar servidor PHP)
  void _cambiarEstadoLight1(bool nuevoEstado) {
    setState(() {
      _luces1Estado = nuevoEstado;
    });
    _guardarCambiosServidor();
  }

  void _cambiarEstadoLight2(bool nuevoEstado) {
    setState(() {
      _luces2Estado = nuevoEstado;
    });
    _guardarCambiosServidor();
  }

  String _cambiarImagen(bool nuevoEstado) {
    return nuevoEstado ? _fonn : _foff;


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ambientes'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _cargarDatosServidor,
            tooltip: 'Actualizar datos',
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _guardarCambiosServidor,
            tooltip: 'Guardar en servidor',
          ),
        ],
      ),
      body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/fondop.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(color: Colors.black.withOpacity(0.6)),

            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Panel de Control server",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Servidor: $serverUrl',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      'Última actualización: ${data?['ultima_actualizacion'] != null ?
                      DateTime.parse(data!['ultima_actualizacion']).toString().substring(0, 16) :
                      '--'}',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 20),

                    if (isLoading)
                      Column(
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text('Cargando datos...', style: TextStyle(color: Colors.white)),
                        ],
                      ),

                    if (errorMessage.isNotEmpty)
                      Column(
                        children: [
                          Icon(Icons.error, color: Colors.red, size: 50),
                          SizedBox(height: 16),
                          Text(errorMessage, style: TextStyle(color: Colors.white)),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _cargarDatosServidor,
                            child: Text('Reintentar'),
                          ),
                        ],
                      ),

                    if (!isLoading && errorMessage.isEmpty)
                      Expanded(
                        child: Wrap(
                          direction: Axis.vertical,
                          spacing: 20,
                          runSpacing: 20,
                          alignment: WrapAlignment.center,
                          children: [
                            // VENTILADOR - Switch
                            InfoBox(
                              title: 'luz1',
                              value: _luces1Estado ? 'ON' : 'OFF',
                              unit: '',
                              color: _luces1Estado ? Colors.greenAccent : Colors.redAccent,
                              height: 100,
                              width: 250,
                              child: Switch(
                                value: _luces1Estado,
                                onChanged: _cambiarEstadoLight1,
                                activeColor: Colors.green,
                                inactiveThumbColor: Colors.red,
                              ),
                            ),

                            // VELOCIDAD - Regulador
                            InfoBox(
                              title: 'luz2',
                              value: _luces2Estado ? 'ON' : 'OFF',
                              unit: '',
                              color: _luces2Estado ? Colors.greenAccent : Colors.redAccent,
                              height: 100,
                              width: 250,
                              child: Switch(
                                value: _luces2Estado,
                                onChanged: _cambiarEstadoLight2,
                                activeColor: Colors.green,
                                inactiveThumbColor: Colors.red,
                              ),
                            ),
                            // TEMPERATURA - Regulador
                            Container(
                              decoration: BoxDecoration(

                                image: DecorationImage(
                                  image: AssetImage(_cambiarImagen(_luces1Estado)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(

                                image: DecorationImage(
                                  image: AssetImage(_cambiarImagen(_luces2Estado)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            // HUMEDAD - Regulador

                          ],
                        ),
                      ),

                    const SizedBox(height: 16),
                    const Text(
                      'Sistema de monitoreo inteligente',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ]
      ),
    );
  }
}