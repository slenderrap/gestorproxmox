import 'dart:convert';
import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class ServerFileManager {
  late SSHClient _sshClient;
  String actualPath = "/home/super";
  ServerFileManager();
   ServerFileManager.withConnection(this._sshClient);

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _configFile async {
    final path = await _localPath;
    return File('$path/server_config.json');
  }

  Future<void> initializeConfig() async {
    final file = await _configFile;
    if (!(await file.exists())) {
      await file.writeAsString(jsonEncode({"servers": {}}));
    }
  }

  Future<Map<String, dynamic>> readConfig() async {
    final file = await _configFile;
    if (await file.exists()) {
      final contents = await file.readAsString();
      return jsonDecode(contents);
    }
    return {"servers": {}};
  }

  Future<void> writeConfig(Map<String, dynamic> config) async {
    final file = await _configFile;
    await file.writeAsString(jsonEncode(config));
  }

  Future<void> addServer(String name, String host, int port, String user,
      String keyFilePath) async {
    final config = await readConfig();
    if (config['servers'].containsKey(name)) {
      throw Exception('Ya existe un servidor con el nombre "$name".');
    }
    config['servers'][name] = {
      'host': host,
      'port': port,
      'user': user,
      'keyFilePath': keyFilePath,
    };
    await writeConfig(config);
  }

  Future<void> removeServer(String name) async {
    final config = await readConfig();
    if (!config['servers'].containsKey(name)) {
      throw Exception('No se encontró un servidor con el nombre "$name".');
    }
    config['servers'].remove(name);
    await writeConfig(config);
  }

  Future<List<String>> listServers() async {
    final config = await readConfig();
    return (config['servers'] as Map<String, dynamic>).keys.toList();
  }

  Future<Map<String, dynamic>?> getServer(String name) async {
    final config = await readConfig();
    return config['servers'][name];
  }

  Future<SSHClient?> connectSSH({
    required String host,
    required String username,
    required int port,
    required String keyFilePath,
  }) async {
    try {
      final socket = await SSHSocket.connect(host, port);
      final keyFile = File(keyFilePath);
      if (!(await keyFile.exists())) {
        throw Exception("Error: No existe el archivo id_rsa");
      }

      final keyContents = await keyFile.readAsString();
      _sshClient = SSHClient(
        socket,
        username: username,
        identities: SSHKeyPair.fromPem(keyContents),
      );
      return _sshClient;
    } catch (e) {
      return null;
    }
  }

  void disconnectSSH() {
    _sshClient.close();
  }

Future<void> downloadFile(String localPath, String item) async {
  try {
    // Construir la ruta remota completa
    final serverPath = "$actualPath/$item";
    print("Descargando archivo desde: $serverPath");

    // Crear el archivo local
    final file = File(localPath);
    await file.create(recursive: true);

    // Abrir un flujo de escritura local
    final sink = file.openWrite();

    // Usar SFTP para descargar el archivo
    final sftp = await _sshClient.sftp();
    final remoteFile = await sftp.open(serverPath, mode: SftpFileOpenMode.read);
    final data = await remoteFile.read();
    await sink.addStream(data);
    await sink.close();

    print("Archivo descargado exitosamente: $item");
  } catch (e) {
    print("Error al descargar el archivo: $e");
    throw Exception("No se pudo descargar el archivo: $e");
  }
}

  Future<void> enterDirectory(String path) async {
    if (path == "..") {
      // Subir un nivel de directorio
      final parentPath = actualPath.split('/').sublist(0, actualPath.split('/').length - 1).join('/');
      actualPath = parentPath.isEmpty ? "/" : parentPath;
    } else {
      // Navegar hacia el directorio seleccionado
      actualPath = "$actualPath/$path".replaceAll("//", "/");
    }
  }

  Future<String> currentDirectory() async{
    final path = await _sshClient.execute("pwd");
    final stdout = await utf8.decodeStream(path.stdout);
    path.close();
    return stdout; 

  }

  Future<void> uploadFile(String localPath, String remotePath) async {
    final file = File(localPath);
    await _sshClient.scp.upload(file.openRead(), remotePath);
  }

  Future<void> uploadFolder(String localPath, String remotePath) async {
    final tempZip = '$localPath.zip';
    final zipProcess = await Process.run('zip', ['-r', tempZip, localPath]);
    if (zipProcess.exitCode != 0) {
      return;
    }
    await uploadFile(tempZip, '$remotePath.zip');
    await _sshClient.execute(
        'unzip -o $remotePath.zip -d $remotePath && rm $remotePath.zip');
    await File(tempZip).delete();
  }

  Future<void> deleteFile(String path) async {
    await _sshClient.execute('rm -rf $actualPath/$path');
  }

  Future<String> getFileInfo(String path) async {
    final result = await _sshClient.execute('ls -l $path');
    final stdout = await utf8.decodeStream(result.stdout);
    result.close();
    return stdout;
  }

  Future<String> getFilePermissions(String path) async {
    final result = await _sshClient.execute('stat -c "%A" $path');
    return result.toString();
  }

  Future<void> unzipFile(String remotePath, String destination) async {
    await _sshClient.execute('unzip -o $remotePath -d $destination');
  }

  Future<void> configurePortForwardingManual(
      int localPort, String remoteHost, int remotePort) async {
    await _sshClient.execute('ssh -L $localPort:$remoteHost:$remotePort');
  }

  Future<void> configurePortForwarding(
      int localPort, String remoteHost, int remotePort) async {
    await _sshClient.forwardLocal(remoteHost, remotePort,
        localHost: 'localhost', localPort: localPort);
  }

  Future<void> compressFilesRemote(String path, String destination) async {
    await _sshClient.execute('zip -r $destination $path');
  }

  Future<void> renameFile(String oldPath, String newPath) async {
    await _sshClient.execute('mv $oldPath $newPath');
  }

  Future<void> manageServer(String path, String action) async {
    if (action == 'start') {
      await _sshClient.execute('cd $path && nohup java -jar app.jar &');
    } else if (action == 'restart') {
      await _sshClient
          .execute('pkill -f java && cd $path && nohup java -jar app.jar &');
    } else if (action == 'stop') {
      await _sshClient.execute('pkill -f java');
    }
  }
}

extension on SSHClient {
  get scp => null;
}
