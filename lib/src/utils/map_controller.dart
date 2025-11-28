import 'package:g1_g2/src/models/collect_point_model.dart';

typedef FollowRouteCallback = Future<void> Function(CollectPointModel point);

class MapController {
  static FollowRouteCallback? _followCb;

  /// Register a callback provided by the map widget to follow a route.
  static void registerFollowCallback(FollowRouteCallback cb) {
    _followCb = cb;
  }

  /// Unregister the callback (optional)
  static void clear() {
    _followCb = null;
  }

  /// Request the map to follow a route to [point]. Returns null if not available.
  static Future<void>? followRouteToPoint(CollectPointModel point) {
    return _followCb?.call(point);
  }
}
