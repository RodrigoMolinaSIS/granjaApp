<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Manejar preflight request
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

// Archivo para guardar los datos de comida - RUTA ABSOLUTA
$dataFile =  'comida_data.json';

// Datos iniciales para diferentes platos - SOLO parámetros requeridos
$defaultData = [
    'comida1' => [
        'vacio' => 10,
        'comida' => 90
    ],
    'comida2' => [
        'vacio' => 20,
        'comida' => 80
    ],
    'comida3' => [
        'vacio' => 15,
        'comida' => 85
    ],
    'comida4' => [
        'vacio' => 5,
        'comida' => 95
    ]
];

// Función para leer datos del archivo
function leerDatosComida($archivo, $default) {
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
function guardarDatosComida($archivo, $datos) {
    // Asegurar que el directorio tenga permisos de escritura
    $directorio = dirname($archivo);
    if (!is_writable($directorio)) {
        throw new Exception("Directorio sin permisos de escritura: $directorio");
    }
    
    $resultado = file_put_contents($archivo, json_encode($datos, JSON_PRETTY_PRINT));
    
    if ($resultado === false) {
        throw new Exception("Error escribiendo archivo: $archivo");
    }
    
    return $datos;
}

// Procesar request
try {
    $method = $_SERVER['REQUEST_METHOD'];
    
    switch ($method) {
        case 'GET':
            // Obtener plato específico
            $plato = $_GET['plato'] ?? null;
            $datos = leerDatosComida($dataFile, $defaultData);
            
            if ($plato && isset($datos[$plato])) {
                $respuesta = $datos[$plato];
            } else if ($plato) {
                // Si el plato no existe, crear uno nuevo SOLO con parámetros requeridos
                $respuesta = ['vacio' => 10, 'comida' => 90];
            } else {
                $respuesta = $datos;
            }
            
            // Log en consola
            error_log("📥 GET Comida - Plato: " . ($plato ?? 'todos') . " - Datos: " . json_encode($respuesta));
            echo json_encode($respuesta);
            break;
            
        case 'POST':
            // Actualizar datos de un plato
            $input = file_get_contents('php://input');
            $nuevosDatos = json_decode($input, true);
            
            if (json_last_error() !== JSON_ERROR_NONE) {
                throw new Exception('JSON inválido');
            }
            
            $plato = $nuevosDatos['plato'] ?? null;
            if (!$plato) {
                throw new Exception('Plato no especificado');
            }
            
            $datosActuales = leerDatosComida($dataFile, $defaultData);
            
            // Filtrar solo los parámetros permitidos
            $datosFiltrados = [];
            if (isset($nuevosDatos['datos']['vacio'])) {
                $datosFiltrados['vacio'] = $nuevosDatos['datos']['vacio'];
            }
            if (isset($nuevosDatos['datos']['comida'])) {
                $datosFiltrados['comida'] = $nuevosDatos['datos']['comida'];
            }
            
            // Combinar con datos existentes
            $datosActuales[$plato] = array_merge($datosActuales[$plato] ?? ['vacio' => 10, 'comida' => 90], $datosFiltrados);
            
            // Guardar datos
            $datosGuardados = guardarDatosComida($dataFile, $datosActuales);
            
            // Log en consola
            error_log("💾 POST Comida - Plato: $plato - Datos: " . json_encode($datosFiltrados));
            error_log("💾 Archivo guardado en: $dataFile");
            
            echo json_encode([
                'success' => true,
                'message' => 'Datos de comida guardados exitosamente',
                'plato' => $plato,
                'data' => $datosGuardados[$plato]
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
    error_log("❌ Error Comida API: " . $e->getMessage());
}
?>