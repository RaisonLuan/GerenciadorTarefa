import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class UploadImagem extends StatefulWidget {
  final Function(String)? onImageUploaded; // Callback para notificar o upload concluído

  const UploadImagem({Key? key, this.onImageUploaded}) : super(key: key);

  @override
  _UploadImagemState createState() => _UploadImagemState();
}

class _UploadImagemState extends State<UploadImagem> {
  final picker = ImagePicker();
  File? _image;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _image = null;
    _loadImageUrlFromPrefs();
  }

  void _loadImageUrlFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedImageUrl = prefs.getString('imageUrl');
    if (savedImageUrl != null) {
      setState(() {
        _imageUrl = savedImageUrl;
      });
    }
  }

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        _image = imageFile;
      });

      await uploadImage(imageFile);
    } else {
      print('Nenhuma imagem selecionada.');
    }
  }

  Future<void> uploadImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference firebaseStorageRef =
      FirebaseStorage.instance.ref().child('uploads/$fileName');

      UploadTask uploadTask;
      if (kIsWeb) {
        uploadTask =
            firebaseStorageRef.putData(await imageFile.readAsBytes());
      } else {
        uploadTask = firebaseStorageRef.putFile(imageFile);
      }

      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      setState(() {
        _imageUrl = downloadUrl; // Atualiza a URL da imagem
      });

      // Salva a URL da imagem no SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('imageUrl', downloadUrl);

      // Notifica o upload concluído usando o callback
      if (widget.onImageUploaded != null) {
        widget.onImageUploaded!(downloadUrl);
      }
    } catch (e) {
      print('Erro ao fazer upload da imagem: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: getImage,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey,
          image: _imageUrl != null
              ? DecorationImage(
            image: NetworkImage(_imageUrl!),
            fit: BoxFit.cover,
          )
              : null,
        ),
        child: _imageUrl == null
            ? Icon(Icons.person, size: 40, color: Colors.white)
            : null,
      ),
    );
  }
}
