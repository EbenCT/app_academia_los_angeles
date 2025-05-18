import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  // Esta clave API es un placeholder - deberías reemplazarla por tu clave real de Gemini
  static const String apiKey = 'AIzaSyDtVbJLqjH_HiNXnW3v_l7YbtFoC7exxts';
  // URL actualizada para gemini-2.0-flash
  static const String apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  /// Solicita una explicación al API de Gemini para un error específico
  static Future<String> getErrorExplanation({
    required String concept,
    required String userAnswer,
    required String correctAnswer,
    required String lessonContext,
  }) async {
    try {
      final prompt = '''
Dame una explicación breve y amigable para un niño de primaria sobre por qué "$userAnswer" no es la respuesta correcta para este problema de matemáticas. 
La respuesta correcta es "$correctAnswer".
Tema: $concept
Contexto: $lessonContext

Por favor, explica el error de forma sencilla, motivadora y en menos de 3 frases. Usa un tono positivo y no uses palabras como "incorrecto" o "error".
''';

      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text": prompt
                }
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.2,
            "maxOutputTokens": 100,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // La estructura de respuesta ha cambiado, actualizando el parser
        final generatedContent = data['candidates'][0]['content'];
        final parts = generatedContent['parts'];
        if (parts != null && parts.isNotEmpty) {
          final text = parts[0]['text'];
          return text ?? "No se pudo obtener una explicación clara.";
        }
        return "No se pudo obtener una explicación clara.";
      } else {
        print('Error API: ${response.statusCode} - ${response.body}');
        // En caso de errores de API, devolver una explicación genérica
        return "Los números enteros funcionan de una forma especial en esta operación. ¡Vamos a intentarlo otra vez!";
      }
    } catch (e) {
      print('Error al obtener explicación: $e');
      return "Hmm, esa no es la respuesta que buscamos. ¡Inténtalo de nuevo!";
    }
  }

  /// Versión offline para pruebas o en caso de que la API no esté disponible
  static String getOfflineExplanation({
    required String concept,
    required String userAnswer,
    required String correctAnswer,
  }) {
    // Explicaciones predefinidas basadas en conceptos
    final Map<String, List<String>> explanations = {
      'enteros': [
        "Los números enteros incluyen números negativos, cero y positivos, pero no incluyen fracciones o decimales.",
        "Recuerda que los números enteros son números completos como -3, -2, -1, 0, 1, 2, 3...",
        "¡Casi! Revisa si tu respuesta es un número completo sin partes decimales o fracciones."
      ],
      'comparacion': [
        "Recuerda que en la recta numérica, los números más a la derecha son mayores.",
        "Cuando comparamos números negativos, el que está más cerca de cero es mayor.",
        "Piensa en la recta numérica: cuanto más a la izquierda, menor es el número."
      ],
      'operaciones': [
        "Recuerda seguir el orden de las operaciones: primero multiplicación y división, luego suma y resta.",
        "Al calcular con números negativos, debes tener cuidado con los signos.",
        "¡Revisa el orden de tus operaciones! Primero resolvemos lo que está dentro de paréntesis."
      ],
      'temperatura': [
        "Cuando las temperaturas suben, sumamos. Cuando bajan, restamos.",
        "Los cambios de temperatura pueden dar números positivos (calentamiento) o negativos (enfriamiento).",
        "Recuerda que -3°C es 3 grados bajo cero, es más frío que 0°C."
      ],
      'altitud': [
        "Las altitudes sobre el nivel del mar son positivas, y bajo el nivel del mar son negativas.",
        "Cuando subimos, sumamos metros. Cuando bajamos, restamos metros.",
        "El nivel del mar es nuestra referencia (0 metros). Por encima es positivo, por debajo es negativo."
      ]
    };

    // Elegir una explicación aleatoria del concepto correspondiente
    final conceptKeys = explanations.keys.toList();
    String key = 'enteros'; // Valor predeterminado

    for (var k in conceptKeys) {
      if (concept.toLowerCase().contains(k)) {
        key = k;
        break;
      }
    }

    final explanationList = explanations[key]!;
    final randomIndex = DateTime.now().millisecondsSinceEpoch % explanationList.length;
    
    return explanationList[randomIndex];
  }
}