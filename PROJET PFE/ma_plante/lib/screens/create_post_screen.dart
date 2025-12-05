import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/post.dart';
import '../providers/post_provider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String? _selectedPlantType;
  bool _isPosting = false;
  bool _isPostEmpty = true;

  final List<String> _plantTypes = [
    'Aloe Vera',
    'Monstera',
    'Snake Plant',
    'Peace Lily',
    'Fiddle Leaf Fig',
    'Pothos',
    'Succulent',
    'Cactus',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _contentController.addListener(() {
      setState(() {
        _isPostEmpty = _contentController.text.trim().isEmpty;
      });
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Create Post",
          style: TextStyle(
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF2E7D32),
        ),
        actions: [
          TextButton(
            onPressed: (_isPostEmpty || _isPosting) 
                ? null 
                : () async {
                    setState(() {
                      _isPosting = true;
                    });
                    
                    final newPost = Post(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      userId: postProvider.currentUser?.id ?? 'unknown',
                      userName: postProvider.currentUser?.name ?? 'User',
                      content: _contentController.text.trim(),
                      timestamp: DateTime.now(),
                      likes: [],
                      comments: [],
                      savedBy: [],
                      plantType: _selectedPlantType,
                      imageUrl: _image != null ? "dummy_image_url" : null, 
                    );
                    
                    
                    await Future.delayed(const Duration(seconds: 1));
                    await postProvider.createPost(newPost);
                    
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Post created successfully')),
                      );
                    }
                  },
            style: TextButton.styleFrom(
              foregroundColor: _isPostEmpty || _isPosting 
                  ? Colors.grey
                  : const Color(0xFF2E7D32),
            ),
            child: _isPosting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF2E7D32),
                    ),
                  )
                : const Text(
                    "POST",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.green[100],
                    child: Text(
                      (postProvider.currentUser?.name ?? 'U')[0].toUpperCase(),
                      style: TextStyle(
                        color: Colors.green[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    postProvider.currentUser?.name ?? 'User',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: "What's on your mind about plants?",
                  border: InputBorder.none,
                ),
                maxLines: 8,
                minLines: 3,
              ),
            ),

            
            if (_image != null)
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: FileImage(_image!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 24,
                    right: 24,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _image = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            // Plant type selector
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                value: _selectedPlantType,
                hint: const Text("Select plant type (optional)"),
                isExpanded: true,
                underline: Container(),
                icon: const Icon(Icons.keyboard_arrow_down),
                items: _plantTypes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedPlantType = newValue;
                  });
                },
              ),
            ),

            // Add image, tags buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showImageSourceDialog();
                      },
                      icon: const Icon(Icons.photo),
                      label: const Text("Add Photo"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
