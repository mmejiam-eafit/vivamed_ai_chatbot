import 'package:radiologist_helper/data/upload.dart';
import 'package:radiologist_helper/repositories/upload_repository.dart';

class UploadService {
  UploadService(this._uploadRepository);

  final UploadRepository _uploadRepository;

  Future<UploadResult> uploadStudy(List<String> fileNames) =>
      _uploadRepository.uploadStudy(fileNames);
}
