import 'package:flutter/widgets.dart';
import 'package:g1_g2/src/models/collect_point_model.dart';

typedef RequestRouteCallback = Future<void> Function(CollectPointModel point, BuildContext context);

class MapController {
  static RequestRouteCallback? _callback;
  static BuildContext? _context;


  /// para rotas
  static void registerCallback(RequestRouteCallback callback, BuildContext context) {
    _callback = callback;
    _context = context;
  }

  static void clearCallback() {
    _callback = null;
  }

  static Future<void>? requestRoute(CollectPointModel point) {
    if (_callback == null || _context == null) {
      return null;
    }
    return _callback?.call(point, _context!);
  }
  /// usado em point_details_page e voice_search_points_page
  static Future<void>? followRouteToPoint(CollectPointModel point) {
    return requestRoute(point);
  }

  /// usado em custom_map
  static void registerFollowCallback(RequestRouteCallback callback, BuildContext context) {
    if (_callback != null) return; 
    registerCallback(callback, context);
  }

  /// usado em custom_map
  static void clear() {
    clearCallback();
  }
}
