import 'package:flutter/material.dart';
import 'widgets/TextFieldWithTitle.dart';
import 'ServerFileManager.dart';
class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final List<String> _servidors = ["Servidor1","Servidor2","Servidor3","Servidor4"];
  final TextEditingController _controllerNom = TextEditingController();
  final TextEditingController _controllerServidor = TextEditingController();
  final TextEditingController _controllerPort = TextEditingController();
  final TextEditingController _controllerClau = TextEditingController();
  int? _selectedServer;
  void clearFields(){
    _controllerNom.clear();
    _controllerServidor.clear();
    _controllerPort.clear();
    _controllerClau.clear();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          automaticallyImplyLeading: false,
          title: Text(
            'Pantalla d\'inici',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          centerTitle: false,
          elevation: 2,
        ),
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: Row(
              children: [
                // Columna con ListView
                Expanded(
                  flex: 1, // Proporción para este contenedor
                  child: Container(
                    color: Colors.blue[100], // Color de fondo para distinguir
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Servidors",
                          style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          ),
                        ),
                    ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _servidors.length,
                            itemBuilder: (context, index) {
                              final isSelected = _selectedServer == index;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedServer = index;
                                    clearFields();
                                  });
                                },
                                child: Container(
                                  color: isSelected
                                      ? Colors.blue[300]
                                      : Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: Text(
                                    _servidors[index],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Columna Información del servidor
                Expanded(
                  flex: 2, // Proporción más amplia para este contenedor

                  child: Container(
                    decoration: const BoxDecoration(color: Colors.orange),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFieldWithTitle(title: "Nom",  controller: _controllerNom),const SizedBox(height:40),
                        TextFieldWithTitle(title: "Servidor",  controller: _controllerServidor),const SizedBox(height:40),
                        TextFieldWithTitle(title: "Port",  controller: _controllerPort),const SizedBox(height:40),
                        TextFieldWithTitle(title: "Clau",  controller: _controllerClau),const SizedBox(height:40),

                        const Spacer(),
                        Align(
                          alignment: Alignment.bottomCenter,
                        ),
                        Padding(padding: const EdgeInsets.only(bottom: 40),
                        child:
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton( icon: const Icon(Icons.delete, color: Colors.black87,),onPressed: (){
                                clearFields();
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Camps netejats")),);
                              }),
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text("Afegeir a preferits"),
                                onPressed: (){
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Afegit a preferits")),);
                              }),
                              TextButton(
                                style: TextButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                ),
                                child: Text("Connectar"),
                                onPressed: (){
                                  ServerFileManager().connectSSH(host: _controllerServidor.text, port: int.parse(_controllerPort.text), user: _controllerNom.text, keyFilePath: _controllerClau.text);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Intentant connexio")),);
                                }
                              ),
                            ],
                          ),
                        ),
                      ],
                  ),
                  ),
                  ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
