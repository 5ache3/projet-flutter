import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../modals/property.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class PublishPage extends StatefulWidget {
  // final Function(Property) onAddProperty;

  const PublishPage({
    super.key,
    // required this.onAddProperty,
    // required Map<String, List<String>> municipalitiesByProvince,
  });

  @override
  State<PublishPage> createState() => _PublishPageState();
}

class _PublishPageState extends State<PublishPage> {
  File? _image;
  List<File> interiorImages = [];
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final landSizeController = TextEditingController();
  final bedroomController = TextEditingController();
  final kitchenController = TextEditingController();
  final bathroomController = TextEditingController();

  bool isSponsored = false;
  bool hasWifi = false;
  bool hasParking = false;
  bool isFurnished = false;

  String? selectedProvince;
  String? selectedMunicipality;
  DateTime? constructionDate;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickInteriorImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        interiorImages = pickedFiles.map((e) => File(e.path)).toList();
      });
    }
  }

  Future<void> _pickConstructionDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        constructionDate = picked;
      });
    }
  }

  void _openImageFullScreen(File imageFile) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder:
            (context, _, __) => Dismissible(
              key: const Key("imageViewer"),
              direction: DismissDirection.down,
              onDismissed: (_) => Navigator.pop(context),
              child: Container(
                color: Colors.black,
                alignment: Alignment.center,
                child: InteractiveViewer(child: Image.file(imageFile)),
              ),
            ),
      ),
    );
  }

  void _submit() async {
    if (_image != null &&
        titleController.text.isNotEmpty &&
        priceController.text.isNotEmpty) {
      // Get the project directory
      final projectDir = Directory(r'C:\Users\edhim\Desktop\uni_project\projet'); // Ensure this is your actual project path

      // Define the 'uploads' directory inside the project directory
      final uploadsDir = Directory(path.join(projectDir.path, 'uploads'));

      // If the "uploads" folder doesn't exist, create it
      if (!(await uploadsDir.exists())) {
        await uploadsDir.create(recursive: true);
      }

      // Create a unique file name using UUID and keep the original extension
      var uuid = Uuid();
      String extension = path.extension(_image!.path); // Get the file extension
      String uniqueFileName = '${uuid.v4()}$extension';

      // Construct the full path where the image will be saved
      String imagePath = path.join(uploadsDir.path, uniqueFileName);

      // Copy the image file to the uploads directory
      final savedImage = await File(_image!.path).copy(imagePath);

      // Now use the savedImage for the Property
      final location = "$selectedMunicipality, $selectedProvince";

      final property = Property(
        title: titleController.text,
        price: priceController.text,
        location: location,
        image: savedImage, // Use the saved image here
        interiorImages: interiorImages, // You might also want to save these similarly
        landSize: landSizeController.text,
        bedrooms: bedroomController.text,
        kitchens: kitchenController.text,
        bathrooms: bathroomController.text,
        constructionDate: constructionDate,
        hasWifi: hasWifi,
        hasParking: hasParking,
        isFurnished: isFurnished,
        isSponsored: isSponsored,
        isPending: true,
      );

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Succès"),
          content: const Text("Logement ajouté avec succès."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      // Optionally show a validation error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Erreur"),
          content: const Text(
            "Veuillez remplir tous les champs et sélectionner une image.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FA),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text("Publier un logement"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // image principale
              GestureDetector(
                onTap:
                    _image == null
                        ? _pickImage
                        : () => _openImageFullScreen(_image!),
                child:
                    _image == null
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
                            _image!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickInteriorImages,
                icon: const Icon(Icons.photo_library),
                label: const Text("Ajouter photos de l'intérieur"),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    interiorImages.map((file) {
                      return GestureDetector(
                        onTap: () => _openImageFullScreen(file),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            file,
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 16),
              _buildTextField(titleController, "Titre", Icons.title),
              const SizedBox(height: 10),
              _buildTextField(
                priceController,
                "Prix",
                Icons.attach_money,
                true,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                landSizeController,
                "Surface du terrain (m²)",
                Icons.landscape,
                true,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                bedroomController,
                "Nombre de chambres",
                Icons.bed,
                true,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                kitchenController,
                "Nombre de cuisines",
                Icons.kitchen,
                true,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                bathroomController,
                "Nombre de salles de bain",
                Icons.bathtub,
                true,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.grey),
                  const SizedBox(width: 10),
                  Text(
                    constructionDate != null
                        ? "Construit en : ${constructionDate!.toLocal().toString().split(' ')[0]}"
                        : "Date de construction non spécifiée",
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _pickConstructionDate,
                    child: const Text("Choisir"),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 10),

              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text("Wi-Fi disponible"),
                value: hasWifi,
                onChanged: (value) => setState(() => hasWifi = value ?? false),
              ),
              CheckboxListTile(
                title: const Text("Meublé"),
                value: isFurnished,
                onChanged:
                    (value) => setState(() => isFurnished = value ?? false),
              ),
              CheckboxListTile(
                title: const Text("Parking disponible"),
                value: hasParking,
                onChanged:
                    (value) => setState(() => hasParking = value ?? false),
              ),
              CheckboxListTile(
                title: const Text("Sponsoriser ce logement"),
                value: isSponsored,
                onChanged:
                    (value) => setState(() => isSponsored = value ?? false),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _submit,
                  child: Text(
                    "Publier",
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
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, [
    bool isNumeric = false,
  ]) {
    return TextField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    IconData icon,
    List<String> items,
    String? value,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items:
          items
              .map(
                (item) =>
                    DropdownMenuItem<String>(value: item, child: Text(item)),
              )
              .toList(),
      onChanged: onChanged,
    );
  }
}
