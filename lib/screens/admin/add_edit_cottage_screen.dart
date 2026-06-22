import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cottage_model.dart';
import '../../providers/cottage_provider.dart';
import '../../widgets/app_logo_title.dart';

class AddEditCottageScreen extends StatefulWidget {
  final CottageModel? cottage;

  const AddEditCottageScreen({super.key, this.cottage});

  @override
  State<AddEditCottageScreen> createState() => _AddEditCottageScreenState();
}

class _AddEditCottageScreenState extends State<AddEditCottageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _capacityController = TextEditingController();
  String _status = 'available';
  String _image = 'assets/images/family.jpg';

  final List<String> _imageOptions = const [
    'assets/images/family.jpg',
    'assets/images/club.jpg',
    'assets/images/double.jpg',
    'assets/images/viproom.jpg',
    'assets/images/specialwooden.jpg',
    'assets/images/gardentable.jpg',
    'assets/images/pooltable.jpg',
    'assets/images/poolcottage.jpg',
    'assets/images/veranda1.jpg',
    'assets/images/veranda2.jpg',
    'assets/images/veranda3.jpg',
    'assets/images/veranda4.jpg',
    'assets/images/roundtable.jpg',
    'assets/images/swing.jpg',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.cottage != null) {
      _nameController.text = widget.cottage!.name;
      _descriptionController.text = widget.cottage!.description;
      _priceController.text = widget.cottage!.price.toString();
      _capacityController.text = widget.cottage!.capacity.toString();
      _status = widget.cottage!.status;
      if (_imageOptions.contains(widget.cottage!.image)) {
        _image = widget.cottage!.image;
      }
    }
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<CottageProvider>(context, listen: false);
      CottageModel cottage = CottageModel(
        id: widget.cottage?.id,
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        capacity: int.parse(_capacityController.text),
        image: _image,
        status: _status,
      );

      bool success;
      if (widget.cottage == null) {
        success = await provider.addCottage(cottage);
      } else {
        success = await provider.updateCottage(cottage);
      }

      if (success && mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppLogoTitle(
          widget.cottage == null ? 'Add Cottage' : 'Edit Cottage',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Cottage Name'),
                validator: (val) => val!.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (val) => val!.isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                      validator: (val) => val!.isEmpty ? 'Enter price' : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      controller: _capacityController,
                      decoration: const InputDecoration(labelText: 'Capacity'),
                      keyboardType: TextInputType.number,
                      validator: (val) =>
                          val!.isEmpty ? 'Enter capacity' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                initialValue: _image,
                items: _imageOptions
                    .map(
                      (image) => DropdownMenuItem(
                        value: image,
                        child: Text(_imageLabel(image)),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _image = val!),
                decoration: const InputDecoration(labelText: 'Cottage Image'),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  color: const Color(0xFFF1F8E9),
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(_image, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                initialValue: _status,
                items: ['available', 'unavailable']
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _status = val!),
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('SAVE COTTAGE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _imageLabel(String path) {
    return path.split('/').last.replaceAll('.jpg', '').replaceAll('_', ' ');
  }
}
