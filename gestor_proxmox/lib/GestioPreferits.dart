import "dart:io";
import "dart:convert";
import 'package:path_provider/path_provider.dart';
import 'Server.dart';

class GestioPreferits {
  static Future<String> _getFilePath() async {
    
    final directori = await getApplicationDocumentsDirectory();

    return '${directori.path}/favorites.json';
  }

  static Future<void> guardarDades(Server serverData) async {
    final directori = await _getFilePath();
    final arxiu = File(directori);
    List<Server> preferits = [];

    if (await arxiu.exists()) {
      
      String contingut = await arxiu.readAsString();
      if (contingut.isNotEmpty) {
        List<dynamic> jsonData = jsonDecode(contingut);
        preferits = jsonData.map((json) => Server.fromJson(json as Map<String, dynamic>)).toList();
        }

      
    }
    if (!preferits.any((s) => s.nom == serverData.nom)) {
      preferits.add(serverData);
    }
    await arxiu.writeAsString(jsonEncode(preferits));
  }

  static Future<List<Server>> carregarDades() async {
    final directori = await _getFilePath();
    final arxiu = File(directori);
    if (await arxiu.exists()) {
      String contingut = await arxiu.readAsStringSync();
      if (contingut.isEmpty) return [];
      List<dynamic> jsonData = jsonDecode(contingut);
      return jsonData.map((json) => Server.fromJson(json)).toList();
    }
    return [];
  }

  static Future<List<Server>> esborrarDades(String nomServidor) async {
      final directori = await _getFilePath();
      final arxiu = File(directori);
      if (await arxiu.exists()) {
        String contingut = await arxiu.readAsStringSync();
        if (contingut.isEmpty) return [];
        List<dynamic> jsonData = jsonDecode(contingut);
        List<Server> preferits =jsonData.map((json) => Server.fromJson(json)).toList();
        preferits.removeWhere((server) => server.nom == nomServidor);
       await arxiu.writeAsString(jsonEncode(preferits));
      
        return await carregarDades();
    }
    return [];
  }

  static Future<List<Server>> llistaServidors() async {
    return await carregarDades();
  }
}