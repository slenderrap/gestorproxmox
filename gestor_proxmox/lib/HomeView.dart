import 'package:flutter/material.dart';
import 'widgets/TextFieldWithTitle.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final List<int> numbers = List.generate(5, (index) => index + 1);
  final TextEditingController _controllerNom = TextEditingController();
  final TextEditingController _controllerServidor = TextEditingController();
  final TextEditingController _controllerPort = TextEditingController();
  final TextEditingController _controllerClau = TextEditingController();
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
                          child: ListView(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            children: numbers
                                .map((number) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 4.0),
                              child: Align(
                                alignment: Alignment(-0.8,0.0),
                                child: Text('$number',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,)
                                ),
                              )

                            ))
                                .toList()
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
                    ],),
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
