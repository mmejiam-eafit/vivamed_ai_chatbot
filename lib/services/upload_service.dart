import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/repositories/upload_repository.dart';

class UploadService {
  UploadService(this._uploadRepository);

  final UploadRepository _uploadRepository;

  Future<CaseDetail> uploadStudy(List<String> fileNames) =>
      _uploadRepository.uploadStudy(fileNames);
}
