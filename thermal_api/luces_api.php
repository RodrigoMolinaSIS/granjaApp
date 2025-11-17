<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

// Archivo para guardar los datos de luces
$dataFile = __DIR__ . '/luces_data.json';

// Datos iniciales para las luces
$defaultData = [
    'luces1_estado' => false,
    'luces2_estado' => false,
    'ultima_actualizacion' => date('c')
];

// FUNCIÓN: Crear archivo si no existe
function inicializarArchivo($archivo, $datosDefault) {
    if (!file_exists($archivo)) {
        error_log("📝 Creando archivo de luces: $archivo");
        $resultado = file_put_contents($archivo, json_encode($datosDefault, JSON_PRETTY_PRINT));
        if ($resultado === false) {
            error_log("❌ Error creando archivo de luces: $archivo");
            return $datosDefault;
        }
        error_log("✅ Archivo de luces creado exitosamente: $archivo");
    }
    return true;
}

// FUNCIÓN: Leer datos
function leerDatosLuces($archivo, $default) {
    // Asegurar que el archivo existe
    inicializarArchivo($archivo, $default);
    
    if (file_exists($archivo)) {
        $contenido = file_get_contents($archivo);
        if ($contenido === false) {
            error_log("❌ Error leyendo archivo de luces: $archivo");
            return $default;
        }
        
        $datos = json_decode($contenido, true);
        if (json_last_error() === JSON_ERROR_NONE) {
            return $datos;
        } else {
            error_log("❌ Error JSON en $archivo: " . json_last_error_msg());
            // Si hay error JSON, recrear el archivo
            inicializarArchivo($archivo, $default);
            return $default;
        }
    }
    
    return $default;
}

// FUNCIÓN: Guardar datos
function guardarDatosLuces($archivo, $datos) {
    // Asegurar que el archivo existe primero
    if (!file_exists($archivo)) {
        error_log("⚠️ Archivo de luces no existe al guardar, creando: $archivo");
        inicializarArchivo($archivo, $datos);
    }
    
    // Agregar timestamp de actualización
    $datos['ultima_actualizacion'] = date('c');
    
    $resultado = file_put_contents($archivo, json_encode($datos, JSON_PRETTY_PRINT));
    
    if ($resultado === false) {
        $error = error_get_last();
        throw new Exception("Error escribiendo archivo de luces: " . ($error['message'] ?? 'Desconocido'));
    }
    
    error_log("💾 Archivo de luces guardado: $archivo - Tamaño: " . filesize($archivo) . " bytes");
    return $datos;
}

try {
    $method = $_SERVER['REQUEST_METHOD'];
    
    switch ($method) {
        case 'GET':
            // Obtener datos actuales de luces
            $datos = leerDatosLuces($dataFile, $defaultData);
            
            // Log en consola
            error_log("📥 GET Luces - Datos enviados: " . json_encode($datos));
            echo json_encode($datos);
            break;
            
        case 'POST':
            // Actualizar datos de luces
            $input = file_get_contents('php://input');
            $nuevosDatos = json_decode($input, true);
            
            if (json_last_error() !== JSON_ERROR_NONE) {
                throw new Exception('JSON inválido');
            }
            
            $datosActuales = leerDatosLuces($dataFile, $defaultData);
            
            // Filtrar y actualizar solo los campos permitidos
            if (isset($nuevosDatos['luces1_estado'])) {
                $datosActuales['luces1_estado'] = (bool)$nuevosDatos['luces1_estado'];
            }
            if (isset($nuevosDatos['luces2_estado'])) {
                $datosActuales['luces2_estado'] = (bool)$nuevosDatos['luces2_estado'];
            }
            
            // Guardar datos actualizados
            $datosGuardados = guardarDatosLuces($dataFile, $datosActuales);
            
            // Log en consola
            error_log("💾 POST Luces - Datos recibidos: " . $input);
            error_log("💾 POST Luces - Datos guardados: " . json_encode($datosGuardados));
            
            echo json_encode([
                'success' => true,
                'message' => 'Datos de luces guardados exitosamente',
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
    error_log("❌ Error Luces API: " . $e->getMessage());
}
?>