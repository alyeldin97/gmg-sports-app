import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

class MetaPixelService {
  MetaPixelService._();

  static bool _initialized = false;

  static void init(String pixelId) {
    if (pixelId.isEmpty) return;
    try {
      js.context.callMethod('fbq', ['init', pixelId]);
      _initialized = true;
      track('PageView');
    } catch (_) {}
  }

  static void track(String event, [Map<String, dynamic>? params]) {
    if (!_initialized) return;
    try {
      if (params != null) {
        js.context.callMethod(
            'fbq', ['track', event, js.JsObject.jsify(params)]);
      } else {
        js.context.callMethod('fbq', ['track', event]);
      }
    } catch (_) {}
  }

  static void pageView() => track('PageView');

  static void viewContent({
    required String contentId,
    required String contentName,
    double? value,
  }) {
    track('ViewContent', {
      'content_ids': [contentId],
      'content_name': contentName,
      'content_type': 'product',
      if (value != null) 'value': value,
      'currency': 'EGP',
    });
  }

  static void addToCart({
    required String contentId,
    required String contentName,
    required double value,
  }) {
    track('AddToCart', {
      'content_ids': [contentId],
      'content_name': contentName,
      'content_type': 'product',
      'value': value,
      'currency': 'EGP',
    });
  }

  static void initiateCheckout({
    required double value,
    required int numItems,
  }) {
    track('InitiateCheckout', {
      'value': value,
      'currency': 'EGP',
      'num_items': numItems,
    });
  }

  static void purchase({
    required String orderId,
    required double value,
  }) {
    track('Purchase', {
      'transaction_id': orderId,
      'value': value,
      'currency': 'EGP',
    });
  }

  static void completeRegistration() => track('CompleteRegistration');
}

class MetaPixelObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    MetaPixelService.pageView();
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    MetaPixelService.pageView();
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    MetaPixelService.pageView();
  }
}
