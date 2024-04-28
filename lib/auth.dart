import 'package:biometrics_auth/Home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

enum SupportState {
  unknown,
  supported,
  unSupported,
}

class _AuthScreenState extends State<AuthScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  SupportState supportState = SupportState.unknown;
  List<BiometricType>? availableBiometrics;
  @override
  void initState() {
    // TODO: implement initState
    auth.isDeviceSupported().then((bool isSupported) => setState(() =>
        supportState =
            isSupported ? SupportState.supported : SupportState.unSupported));
    super.initState();
  }

  Future<void> checkBiometric() async {
    late bool canCheckBiometric;
    try {
      canCheckBiometric = await auth.canCheckBiometrics;
      debugPrint("Biometric Supported : $canCheckBiometric");
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      canCheckBiometric = false;
    }
  }

  Future<void> getAvailableBiometrics() async {
    late List<BiometricType> biometricType;
    try {
      biometricType = await auth.getAvailableBiometrics();
      debugPrint("support biometric: $biometricType ");
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    }
    if (!mounted) {
      return;
    }
    setState(() {
      availableBiometrics = biometricType;
    });
  }

  Future<void> authenticateWIthBiometrics() async {
    try {
      final authenticated = await auth.authenticate(
        localizedReason: 'Authenticated With Fingerprint',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (!mounted) {
        return;
      }
      if (authenticated) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Home(),
          ),
        );
      }
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometric Authenctication'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              supportState == SupportState.supported
                  ? 'Biometric Authentication is supported on THis Device'
                  : supportState == SupportState.unSupported
                      ? 'Biometric Authentication is  not supported on THis Device'
                      : 'Checking biometric Support ....',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: supportState == SupportState.supported
                    ? Colors.green
                    : supportState == SupportState.unSupported
                        ? Colors.red
                        : Colors.blue,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: authenticateWIthBiometrics,
              child: Text('Authenticate'),
            ),
          ],
        ),
      ),
    );
  }
}
