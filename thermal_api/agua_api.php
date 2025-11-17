<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Manejar preflight request
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

// Archivo para guardar los datos de agua - RUTA ABSOLUTA para asegurar guardado
$dataFile ='agua_data.json';

// Datos iniciales para diferentes vasos - SOLO los parámetros requeridos
$defaultData = [
    'vaso1' => [
        'vacio' => 20,
        'agua' => 80
    ],
    'vaso2' => [
        'vacio' => 30,
        'agua' => 70
    ],
    'vaso3' => [
        'vacio' => 10,
        'agua' => 90
    ],
    'vaso4' => [
        'vacio' => 40,
        'agua' => 60
    ]
];

// Función para leer datos del archivo
function leerDatosAgua($archivo, $default) {
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
function guardarDatosAgua($archivo, $datos) {
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
            // Obtener vaso específico
            $vaso = $_GET['vaso'] ?? null;
            $datos = leerDatosAgua($dataFile, $defaultData);
            
            if ($vaso && isset($datos[$vaso])) {
                $respuesta = $datos[$vaso];
            } else if ($vaso) {
                // Si el vaso no existe, crear uno nuevo SOLO con parámetros requeridos
                $respuesta = ['vacio' => 20, 'agua' => 80];
            } else {
                // Si no se especifica vaso, devolver todos
                $respuesta = $datos;
            }
            
            // Log en consola
            error_log("📥 GET Agua - Vaso: " . ($vaso ?? 'todos') . " - Datos: " . json_encode($respuesta));
            echo json_encode($respuesta);
            break;
            
        case 'POST':
            // Actualizar datos de un vaso
            $input = file_get_contents('php://input');
            $nuevosDatos = json_decode($input, true);
            
            if (json_last_error() !== JSON_ERROR_NONE) {
                throw new Exception('JSON inválido');
            }
            
            $vaso = $nuevosDatos['vaso'] ?? null;
            if (!$vaso) {
                throw new Exception('Vaso no especificado');
            }
            
            $datosActuales = leerDatosAgua($dataFile, $defaultData);
            
            // Filtrar solo los parámetros permitidos
            $datosFiltrados = [];
            if (isset($nuevosDatos['datos']['vacio'])) {
                $datosFiltrados['vacio'] = $nuevosDatos['datos']['vacio'];
            }
            if (isset($nuevosDatos['datos']['agua'])) {
                $datosFiltrados['agua'] = $nuevosDatos['datos']['agua'];
            }
            
            // Combinar con datos existentes
            $datosActuales[$vaso] = array_merge($datosActuales[$vaso] ?? ['vacio' => 20, 'agua' => 80], $datosFiltrados);
            
            // Guardar datos
            $datosGuardados = guardarDatosAgua($dataFile, $datosActuales);
            
            // Log en consola
            error_log("💾 POST Agua - Vaso: $vaso - Datos: " . json_encode($datosFiltrados));
            error_log("💾 Archivo guardado en: $dataFile");
            
            echo json_encode([
                'success' => true,
                'message' => 'Datos de agua guardados exitosamente',
                'vaso' => $vaso,
                'data' => $datosGuardados[$vaso]
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
    error_log("❌ Error Agua API: " . $e->getMessage());
    
    // Información adicional para debug
    error_log("❌ Ruta del archivo: $dataFile");
    error_log("❌ Permisos del directorio: " . (is_writable(dirname($dataFile)) ? 'WRITABLE' : 'NOT WRITABLE'));
}
?>