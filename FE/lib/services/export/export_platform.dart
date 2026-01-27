export 'export_platform_stub.dart'
    if (dart.library.html) 'export_platform_web.dart'
    if (dart.library.io) 'export_platform_io.dart';
