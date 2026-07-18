import 'package:flutter_test/flutter_test.dart';
import 'package:fithub_portal_admin/config/theme/app_colors.dart';

void main() {
  test('Stitch Kinetic Monolith tokens match get_project namedColors', () {
    expect(AppColors.background.toARGB32(), 0xFF131313);
    expect(AppColors.primaryContainer.toARGB32(), 0xFFC3F400);
    expect(AppColors.primaryFixedDim.toARGB32(), 0xFFABD600);
    expect(AppColors.errorContainer.toARGB32(), 0xFF93000A);
    expect(AppColors.error.toARGB32(), 0xFFFFB4AB);
    expect(AppColors.electricLime.toARGB32(), 0xFFCCFF00);
  });
}
