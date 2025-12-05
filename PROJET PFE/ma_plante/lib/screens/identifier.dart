import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class IdentifierPage extends StatefulWidget {
  const IdentifierPage({Key? key}) : super(key: key);

  @override
  _IdentifierPageState createState() => _IdentifierPageState();
}

class _IdentifierPageState extends State<IdentifierPage> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _showOptions = false;

  Future<void> _takePicture() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _selectedImage = File(photo.path);
        _showOptions = false;
      });
      _navigateToResultPage();
    }
  }

  Future<void> _importPicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _showOptions = false;
      });
  
      _navigateToResultPage();
    }
  }

  void _toggleOptions() {
    setState(() {
      _showOptions = !_showOptions;
    });
  }

  void _navigateToResultPage() {
    
  }

  int _currentNavIndex = 0;

  void _onNavItemTapped(int index) {
    setState(() {
      _currentNavIndex = index;
    });

    switch (index) {
      case 0: 
        Navigator.pushReplacementNamed(context, '/homepage');
        break;
      case 1: 
        Navigator.pushNamed(context, '/categories');
        break;
      case 2: 
        break;
      case 3: 
        Navigator.pushNamed(context, '/chat');
        break;
      case 4: 
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green.shade900, Colors.green.shade300],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.local_florist,
                      color: Colors.white,
                      size: 30,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Identifier',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 3.0,
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              GestureDetector(
                onTap: _toggleOptions,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.width * 0.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3.0),
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.55,
                          height: MediaQuery.of(context).size.width * 0.55,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 1.0,
                              style: BorderStyle.solid,
                            ),
                          ),
                        ),
                      ),

      
                      if (!_showOptions)
                        const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                          size: 50,
                        ),
                    ],
                  ),
                ),
              ),

              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _showOptions ? 150 : 0,
                curve: Curves.easeInOut,
                child:
                    _showOptions
                        ? Column(
                          children: [
                            const SizedBox(height: 20),
                            _buildOptionButton(
                              icon: Icons.camera_alt,
                              label: "Prendre une image",
                              onTap: _takePicture,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(height: 10),
                            _buildOptionButton(
                              icon: Icons.photo_library,
                              label: "Importer une photo",
                              onTap: _importPicture,
                              color: Colors.green.shade500,
                            ),
                          ],
                        )
                        : const SizedBox(),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        backgroundColor: Colors.green,
        child: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
