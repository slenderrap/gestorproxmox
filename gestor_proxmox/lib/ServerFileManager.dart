import 'dart:convert';
import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
//scp per cridar per comandes
//import 'package:ftpclient/ftpclient.dart';
import 'package:path_provider/path_provider.dart';

class ServerFileManager {
  late SSHClient _sshClient;
  //late FTPClient _ftpClient;

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

  Future<void> addServer(String name, String host, int port, String user, String password) async {
    final config = await readConfig();
    if (config['servers'].containsKey(name)) {
      throw Exception('Ya existe un servidor con el nombre "$name".');
    }
    config['servers'][name] = {
      'host': host,
      'port': port,
      'user': user,
      'password': password,
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

  Future<void> connectSSH({
    required String host,
    required int port,
    required String user,
    required String password,
  }) async {
    final socket = await SSHSocket.connect(host, port);
    _sshClient = SSHClient(
      socket,
      username: user,
      onPasswordRequest: () => password,
    );
  }

  void disconnectSSH() {
    _sshClient.close();
  }

  Future<void> connectFTP({
    required String host,
    required int port,
    required String user,
    required String password,
  }) async {
    _ftpClient = FTPClient(
      host,
      port: port,
      user: user,
      pass: password,
    );
    _ftpClient.connect();
  }

  void disconnectFTP() {
    _ftpClient.disconnect();
  }

  Future<void> renameFile(String oldPath, String newPath) async {
    await _sshClient.execute('mv $oldPath $newPath');
  }

  Future<void> downloadFile(String remotePath, String localPath) async {
    final file = File(localPath);
    final sink = file.openWrite();
    await _sshClient.scp.download(remotePath, sink);
    await sink.close();
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
    await _sshClient.execute('unzip -o $remotePath.zip -d $remotePath && rm $remotePath.zip');
    await File(tempZip).delete();
  }

  Future<void> deleteFile(String path) async {
    await _sshClient.execute('rm -rf $path');
  }

  Future<String> getFileInfo(String path) async {
    final result = await _sshClient.execute('ls -ld $path');
    return result;
  }

  Future<String> getFilePermissions(String path) async {
    final result = await _sshClient.execute('stat -c "%A" $path');
    return result.trim();
  }

  Future<void> unzipFile(String remotePath, String destination) async {
    await _sshClient.execute('unzip -o $remotePath -d $destination');
  }

    Future<void> configurePortForwarding(int localPort, String remoteHost, int remotePort) async {
        await _sshClient.execute('ssh -L $localPort:$remoteHost:$remotePort');
    }

    Future<void> compressFilesRemote(String path, String destination) async {
    await _sshClient.execute('zip -r $destination $path');
    }


    Future<List<Map<String, dynamic>>> listDirectory(String path) async {
        final sftp = await _sshClient.sftp();
        final entries = await sftp.opendir(path);

        List<Map<String, dynamic>> files = [];

        await for (final entry in entries) {
            files.add({
                'filename': entry.filename,
                'isDirectory': entry.attrs.isDirectory,
                'size': entry.attrs.size,
                'permissions': entry.attrs.permissions,
            });
        }

        return files;
    }

  Future<void> manageServer(String path, String action) async {
    if (action == 'start') {
      await _sshClient.execute('cd $path && nohup java -jar app.jar &');
    } else if (action == 'restart') {
      await _sshClient.execute('pkill -f java && cd $path && nohup java -jar app.jar &');
    } else if (action == 'stop') {
      await _sshClient.execute('pkill -f java');
    }
  }
}
