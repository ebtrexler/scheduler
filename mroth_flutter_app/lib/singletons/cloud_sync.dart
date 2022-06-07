import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'package:mroth_flutter_app/models/appointment.dart';
import 'package:mroth_flutter_app/models/user.dart';
import 'package:mroth_flutter_app/utils/code_gen.dart';

const String serverlessId = '27h3qylvhk';
const String urlBase =
    "https://$serverlessId.execute-api.us-east-1.amazonaws.com";

const String urlToCreateOrUpdateUser = "$urlBase/create_or_update_user";
const String urlToGetUser = "$urlBase/get_user";
const String urlToGetAllUsers = "$urlBase/get_all_users";
const String urlToCreateOrUpdateAppt = "$urlBase/create_or_update_appt";
const String urlToDeleteAppt = "$urlBase/delete_appt";
const String urlToGetAllUserAppts = "$urlBase/get_all_user_appts";

class CloudResult {
  bool connected;
  bool success;
  String status;
  dynamic data;
  CloudResult(this.connected, this.success, this.status, [this.data]);
}

class CloudSync {
  static final CloudSync _instance = CloudSync._internal();

  static const String apptStoreName = "appts";

  final Map<String, String> _headers = {};

  List<Appointment> appointments = [];
  List<User> users = [];

  factory CloudSync() {
    return _instance;
  }

  CloudSync._internal() {
    _init();
  }

  _init() async {
    _headers['content-type'] = 'application/json';
  }

  Future<bool> hasInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return (connectivityResult != ConnectivityResult.none);
  }

  Future<CloudResult> _postRequest(
      String url, Map<String, dynamic> body) async {
    if (!await hasInternetConnection()) {
      return CloudResult(false, false, "Not connected to the internet.");
    }

    var jsonBody = json.encode(body);
    final response =
        await http.post(Uri.parse(url), body: jsonBody, headers: _headers);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return CloudResult(true, true, "Post request succeeded.", data);
    }
    return CloudResult(false, false, "Error posting request from $url.");
  }

  Future<CloudResult> _getRequest(String url) async {
    if (!await hasInternetConnection()) {
      return CloudResult(false, false, "Not connected to the internet.");
    }

    final response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      return CloudResult(true, true, "Get request succeeded.", data);
    }
    return CloudResult(false, false, "Error getting request from $url.");
  }

  // appt functions
  Future<CloudResult> createOrUpdateAppt(Appointment appt) async {
    if (appt.primaryKey == "") {
      // new -- create with uuid
      appt.primaryKey = CodeGenerator.createCryptoRandomString();
    }

    var jsonAppt = appt.toJson();
    var result = await _postRequest(urlToCreateOrUpdateAppt, jsonAppt);
    if (result.success) {
      appointments.add(appt);
    }
    return result;
  }

  Future<CloudResult> getAllUserAppts(User user) async {
    var body = {"email": user.email, "name": user.name};
    return _postRequest(urlToGetAllUserAppts, body);
  }

  Future<CloudResult> deleteAppt(Appointment appt) async {
    var body = {"primaryKey": appt.primaryKey};
    return _postRequest(urlToDeleteAppt, body);
  }

  // user functions
  Future<CloudResult> getAllUsers() async {
    return _getRequest(urlToGetAllUsers);
  }

  Future<CloudResult> getUser(String email) async {
    var body = {"email": email};
    return _postRequest(urlToGetUser, body);
  }

  Future<CloudResult> createOrUpdateUser(User user) async {
    var jsonUser = user.toJson();
    var result = await _postRequest(urlToCreateOrUpdateUser, jsonUser);
    if (result.success) {
      users.add(user);
    }
    return result;
  }
}
