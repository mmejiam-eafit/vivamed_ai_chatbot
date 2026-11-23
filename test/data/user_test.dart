import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/user.dart';

void main() {
  group('roleLabel', () {
    test('names the roles the backend sends in the app\'s words', () {
      expect(roleLabel('radiologist'), 'Radiologist');
      expect(roleLabel('admin'), 'Administrator');
    });

    test('shows a role the app does not know by the backend\'s name', () {
      expect(roleLabel('technologist'), 'technologist');
    });
  });
}
