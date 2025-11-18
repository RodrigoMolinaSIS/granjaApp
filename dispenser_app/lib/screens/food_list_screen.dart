import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FoodListScreen extends StatefulWidget {
  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  final double vaseWidth = 170.0;
  final double vaseHeight = 320.0;

  bool isReloading = false;
  List<Offset> granos = [];
  final int totalGranos = 600;
  Random random = Random();

  double foodLevel = 0.0; // de 0 a vaseHeight

  late Timer timer;

  final String apiBase = "http://localhost/thermal_api/comida_api.php"; // <-- CAMBIAR AQUÍ

  @override
  void initState() {
    super.initState();
    fetchFoodLevel(); // carga nivel inicial desde servidor
  }

  @override
  void dispose() {
    if (timer.isActive) timer.cancel();
    super.dispose();
  }

  // ----------------------------------------------------------
  //              API: obtener nivel desde servidor
  // ----------------------------------------------------------
  Future<void> fetchFoodLevel() async {
    try {
      final res = await http.get(Uri.parse(apiBase));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        double porcentaje = ((data["nivel_comida"] ?? 0.0).toDouble())/100;

        setState(() {
          foodLevel = porcentaje * vaseHeight;
        });
      }
    } catch (e) {
      print("ERROR FETCH FOOD: $e");
    }
  }

  // ----------------------------------------------------------
  //              API: enviar recarga al servidor
  // ----------------------------------------------------------
  Future<void> sendRefillRequest() async {
    try {
      await http.post(Uri.parse("$apiBase/api/refill-food"));
    } catch (e) {
      print("ERROR POST REFILL: $e");
    }
  }

  // ----------------------------------------------------------
  //                Animar recarga visual
  // ----------------------------------------------------------
  void _recargarComida() async {
    if (isReloading) return;

    setState(() {
      isReloading = true;
      granos.clear();
      foodLevel = 0.0;
    });

    // avisar al servidor
    await sendRefillRequest();

    int generated = 0;

    timer = Timer.periodic(Duration(milliseconds: 15), (t) {
      setState(() {
        if (foodLevel < vaseHeight) {
          foodLevel += 2.0;
          if (foodLevel > vaseHeight) foodLevel = vaseHeight;

          // generar granos según nivel actual
          int target = (foodLevel / vaseHeight * totalGranos).toInt();
          while (granos.length < target) {
            double x = random.nextDouble() * vaseWidth;
            granos.add(Offset(x, vaseHeight));
            generated++;
          }

          // caída animada
          granos = granos.map((g) {
            double newY = g.dy - random.nextDouble() * 5 - 1;
            double minY = vaseHeight - foodLevel;
            if (newY < minY) newY = minY;
            return Offset(g.dx, newY);
          }).toList();
        } else {
          foodLevel = vaseHeight;
          isReloading = false;
          t.cancel();

          // refrescar nivel real desde servidor
          fetchFoodLevel();
        }
      });
    });
  }

  // ----------------------------------------------------------
  //                        UI
  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Comida de Gallinas"),
        backgroundColor: Colors.orangeAccent,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                "NIVEL DE COMIDA",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),

              // Contenedor principal
              Container(
                width: 200,
                height: 350,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // fondo del vaso
                    Container(
                      width: 180,
                      height: vaseHeight,
                      decoration: BoxDecoration(
                        color: Colors.purple[200],
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.purple, width: 3),
                      ),
                    ),

                    // Comida base
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: 180,
                        height: foodLevel,
                        child: Image.asset(
                          'assets/images/granos.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // granos animados
                    ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        width: vaseWidth,
                        height: vaseHeight,
                        child: Stack(
                          children: [
                            ...granos.map((g) {
                              return Positioned(
                                left: g.dx,
                                bottom: g.dy,
                                child: SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: Image.asset('assets/images/grano.png'),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 18),

              Text(
                "Nivel: ${(100*foodLevel / vaseHeight ).toStringAsFixed(1)}%",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 25),

              ElevatedButton(
                onPressed: _recargarComida,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  isReloading ? "RECARGANDO..." : "RECARGAR",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
