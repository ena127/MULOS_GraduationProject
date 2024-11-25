import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:mulos/service/preference_service.dart';


class ApiService {
  static const String baseUrl = 'http://3.39.184.195:5000';
  final ImagePicker _picker = ImagePicker();
  Rx<File?> selectedImage = Rx<File?>(null);

  // 공통 API 요청 함수
  Future<dynamic> apiFetch(String endpoint, String method,
      {Map<String, dynamic>? data}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = {'Content-Type': 'application/json'};
    final body = data != null ? jsonEncode(data) : null;

    http.Response response;
    try {
      if (method == 'POST') {
        response = await http.post(url, headers: headers, body: body);
      } else {
        // GET의 경우
        response = await http.get(url, headers: headers);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        //성공
        return jsonDecode(response.body);
      } else {
        throw Exception('API Error: ${response.statusCode} ${response.body}');
      }
    } catch (error) {
      throw Exception('Failed to connect to API: $error');
    }
  }


  Future<dynamic> getAllRentals() {
    return apiFetch('/rentals', 'GET');
  }

  Future<dynamic> getUserRentals(int userId) {
    return apiFetch('/rentals/$userId', 'GET');
  }

  // Returns API
  Future<dynamic> addReturn(Map<String, dynamic> returnData) {
    return apiFetch('/returns', 'POST', data: returnData);
  }

  Future<dynamic> getAllReturns() {
    return apiFetch('/returns', 'GET');
  }

  Future<dynamic> getUserReturns(int userId) {
    return apiFetch('/returns/$userId', 'GET');
  }

  // User API
  Future<dynamic> getUser(int userId) {
    return apiFetch('/users/$userId', 'GET');
  }



  // 유저 등록 API 호출 함수
  Future<bool> registerUser(Map<String, dynamic> userData) async {
    final url = Uri.parse('$baseUrl/auth/signup');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      // 서버 응답이 배열 형태인지 확인
      final responseData = jsonDecode(response.body);
      if (responseData is List) {
        // 응답이 배열 형태로 반환되는 경우
        final Map<String, dynamic> data = responseData[0];

        if (data['message'] == 'User registered successfully') {
          print("[DEBUG] User registration successful");
          return true;
        }
      } else if (responseData is Map && responseData['message'] == 'User registered successfully') {
        print("[DEBUG] User registration successful");
        return true;
      }

      print("[DEBUG] User registration failed with unexpected response");
      return false;
    } catch (error) {
      print("Error in registerUser: $error");
      return false;
    }
  }

  // Device API
  Future<dynamic> getDevice(int deviceId) {
    return apiFetch('/devices/$deviceId', 'GET');
  }

  Future<List<String>> getDeviceTypes() async {
    final response = await http.get(Uri.parse('$baseUrl/devices/types'));
    return (jsonDecode(response.body) as List<dynamic>).cast<String>();
  }

  //기기 모델 가져옴 (맥북 프로, 맥북 에어, 등)
  Future<List<String>> getDeviceModels(String type) async {
    final response = await http.get(Uri.parse('$baseUrl/devices/models?type=$type'));
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List<dynamic>).cast<String>();
    } else {
      throw Exception('Failed to load device models');
    }
  }

  // 기기이름으로 id 받아오기
  Future<int?> getDeviceIdByName(String deviceName) async {
    final response = await apiFetch('/devices/id?device_name=$deviceName', 'GET');
    return response != null ? response['device_id'] as int : null;
  }
  // 대여 가능한 기기명 목록 불러옴
  Future<List<String>> getAvailableDevices(String model) async {
    final response = await http.get(Uri.parse('$baseUrl/devices/available?model=$model'));
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List<dynamic>).cast<String>();
    } else {
      throw Exception('Failed to fetch available devices');
    }
  }

  /// 대여 요청
  Future<bool> addRental(Map<String, dynamic> rentalData) async {
    final url = Uri.parse('$baseUrl/rentals');

    try {
      print('Rental data being sent: $rentalData');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(rentalData),
      );
      // 상태 코드가 200 또는 201일 경우 성공
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error in addRental: $e");
      return false;
    }
  }
  Future<dynamic> registerDevice(Map<String, dynamic> deviceData) {
    return apiFetch('/devices', 'POST', data: deviceData);
  }


  // 로그인 API 호출 함수
  Future<bool> isLoginUser(String studentId, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'student_id': studentId, 'password': password}),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        // 응답을 리스트로 파싱
        final List<dynamic> dataList = jsonDecode(response.body);

        if (dataList.isEmpty) {
          print('Error: Response list is empty');
          return false;
        }

        final Map<String, dynamic> data = dataList[0]; // 리스트의 첫 번째 요소 접근
        final token = data['token'];
        final user = data['user'];

        if (user == null) {
          print('Error: User data is missing from the response');
          return false;
        }
        final appPreferences = AppPreferences();

        await appPreferences.save('authToken', token ?? '');
        await appPreferences.save('studentId', user['student_id'] ?? '');

        await appPreferences.save('name', user['name'] ?? '');
        await appPreferences.save('role', user['role']?.toString() ?? '');
        await appPreferences.save('email', user['email'] ?? '');
        await appPreferences.save('professor', user['professor'] ?? '');
        await appPreferences.save('photoUrl', user['photo_url'] ?? '');

        final storedStudentId = await appPreferences.get('studentId');
        print('Stored studentId: $storedStudentId'); // 로그로 저장된 값 확인

        return true;
      } else {
        print('Login failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error in isLoginUser: $e');
      return false;
    }
  }


  // 갤러리 이미지 받아오기
  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  //서버에 이미지 업로드하고 url받아오기
  Future<String?> uploadImage(File image) async {
    final url = Uri.parse('$baseUrl/upload/upload'); // 서버의 업로드 엔드포인트
    final request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('image', image.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);
      final photoUrl = jsonResponse['photo_url'];

      print('Uploaded photo URL: $photoUrl'); // photo_url 출력
      return photoUrl;
    } else {
      print('Image upload failed: ${response.statusCode}');
      return null;
    }
  }
  // 교수님 이름 받아오기
  Future<List<String>> getProfessors() async {
    final response = await apiFetch('/professors', 'GET');
    return (response as List<dynamic>).cast<String>();
  }

}
