class Server{
  String _nom;
  String _nomUsuari;
  String _direccio;
  String _port;
  String _rsa;

  Server(this._nom, this._nomUsuari, this._direccio, this._port, this._rsa);

  String get rsa => _rsa;

  set rsa(String value) {
    _rsa = value;
  }

  String get port => _port;

  set port(String value) {
    _port = value;
  }

  String get direccio => _direccio;

  set direccio(String value) {
    _direccio = value;
  }

  String get nom => _nom;

  set nom(String value) {
    _nom = value;
  }

  String get nomUsuari => _nomUsuari;

  set nomUsuari(String value) {
    _nomUsuari = value;
  }


  Map<String, dynamic> toJson(){
    return {
      'nom': _nom,
      'nomUsuari': _nomUsuari,
      'direccio': _direccio,
      'port': _port,
      'rsa': _rsa
    };
  }

  factory Server.fromJson(Map<String, dynamic> json){
    return Server(
      json['nom'] ?? '', 
      json['nomUsuari'] ?? '',
      json['direccio'] ?? '', 
      json['port'] ?? '', 
      json['rsa'] ?? '');
  }

}