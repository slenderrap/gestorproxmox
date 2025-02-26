import 'package:flutter/material.dart';
import 'package:dartssh2/dartssh2.dart';

class ServerView extends StatelessWidget{
  final SSHClient connection;
  final String nomServer;
  const ServerView({Key? key, required SSHClient this.connection, required String this.nomServer}) : super(key: key) ;

  @override
  Widget build(BuildContext context){
    return  Scaffold(
        appBar: AppBar(
          title: Text(nomServer),
        ),
        
    );
  }

}
