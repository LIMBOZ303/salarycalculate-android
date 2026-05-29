import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Log debug API (không log token đầy đủ).
class ApiDebugLog {
  ApiDebugLog._();

  static void logResponse(
    String endpoint, {
    int? statusCode,
    dynamic data,
  }) {
    if (!kDebugMode) return;
    developer.log(
      'endpoint=$endpoint | statusCode=${statusCode ?? '-'} | data=${_sanitize(data)}',
      name: 'ApiDebug',
    );
  }

  static dynamic _sanitize(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      final out = <String, dynamic>{};
      value.forEach((key, v) {
        final k = key.toString().toLowerCase();
        if (k == 'token' || k == 'accesstoken' || k == 'refreshtoken') {
          out[key.toString()] = _maskToken(v?.toString());
        } else if (v is Map || v is List) {
          out[key.toString()] = _sanitize(v);
        } else {
          out[key.toString()] = v;
        }
      });
      return out;
    }
    if (value is List) {
      return value.map(_sanitize).toList();
    }
    return value;
  }

  static String _maskToken(String? token) {
    if (token == null || token.isEmpty) return '***';
    if (token.length <= 8) return '***';
    return '${token.substring(0, 4)}...${token.substring(token.length - 4)}';
  }
}
