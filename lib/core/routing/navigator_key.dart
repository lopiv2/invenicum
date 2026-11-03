import 'package:flutter/material.dart';

/// Global navigator key shared by the router and [ToastService].
/// Kept in its own file so services can use it without importing
/// the router (which pulls web-only dependencies).
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
