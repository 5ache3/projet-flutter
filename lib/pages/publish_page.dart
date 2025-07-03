import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projet/components/TextField.dart';
import 'package:projet/components/location_picker.dart';
import 'package:projet/constants.dart';
import 'package:projet/pages/home_page.dart';
import '../modals/property.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class PublishPageController extends GetxController {
  File? _image;
  List<File> interiorImages = [];
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final surfaceController = TextEditingController();
  final cityController = TextEditingController();
  final regionController = TextEditingController();
  final typeController = TextEditingController();
  final roomsController = TextEditingController();
  String? location;
  final storage = const FlutterSecureStorage();
  String? user_id;
  String? user_role;
  final String passedUserId;
  final String passedUserRole;
  PublishPageController(this.passedUserId, this.passedUserRole);
  @override
  void onInit() {
    super.onInit();
    initPage();
  }
  Future<void> initPage() async {
    await getTokenData();
  }
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      update();
    }
  }
  Future<void> pickInteriorImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      interiorImages = pickedFiles.map((e) => File(e.path)).toList();
      update();
    }
  }

  Future<void> getTokenData() async {
    String? token = await storage.read(key: 'token');
    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token)['sub'];
      user_id = decodedToken['user_id'];
      user_role = decodedToken['role'];
    } else {
      user_id = passedUserId;
      user_role = passedUserRole;
    }
    update();
  }
  Future<void> submit(BuildContext context) async {
    if (_image != null &&
        titleController.text.isNotEmpty &&
        priceController.text.isNotEmpty) {
      final imageBytes = await _image?.readAsBytes();
      final imageBase64 = base64Encode(imageBytes!);
      final interiorImages64 = await Future.wait(
        interiorImages.map((img) async {
          final bytes = await img.readAsBytes();
          return base64Encode(bytes);
        }),
      );
      final data = {
        'description': titleController.text,
        'price': priceController.text,
        'surface': surfaceController.text,
        'nb_rooms': roomsController.text,
        'type': typeController.text,
        'region': regionController.text,
        'city': cityController.text,
        'location': location,
        'mainImage': imageBase64,
        'images': interiorImages64,
      };
      final url = Uri.parse('$apiUrl/create');
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(data),
        );
        if (response.statusCode == 200) {
          Get.snackbar(
            "Succès",
            "Logement ajouté avec succès.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          });
        } else {
          Get.snackbar(
            "Erreur",
            "Échec de l'ajout du logement. Code: ${response.statusCode}",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (_) {
        Get.snackbar(
          "Erreur",
          "Une erreur est survenue lors de l'envoi.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar(
        "Champs manquants",
        "Veuillez remplir tous les champs et sélectionner une image.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }
}

class PublishPage extends StatelessWidget {
  final String user_id;
  final String user_role;
  const PublishPage({super.key, required this.user_id, required this.user_role});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<PublishPageController>(
      init: PublishPageController(user_id, user_role),
      builder: (controller) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: controller._image == null
                      ? controller.pickImage
                      : () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (context, _, __) => Dismissible(
                          key: const Key("imageViewer"),
                          direction: DismissDirection.down,
                          onDismissed: (_) =>
                              Navigator.pop(context),
                          child: Container(
                            color: Colors.black,
                            alignment: Alignment.center,
                            child: InteractiveViewer(
                                child:
                                Image.file(controller._image!)),
                          ),
                        ),
                      ),
                    );
                  },
                  child: controller._image == null
                      ? Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.camera_alt,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      controller._image!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: controller.pickInteriorImages,
                  icon: const Icon(Icons.photo_library),
                  label: const Text("more images"),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.interiorImages
                      .map((file) => GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (context, _, __) =>
                              Dismissible(
                                key: const Key("imageViewer"),
                                direction: DismissDirection.down,
                                onDismissed: (_) =>
                                    Navigator.pop(context),
                                child: Container(
                                  color: Colors.black,
                                  alignment: Alignment.center,
                                  child: InteractiveViewer(
                                      child: Image.file(file)),
                                ),
                              ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        file,
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.titleController,
                  label: "title",
                  icon: Icons.title,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: controller.priceController,
                  label: "price",
                  icon: Icons.attach_money,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: controller.surfaceController,
                  label: "Surface (m²)",
                  icon: Icons.landscape,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: controller.roomsController,
                  label: "number of rooms",
                  icon: Icons.bed,
                  isNumeric: true,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: controller.regionController,
                  label: "region",
                  icon: Icons.track_changes,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: controller.cityController,
                  label: "city",
                  icon: Icons.location_city,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: controller.typeController,
                  label: "type",
                  icon: Icons.house,
                ),
                const SizedBox(height: 20),
                PickLocationBox(
                  onLocationPicked: (cords) {
                    controller.location = cords;
                    controller.update();
                  },
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding:
                      const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => controller.submit(context),
                    child: Text(
                      "Submit",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
