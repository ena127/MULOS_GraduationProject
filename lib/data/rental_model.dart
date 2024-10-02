import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';




class RentalModel {
  String uid;
  String type; // rental , return
  String deviceCategory; // 기종
  String deviceName; // 기기
  String professor; // 교수님 성함
  int requestTime; // timestamp
  int approveTime; // 승인 시간
  String status; // 대여 대기, 대여 승인 완료, 반납 완료
  // "wait","rental_confirm","return_confirm"

  RentalModel({
    required this.uid,
    required this.type,
    required this.deviceCategory,
    required this.deviceName,
    required this.professor,
    required this.requestTime,
    required this.approveTime,
    required this.status,
  });

  // 객체를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() => {
    'uid': uid,
    'type': type,
    'deviceCategory': deviceCategory,
    'deviceName': deviceName,
    'professor': professor,
    'requestTime': requestTime,
    'approveTime': approveTime,
    'status': status
  };

  // JSON을 객체로 변환하는 메서드
  factory RentalModel.fromJson(Map<String, dynamic> json) {
    return RentalModel(
      uid: json['uid'],
      type: json['type'],
      deviceCategory: json['deviceCategory'],
      deviceName: json['deviceName'],
      professor: json['professor'],
      requestTime: json['requestTime'],
      approveTime: json['approveTime'],
      status: json['status']
    );
  }

  static Future<void> saveRentalInfoList(List<RentalModel> items) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonList = items.map((item) => jsonEncode(item)).toList();
    prefs.setStringList('rental_info_list', jsonList);
  }

  static Future<List<RentalModel>> getRentalInfoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonList = prefs.getStringList('rental_info_list');

    if (jsonList != null) {
      return jsonList.map((jsonString) {
        Map<String, dynamic> userMap = jsonDecode(jsonString);
        return RentalModel.fromJson(userMap);
      }).toList();
    }

    return [];
  }




  static Future<void> updateRentalByUid(String uid, String newStatus) async {
    List<RentalModel> rentalList = await getRentalInfoList();

    for (var rental in rentalList) {
      if (rental.uid == uid) {
        rental.status = newStatus;
        break;
      }
    }

    await saveRentalInfoList(rentalList);
  }


}

