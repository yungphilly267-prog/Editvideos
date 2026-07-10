import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionService extends ChangeNotifier {
  bool _isProUser = false;
  bool get isProUser => _isProUser;
  set isProUser(bool value) => _isProUser = value;

  SubscriptionService() {
    _initSubscriptionState();
  }

  Future<void> _initSubscriptionState() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      if (customerInfo.entitlements.active.isNotEmpty) {
        isProUser = true;
      } else {
        isProUser = false;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error getting customer info: $e');
    }
  }

  Future<bool> upgradeToPro() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current!.monthly != null) {
        await Purchases.purchasePackage(offerings.current!.monthly!);
      }
      final customerInfo = await Purchases.getCustomerInfo();
      if (customerInfo.entitlements.active.isNotEmpty) {
        isProUser = true;
      } else {
        isProUser = false;
      }
      notifyListeners();
      return isProUser;
    } catch (e) {
      debugPrint('Error during purchase: $e');
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    try {
      await Purchases.restorePurchases();
      final customerInfo = await Purchases.getCustomerInfo();
      if (customerInfo.entitlements.active.isNotEmpty) {
        isProUser = true;
      } else {
        isProUser = false;
      }
      notifyListeners();
      return isProUser;
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      return false;
    }
  }
}
