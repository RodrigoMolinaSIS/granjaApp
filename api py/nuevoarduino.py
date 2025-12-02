import socket
import requests
import json
import time

# CONFIGURACIÓN
HOST = '0.0.0.0'  # Escucha en todas las interfaces de red de tu PC
PORT = 5000       # Debe coincidir con el puerto en el código Arduino
URL_API = "http://localhost/thermal_api/muchoapi.php" 

print(f"Iniciando Servidor WiFi en puerto {PORT}...")
print("Esperando datos del Arduino...")

# Creamos el Socket TCP
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    try:
        s.bind((HOST, PORT))
        s.listen()
        
        while True:
            # Aceptamos conexión entrante del Arduino
            conn, addr = s.accept()
            with conn:
                print(f"\nConexión establecida desde {addr}")
                
                # Recibimos los datos
                # Buffer de 1024 bytes es suficiente para el JSON
                data = conn.recv(1024)
                
                if not data:
                    continue
                    
                raw_msg = data.decode('utf-8').strip()
                print(f"Recibido: {raw_msg}")
                
                # Intentamos parsear JSON y enviar a PHP
                try:
                    # Limpiamos posibles caracteres basura del ESP8266
                    # A veces llegan respuestas como "+IPD,len:..." antes del JSON
                    if "{" in raw_msg and "}" in raw_msg:
                        # Extraemos solo lo que está entre llaves
                        start = raw_msg.find("{")
                        end = raw_msg.rfind("}") + 1
                        json_str = raw_msg[start:end]
                        
                        data_dict = json.loads(json_str)
                        
                        # Convertir booleanos de Python a 1/0 para PHP si es necesario,
                        # aunque requests suele manejarlo bien.
                        
                        print("Enviando a PHP...")
                        response = requests.post(URL_API, data=data_dict, timeout=5)
                        print(f"Respuesta API: {response.text}")
                    else:
                        print("Datos recibidos no contienen un JSON válido.")

                except json.JSONDecodeError:
                    print("Error: El JSON está mal formado.")
                except requests.exceptions.RequestException as e:
                    print(f"Error conectando con PHP: {e}")
                    
    except KeyboardInterrupt:
        print("\nServidor detenido por usuario.")
    except Exception as e:
        print(f"\nError crítico del servidor: {e}")