import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:gestor_proxmox/ServerFileManager.dart';
import 'package:gestor_proxmox/widgets/filetile.dart';
import 'package:gestor_proxmox/widgets/GenericList.dart'; // Importar el widget genérico

class ServerView extends StatefulWidget {
  final SSHClient connection;
  final String nomServer;

  const ServerView({
    Key? key,
    required this.connection,
    required this.nomServer,
  }) : super(key: key);

  @override
  _ServerViewState createState() => _ServerViewState();
}

class _ServerViewState extends State<ServerView> {
  late ServerFileManager fileManager;
  List<String> files = [];
  bool isLoading = true;

  // Estado para rastrear la sección activa
  final ValueNotifier<String> selectedSection = ValueNotifier<String>("Carpetes");

  @override
  void initState() {
    super.initState();
    fileManager = ServerFileManager.withConnection(widget.connection);
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    try {
      files.clear(); // Limpiar la lista de archivos
      files.add(".."); // Agregar opción para regresar al directorio padre

      final result = await fileManager.getFileInfo(fileManager.actualPath);
      for (var line in result.split('\n')) {
        if (line.isNotEmpty && !line.startsWith("total")) {
          var parts = line.split(' ');
          files.add(parts.last.trim());
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar archivos: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nomServer),
      ),
      body: Row(
        children: [
          // Columna izquierda: Secciones "Recents", "Carpetes" y "Eliminats"
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSections(),
                ],
              ),
            ),
          ),

          // Columna derecha: Contenido dinámico según la sección seleccionada
          Expanded(
            flex: 5,
            child: ValueListenableBuilder<String>(
              valueListenable: selectedSection,
              builder: (context, activeSection, _) {
                switch (activeSection) {
                  case "Recents":
                    return Center(
                      child: Text(
                        "Arxius recents",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    );
                  case "Eliminats":
                    return Center(
                      child: Text(
                        "Arxius eliminats",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    );
                  default: // "Carpetes"
                    return GenericList(
                      title: fileManager.actualPath.split("/").last.isEmpty
                          ? "arrel"
                          : fileManager.actualPath.split("/").last,
                      items: files,
                      itemBuilder: (context, index) {
                        final item = files[index];
                        final isDirectory =
                            item == ".." || (!item.contains(".") && !item.startsWith("."));
                        return _buildFileTile(item, isDirectory);
                      },
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Método auxiliar para construir las secciones
  Widget _buildSections() {
    final List<String> sections = ["Recents", "Carpetes", "Eliminats"];

    return ValueListenableBuilder<String>(
      valueListenable: selectedSection,
      builder: (context, activeSection, _) {
        return Column(
          children: sections.map((section) {
            return InkWell(
              onTap: () {
                selectedSection.value = section;
                print("Sección seleccionada: $section");
                // Aquí puedes agregar lógica adicional para manejar la selección
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: section == activeSection ? Colors.grey.shade300 : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  section,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: section == activeSection ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // Método auxiliar para construir un archivo o carpeta con efecto de hover
  Widget _buildFileTile(String item, bool isDirectory) {
    // Usamos ValueNotifier para manejar el estado de isHovered
    final ValueNotifier<bool> isHovered = ValueNotifier<bool>(false);

    return MouseRegion(
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: ValueListenableBuilder<bool>(
        valueListenable: isHovered,
        builder: (context, hovered, child) {
          return SizedBox(
            height: 60, // Altura fija para todas las filas
            child: Container(
              decoration: BoxDecoration(
                color: hovered
                    ? Colors.green.shade200
                    : null, // Fondo ligeramente más claro al pasar el mouse
                borderRadius: BorderRadius.circular(10), // Bordes redondeados
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              margin: const EdgeInsets.symmetric(vertical: 4), // Espaciado entre elementos
              child: InkWell(
                onTap: () async {
                  if (!item.contains(".") || item.contains("..")) {
                    await fileManager.enterDirectory(item);
                    files.clear();
                    setState(() {});
                    print("path: ${fileManager.actualPath}");
                    _loadFiles();
                  } else {}
                },
                child: Row(
                  children: [
                    // Ícono de carpeta o archivo
                    Icon(
                      isDirectory ? Icons.folder : Icons.insert_drive_file,
                      color: isDirectory ? Colors.blue : Colors.grey,
                    ),
                    const SizedBox(width: 16), // Espacio entre el ícono y el texto
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    // Reservar espacio para los iconos incluso cuando no están visibles
                    if (!isDirectory && hovered)
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.download, color: Colors.green),
                            iconSize: 22,
                            onPressed: () async {
                              // Mostrar un cuadro de diálogo de confirmación
                              String remotePath = await showDialog(
                                context: context,
                                builder: (context) {
                                  final TextEditingController _pathController = TextEditingController();

                                  return AlertDialog(
                                    title: const Text("En que ruta quieres guardar el archivo?"),
                                    
                                    content: TextField(
                                      controller: _pathController,
                                      decoration: InputDecoration(
                                        hintText: "Ejemplo: /ruta/local/archivo",
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, ""), // Cancelar
                                        child: const Text("Cancelar"),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context,_pathController.text.trim()), // Confirmar
                                        child: const Text("Aceptar"),
                                      ),
                                    ],
                                  );
                                },
                              );

                              // Si el usuario confirma
                              if (remotePath.isNotEmpty) {
                                try {
                                  // guardar el archivo
                                  
                                  await fileManager.downloadFile(remotePath, item);

                                  // Mostrar mensaje de éxito
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Archivo guardado: $item"),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  
                                } catch (e) {
                                  // Mostrar mensaje de error si algo falla
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Error al guardar el archivo: $e"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.info, color: Colors.blue),

                            iconSize: 22,
                            onPressed: () {
                              print("Viendo propiedades de: $item");
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            iconSize: 22,
                            onPressed: () async {
                              // Mostrar un cuadro de diálogo de confirmación
                              bool? confirm = await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Confirmar eliminación"),
                                    content: Text("¿Estás seguro de que deseas eliminar '$item'?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false), // Cancelar
                                        child: const Text("Cancelar"),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true), // Confirmar
                                        child: const Text("Eliminar"),
                                      ),
                                    ],
                                  );
                                },
                              );

                              // Si el usuario confirma la eliminación
                              if (confirm == true) {
                                try {
                                  // Eliminar el archivo
                                  
                                  await fileManager.deleteFile(item);

                                  // Mostrar mensaje de éxito
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Archivo eliminado: $item"),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  setState(() {
                                    _loadFiles();
                                  });
                                  // Recargar la lista de archivos
                                } catch (e) {
                                  // Mostrar mensaje de error si algo falla
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Error al eliminar archivo: $e"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      )
                    else
                      SizedBox(width: 120), // Reservar espacio para los iconos incluso cuando no están visibles
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}