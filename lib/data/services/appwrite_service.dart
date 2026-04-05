import 'package:appwrite/appwrite.dart';

class AppwriteService {
  late Client client;
  late Storage storage;

  static const String projectId = '69bafc2400163f8e22ea';
  static const String bucketId = '69bb74c9003b6b2c2f98';
  static const String endpoint = 'https://sfo.cloud.appwrite.io/v1';

  AppwriteService() {
    client = Client()
      .setEndpoint(endpoint)
      .setProject(projectId);
    storage = Storage(client);
  }

  Future<String?> uploadFile(String filePath, String fileName) async {
    try {
      final result = await storage.createFile(
        bucketId: bucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: filePath, filename: fileName),
      );
      
      return '$endpoint/storage/buckets/$bucketId/files/${result.$id}/view?project=$projectId&mode=admin';
    } catch (e) {
      print('Appwrite upload error: \$e');
      return null;
    }
  }
}
