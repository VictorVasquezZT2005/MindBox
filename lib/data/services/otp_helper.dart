import 'package:otp/otp.dart';
import 'package:base32/base32.dart';

class OtpHelper {
  static String generateTOTP(String secret) {
    if (secret.isEmpty) return '000000';
    try {
      // Normalize secret: remove spaces and handle base32 padding
      String normalizedSecret = secret.replaceAll(' ', '').toUpperCase();
      
      return OTP.generateTOTPCodeString(
        normalizedSecret,
        DateTime.now().millisecondsSinceEpoch,
        algorithm: Algorithm.SHA1,
        isGoogle: true,
      );
    } catch (e) {
      print('TOTP Error: \$e');
      return 'ERROR';
    }
  }

  static Map<String, String>? parseQrCode(String qrData) {
    try {
      final uri = Uri.parse(qrData);
      if (uri.scheme != 'otpauth') return null;

      String service = uri.path.split(':').last;
      String email = uri.queryParameters['issuer'] ?? '';
      String secret = uri.queryParameters['secret'] ?? '';

      return {
        'service': service,
        'email': email,
        'secret': secret,
      };
    } catch (e) {
      return null;
    }
  }
}
