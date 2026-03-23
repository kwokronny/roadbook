// lib/shared/api/api_endpoints.dart
abstract class ApiEndpoints {
  // Auth
  static const String login          = '/api/user/login';
  static const String register       = '/api/user/register';
  static const String userDetail     = '/api/user/detail';
  static const String userUpdate     = '/api/user/update';
  static const String passwordModify = '/api/user/password/modify';

  // Travel
  static const String travelPage    = '/api/travel/page';
  static const String travelDetail  = '/api/travel/detail';
  static const String travelSave    = '/api/travel/save';
  static const String travelRemove  = '/api/travel/remove';
  static const String travelInvite  = '/api/travel/invite';
  static const String travelAccept  = '/api/travel/accept';
  static const String travelSetRole = '/api/travel/set_role';

  // Schedule
  static const String scheduleList   = '/api/travel/schedule/list';
  static const String scheduleAdd    = '/api/travel/schedule/add';
  static const String scheduleUpdate = '/api/travel/schedule/update';
  static const String scheduleRemove = '/api/travel/schedule/remove';
  static const String scheduleClone  = '/api/travel/schedule/clone';

  // Upload
  static const String upload = '/upload';
}
