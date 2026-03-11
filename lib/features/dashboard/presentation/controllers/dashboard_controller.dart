import 'dart:async';
import 'package:get/get.dart';
import '../../../../core/network/network_service.dart';
import '../../../auth/domain/entities/entities.dart';
import '../../../auth/data/datasources/mock_data_service.dart';

class DashboardController extends GetxController {
  final _dataService = MockDataService();
  final metrics = Rxn<DashboardMetrics>();
  final isLoading = true.obs;
  final isOffline = false.obs;
  StreamSubscription? _sub;

  @override
  void onInit() {
    super.onInit();
    _startStream();
  }

  void _startStream() {
    isLoading.value = true;
    _sub?.cancel();
    _sub = _dataService.watchDashboard().listen(
          (m) {
        metrics.value = m as DashboardMetrics?;
        isLoading.value = false;
        isOffline.value = false;
      },
      onError: (_) {
        isLoading.value = false;
        isOffline.value = true;
      },
    );
  }

  void refresh() => _startStream();

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
