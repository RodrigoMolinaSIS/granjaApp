<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Manejar preflight request
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

// Archivo para guardar los datos
$dataFile = 'thermal_data.json';

// Datos iniciales
$defaultData = [
    'ventilador_estado' => false,
    'velocidad' => 0,
    'temperatura_deseada' => 22,
    'humedad_deseada' => 50,
    'ultima_actualizacion' => date('c')
];

// Función para leer datos del archivo
function leerDatos($archivo, $default) {
    if (file_exists($archivo)) {
        $contenido = file_get_contents($archivo);
        $datos = json_decode($contenido, true);
        if (json_last_error() === JSON_ERROR_NONE) {
            return $datos;
        }
    }
    return $default;
}

// Función para guardar datos en el archivo
function guardarDatos($archivo, $datos) {
    $datos['ultima_actualizacion'] = date('c');
    file_put_contents($archivo, json_encode($datos, JSON_PRETTY_PRINT));
    return $datos;
}

// Procesar request
try {
    $method = $_SERVER['REQUEST_METHOD'];
    
    switch ($method) {
        case 'GET':
            // Obtener datos actuales
            $datos = leerDatos($dataFile, $defaultData);
            
            // Log en consola
            error_log("📥 GET - Datos enviados: " . json_encode($datos));
            echo json_encode($datos);
            break;
            
        case 'POST':
            // Leer datos del body
            $input = file_get_contents('php://input');
            $nuevosDatos = json_decode($input, true);
            
            if (json_last_error() !== JSON_ERROR_NONE) {
                throw new Exception('JSON inválido');
            }
            
            // Combinar con datos existentes
            $datosActuales = leerDatos($dataFile, $defaultData);
            $datosActualizados = array_merge($datosActuales, $nuevosDatos);
            
            // Guardar datos
            $datosGuardados = guardarDatos($dataFile, $datosActualizados);
            
            // Log en consola
            error_log("💾 POST - Datos recibidos: " . $input);
            error_log("💾 POST - Datos guardados: " . json_encode($datosGuardados));
            
            echo json_encode([
                'success' => true,
                'message' => 'Datos guardados exitosamente',
                'data' => $datosGuardados
            ]);
            break;
            
        default:
            http_response_code(405);
            echo json_encode(['error' => 'Método no permitido']);
            break;
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
    error_log("❌ Error: " . $e->getMessage());
}
?>