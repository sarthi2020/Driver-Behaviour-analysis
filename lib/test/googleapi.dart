// // import 'package:fit_kit/fit_kit.dart';
// import 'package:googleapis/fitness/v1.dart';
// import 'package:googleapis_auth/auth.dart';
// import 'package:googleapis_auth/auth_browser.dart';
// import 'package:googleapis_auth/auth_io.dart';
//
// import 'package:googleapis/storage/v1.dart';
//
// final _scopes = const [FitnessApi.fitnessActivityReadScope];
// class Fitness{
//   static var steps;
//   void stepcount() async {
//     steps = await FitnessApi.fitnessActivityReadScope;
//   }
// }
// var _credentials;



// if (Platform.isAndroid) {
// _credentials = new ClientId(
// "YOUR_CLIENT_ID_FOR_ANDROID_APP_RETRIEVED_FROM_Google_Console_Project_EARLIER",
// "");
// } else if (Platform.isIOS) {
// _credentials = new ClientId(
// "YOUR_CLIENT_ID_FOR_IOS_APP_RETRIEVED_FROM_Google_Console_Project_EARLIER",
// "");
// }
// final _credentials = ServiceAccountCredentials.fromJson(r'''
// {
//   "private_key_id": ...,
//   "private_key": ...,
//   "client_email": ...,
//   "client_id": ...,
//   "type": "service_account"
// }
// ''');
//
// const _scopes = [StorageApi.devstorageReadOnlyScope];
//
// Future<void> main() async {
//   final httpClient = await clientViaServiceAccount(_credentials, _scopes);
//   try {
//     final storage = StorageApi(httpClient);
//
//     final buckets = await storage.buckets.list('dart-on-cloud');
//     final items = buckets.items!;
//     print('Received ${items.length} bucket names:');
//     for (var file in items) {
//       print(file.name);
//     }
//   } finally {
//     httpClient.close();
//   }
// }