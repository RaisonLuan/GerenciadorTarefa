import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseCloudMessaging {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  void inicializarFCM() {
    _firebaseMessaging.getToken().then((token) {
      print("Token FCM: $token");
      // Você pode salvar o token no Firestore ou em outro local para enviar notificações
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Mensagem FCM recebida: ${message.notification?.title}");
      // Aqui você pode lidar com a mensagem recebida enquanto o aplicativo está em primeiro plano
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Mensagem FCM aberta por meio do aplicativo: ${message.notification?.title}");
      // Aqui você pode lidar com a mensagem recebida ao abrir o aplicativo
    });
  }

  void configurarListenersFCM() {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Mensagem FCM recebida em segundo plano: ${message.notification?.title}");
    // Você pode adicionar lógica para lidar com a notificação recebida enquanto o aplicativo está em segundo plano
  }
}
