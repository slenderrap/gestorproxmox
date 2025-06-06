import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:gestor_proxmox/ServerView.dart';
import 'widgets/TextFieldWithTitle.dart';
import 'ServerFileManager.dart';
import 'package:gestor_proxmox/GestioPreferits.dart';
import 'package:gestor_proxmox/Server.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<Server> _servidors=[];
  final TextEditingController _controllerNomServer = TextEditingController();
  final TextEditingController _controllerNomUsuari = TextEditingController();  
  final TextEditingController _controllerServidor = TextEditingController();
  final TextEditingController _controllerPort = TextEditingController();
  final TextEditingController _controllerClau = TextEditingController();
  int? _selectedServer;

  @override
  void initState() {
    super.initState();
    _carregarServidors();
  }
  void _carregarServidors() async{
    List<Server> servidorsGuardats = await GestioPreferits.llistaServidors();
    setState(() {
      _servidors = servidorsGuardats;
    });
  }

void _afegirServidor() async {
  setState(() {
    clearFields();
    _servidors.add(Server("Nou servidor ${_servidors.length}", "", "", "", ""));
    _selectedServer = _servidors.length - 1; // Seleccionar el nuevo servidor
  });
    
  }

  void clearFields() {
    _controllerNomServer.clear();
    _controllerNomUsuari.clear();
    _controllerServidor.clear();
    _controllerPort.clear();
    _controllerClau.clear();
  }

  String ValidateFields(){
    
    if(_controllerNomServer.text.toString()=="") return "Has d'introduir un nom";
    if(_controllerNomUsuari.text.toString()=="") return "Has d'introduir un nom d'usuari";
    if(_controllerServidor.text.toString()=="")  return "Has d'introduir un servidor";
    if(_controllerPort.text.toString()=="")  return "Has d'introduir un port";
    if(_controllerClau.text.toString()=="")  return "Has d'introduir un rsa";
    return "";
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
          backgroundColor: const Color.fromARGB(255, 151, 116, 250),
          automaticallyImplyLeading: false,
          title: Text(
            'Pantalla d\'inici',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          centerTitle: false,
          elevation: 2,
        ),
        body: SafeArea(
          child: Row(
            children: [
              _buildServerList(),
              _buildServerInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServerList() {
    return Expanded(
      flex: 1,
      child: Container(
        color: Colors.blue[100],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Servidors",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _servidors.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedServer = index;
                        _controllerNomServer.text=_servidors[_selectedServer!].nom;
                        _controllerNomUsuari.text=_servidors[_selectedServer!].nomUsuari;
                        _controllerServidor.text=_servidors[_selectedServer!].direccio;
                        _controllerPort.text=_servidors[_selectedServer!].port;
                        _controllerClau.text=_servidors[_selectedServer!].rsa;
                         _servidors[index].nom;

                      });
                    },
                    child: Container(
                      color: _selectedServer == index ? Colors.blue[200] : Colors.transparent,
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _servidors[index].nom,
                        
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _afegirServidor, 
                child: Text("Nou servidor"),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildServerInfo() {
    return Expanded(
      flex: 2,
      child: Container(
        decoration: const BoxDecoration(color: Color.fromARGB(255, 169, 206, 188)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFieldWithTitle(title: "Nom", controller: _controllerNomServer),
            const SizedBox(height: 40),
            TextFieldWithTitle(title: "Usuari", controller: _controllerNomUsuari),
            const SizedBox(height: 40),
            TextFieldWithTitle(title: "Servidor", controller: _controllerServidor),
            const SizedBox(height: 40),
            TextFieldWithTitle(title: "Port", controller: _controllerPort),
            const SizedBox(height: 40),
            TextFieldWithTitle(title: "Clau", controller: _controllerClau),
            const SizedBox(height: 40),
            const Spacer(),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.black87),
            onPressed: () async{
            await GestioPreferits.esborrarDades(_servidors[_selectedServer!].nom);
              _carregarServidors();
              ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
                const SnackBar(content: Text("Servidor esborrat"), backgroundColor: Colors.green
              ));
              clearFields();
            },
          ),
          TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
            child: const Text("Afegeir a preferits"),
            onPressed: () async{
              if (_selectedServer != null){
                String error= ValidateFields();
                if (error!=""){
                  ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
                    SnackBar(content: Text(error), backgroundColor: Colors.red)
                   );
                }
                else{
                  setState(() {
                    
                    _servidors[_selectedServer!].nom=_controllerNomServer.text.toString();
                    _servidors[_selectedServer!].nomUsuari=_controllerNomUsuari.text.toString();
                    _servidors[_selectedServer!].direccio=_controllerServidor.text.toString();
                    _servidors[_selectedServer!].port=_controllerPort.text.toString();
                    _servidors[_selectedServer!].rsa=_controllerClau.text.toString();
                    
                  });

                  await GestioPreferits.guardarDades(_servidors[_selectedServer!]);

                  ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
                  const SnackBar(content: Text("Afegit a preferits"),backgroundColor: Colors.green
                  ),
                  );
                }
              }
              
            },
          ),
          TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            child: const Text("Connectar"),
            onPressed: () async {
              String error=ValidateFields();
              if (error!="")
              {
                ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
                    SnackBar(content: Text(error), backgroundColor: Colors.red)
                   );
              }
              else{

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return const AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 10),
                          Text("Connectant..."),
                        ],
                      ),
                    );
                  },
                );

                SSHClient? conectat = await ServerFileManager().connectSSH(
                  host: _controllerServidor.text,
                  username: _controllerNomUsuari.text,
                  port: int.parse(_controllerPort.text),
                  keyFilePath: _controllerClau.text,
                );
                if (conectat != null){
                  await GestioPreferits.guardarDades(_servidors[_selectedServer!]);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
                    SnackBar(content: Text("Connectat"),backgroundColor: Colors.green,));
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                    builder: (context) => ServerView(connection: conectat, nomServer: _controllerNomServer.text,),
                    ),
                  );
                }
                else{
                  Navigator.pop(context);
                  ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
                    SnackBar(content: Text("No s'ha pogut connectar al servidor"),backgroundColor: Colors.red,));
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
