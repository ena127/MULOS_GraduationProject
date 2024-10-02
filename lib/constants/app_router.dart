import 'package:get/get.dart';

import '../view/screens.dart';

abstract class AppRouter {
  AppRouter._();

  static const String home = '/home';
  static const String sign_in = '/sign_in';
  static const String sign_up = '/sign_up';
  static const String admin = '/admin';
  static const String user = '/user';
  static const String menu = '/menu';
  static const String rental = '/rental';
  static const String rental_device_selection = '/rental_device_selection';
  static const String request_rental = '/request_rental';
  static const String confirm_rental = '/confirm_rental';
  static const String return_screen = '/return_screen';
  static const String return_add_photo = '/return_add_photo';
  static const String academic_record = '/academic_record';

  static final List<GetPage> routes = [
    GetPage(
        name: home,
        page: () => HomeScreen(),
    ),
    GetPage(
      name: sign_in,
      page: () => SignInScreen(),
    ),
    GetPage(
      name: sign_up,
      page: () => SignUpScreen(),
    ),
    GetPage(
      name: admin,
      page: () => AdminScreen(),
    ),
    GetPage(
      name: user,
      page: () => UserScreen(),
    ),
    GetPage(
      name: menu,
      page: () => MenuScreen(),
    ),
    GetPage(
      name: rental,
      page: () => RentalScreen(),
    ),
    GetPage(
      name: rental_device_selection,
      page: () => RentalDeviceSelectionScreen(),
    ),
    GetPage(
      name: request_rental,
      page: () => RequestRentalScreen(),
    ),
    GetPage(
      name: confirm_rental,
      page: () => ConfirmRentalScreen(),
    ),
    GetPage(
      name: return_screen,
      page: () => ReturnScreen(),
    ),
    GetPage(
      name: return_add_photo,
      page: () => ReturnAddPhotoScreen(),
    ),
    GetPage(
      name: academic_record,
      page: () => AcademicRecordScreen(),
    ),
  ];


}
