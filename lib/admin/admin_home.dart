import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:date_time_picker/date_time_picker.dart';

class AddMoviePage extends StatefulWidget {
  const AddMoviePage({super.key});

  @override
  State<AddMoviePage> createState() => _AddMoviePageState();
}

class _AddMoviePageState extends State<AddMoviePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _showtimeController = TextEditingController();

  File? _image;
  int? _selectedTheaterId;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitMovie() async {
    if (_formKey.currentState!.validate() &&
        _image != null &&
        _selectedTheaterId != null &&
        _showtimeController.text.isNotEmpty) {
      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://10.0.2.2:3000/movies'),
        );
        request.fields['title'] = _titleController.text;
        request.fields['genre'] = _genreController.text;
        request.fields['time'] = _timeController.text;
        request.fields['price'] = _priceController.text;
        request.fields['theater_id'] = _selectedTheaterId.toString();
        request.fields['showtime'] = _showtimeController.text;
        request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

        var response = await request.send();

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Movie added successfully!")),
          );
          _formKey.currentState!.reset();
          setState(() {
            _image = null;
            _selectedTheaterId = null;
            _showtimeController.clear();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to upload movie")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please complete all fields, select a theater, and pick a showtime")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Movie'),
        centerTitle: true,
        backgroundColor: Color(0xffD59708),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_image != null)
                Image.file(_image!, height: 200, fit: BoxFit.cover),
              TextButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image),
                label: Text('Pick Image'),
              ),
              SizedBox(height: 10),
              _buildTextField(_titleController, 'Title'),
              _buildTextField(_genreController, 'Genre'),
              _buildTextField(_timeController, 'Duration (e.g. 2h)'),
              _buildTextField(_priceController, 'Price', isNumber: true),
              SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _selectedTheaterId,
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Main Theater')),
                  DropdownMenuItem(value: 2, child: Text('Gold')),
                  DropdownMenuItem(value: 3, child: Text('Theater-2')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedTheaterId = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Theater',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null ? 'Select a theater' : null,
              ),
              SizedBox(height: 12),
              DateTimePicker(
                type: DateTimePickerType.dateTimeSeparate,
                controller: _showtimeController,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(Duration(days: 30)),
                dateLabelText: 'Show Date',
                timeLabelText: 'Show Time',
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Showtime',
                ),
                validator: (val) => val == null || val.isEmpty ? 'Select a showtime' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitMovie,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xffD59708),
                  foregroundColor: Colors.white,
                ),
                child: Text('Submit Movie'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) =>
            value == null || value.isEmpty ? 'Enter $label' : null,
      ),
    );
  }
}
