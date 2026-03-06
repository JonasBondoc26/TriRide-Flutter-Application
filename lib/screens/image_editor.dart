import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../models/data_store.dart';

class ImageEditorScreen extends StatefulWidget {
  const ImageEditorScreen({super.key});

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  Uint8List? _imageBytes;
  img.Image? _originalImage;
  img.Image? _editedImage;
  int _rotationDegrees = 0;
  
  // Crop variables
  Offset _cropStart = const Offset(0.2, 0.2);
  Offset _cropEnd = const Offset(0.8, 0.8);
  bool _isCropping = false;
  Offset? _dragStart;
  String _dragHandle = '';

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        final decodedImage = img.decodeImage(bytes);
        
        if (decodedImage != null) {
          setState(() {
            _imageBytes = bytes;
            _originalImage = decodedImage;
            _editedImage = img.copyResize(decodedImage, width: decodedImage.width);
            _rotationDegrees = 0;
            _cropStart = const Offset(0.2, 0.2);
            _cropEnd = const Offset(0.8, 0.8);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _rotateImage() {
    if (_editedImage == null) return;
    
    setState(() {
      _rotationDegrees = (_rotationDegrees + 90) % 360;
      _editedImage = img.copyRotate(_originalImage!, angle: _rotationDegrees);
    });
  }

  void _applyCrop() {
    if (_editedImage == null) return;
    
    final left = _cropStart.dx.clamp(0.0, 1.0);
    final top = _cropStart.dy.clamp(0.0, 1.0);
    final right = _cropEnd.dx.clamp(0.0, 1.0);
    final bottom = _cropEnd.dy.clamp(0.0, 1.0);
    
    final cropX = (left * _editedImage!.width).toInt();
    final cropY = (top * _editedImage!.height).toInt();
    final cropW = ((right - left) * _editedImage!.width).toInt();
    final cropH = ((bottom - top) * _editedImage!.height).toInt();
    
    if (cropW > 0 && cropH > 0) {
      setState(() {
        _editedImage = img.copyCrop(
          _editedImage!,
          x: cropX,
          y: cropY,
          width: cropW,
          height: cropH,
        );
        _originalImage = _editedImage;
        _cropStart = const Offset(0.2, 0.2);
        _cropEnd = const Offset(0.8, 0.8);
        _isCropping = false;
      });
    }
  }

  void _saveImage() {
    if (_editedImage != null) {
      final pngBytes = Uint8List.fromList(img.encodePng(_editedImage!));
      DataStore.userProfileImage = pngBytes;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo updated!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Photo'),
        actions: [
          if (_editedImage != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveImage,
              tooltip: 'Save',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _editedImage == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 100,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No image selected',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.upload),
                          label: const Text('Choose Photo'),
                        ),
                      ],
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        onPanStart: _isCropping ? (details) {
                          final localPos = details.localPosition;
                          final size = constraints.biggest;
                          final relativePos = Offset(
                            localPos.dx / size.width,
                            localPos.dy / size.height,
                          );
                          
                          _dragStart = relativePos;
                          _dragHandle = _getHandleAtPosition(relativePos);
                        } : null,
                        onPanUpdate: _isCropping ? (details) {
                          if (_dragStart == null) return;
                          
                          final localPos = details.localPosition;
                          final size = constraints.biggest;
                          final relativePos = Offset(
                            (localPos.dx / size.width).clamp(0.0, 1.0),
                            (localPos.dy / size.height).clamp(0.0, 1.0),
                          );
                          
                          setState(() {
                            if (_dragHandle == 'tl') {
                              _cropStart = Offset(
                                relativePos.dx.clamp(0.0, _cropEnd.dx - 0.1),
                                relativePos.dy.clamp(0.0, _cropEnd.dy - 0.1),
                              );
                            } else if (_dragHandle == 'tr') {
                              _cropStart = Offset(_cropStart.dx, relativePos.dy.clamp(0.0, _cropEnd.dy - 0.1));
                              _cropEnd = Offset(relativePos.dx.clamp(_cropStart.dx + 0.1, 1.0), _cropEnd.dy);
                            } else if (_dragHandle == 'bl') {
                              _cropStart = Offset(relativePos.dx.clamp(0.0, _cropEnd.dx - 0.1), _cropStart.dy);
                              _cropEnd = Offset(_cropEnd.dx, relativePos.dy.clamp(_cropStart.dy + 0.1, 1.0));
                            } else if (_dragHandle == 'br') {
                              _cropEnd = Offset(
                                relativePos.dx.clamp(_cropStart.dx + 0.1, 1.0),
                                relativePos.dy.clamp(_cropStart.dy + 0.1, 1.0),
                              );
                            } else if (_dragHandle == 'move') {
                              final delta = relativePos - _dragStart!;
                              final width = _cropEnd.dx - _cropStart.dx;
                              final height = _cropEnd.dy - _cropStart.dy;
                              
                              var newStartX = (_cropStart.dx + delta.dx).clamp(0.0, 1.0 - width);
                              var newStartY = (_cropStart.dy + delta.dy).clamp(0.0, 1.0 - height);
                              
                              _cropStart = Offset(newStartX, newStartY);
                              _cropEnd = Offset(newStartX + width, newStartY + height);
                              _dragStart = relativePos;
                            }
                          });
                        } : null,
                        onPanEnd: _isCropping ? (details) {
                          _dragStart = null;
                          _dragHandle = '';
                        } : null,
                        child: Stack(
                          children: [
                            Center(
                              child: Image.memory(
                                Uint8List.fromList(img.encodePng(_editedImage!)),
                                fit: BoxFit.contain,
                              ),
                            ),
                            if (_isCropping)
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: CropOverlayPainter(
                                    cropStart: _cropStart,
                                    cropEnd: _cropEnd,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          if (_editedImage != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (_isCropping)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Drag corners to resize • Drag center to move',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildToolButton(
                        icon: Icons.upload,
                        label: 'Change',
                        onPressed: _pickImage,
                      ),
                      _buildToolButton(
                        icon: Icons.rotate_right,
                        label: 'Rotate',
                        onPressed: _rotateImage,
                      ),
                      _buildToolButton(
                        icon: _isCropping ? Icons.check : Icons.crop,
                        label: _isCropping ? 'Apply' : 'Crop',
                        onPressed: () {
                          if (_isCropping) {
                            _applyCrop();
                          } else {
                            setState(() => _isCropping = true);
                          }
                        },
                      ),
                      if (_isCropping)
                        _buildToolButton(
                          icon: Icons.close,
                          label: 'Cancel',
                          onPressed: () {
                            setState(() {
                              _isCropping = false;
                              _cropStart = const Offset(0.2, 0.2);
                              _cropEnd = const Offset(0.8, 0.8);
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _saveImage,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Photo'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getHandleAtPosition(Offset position) {
    const handleSize = 0.05;
    
    if ((position - _cropStart).distance < handleSize) return 'tl';
    if ((position - Offset(_cropEnd.dx, _cropStart.dy)).distance < handleSize) return 'tr';
    if ((position - Offset(_cropStart.dx, _cropEnd.dy)).distance < handleSize) return 'bl';
    if ((position - _cropEnd).distance < handleSize) return 'br';
    
    if (position.dx >= _cropStart.dx && position.dx <= _cropEnd.dx &&
        position.dy >= _cropStart.dy && position.dy <= _cropEnd.dy) {
      return 'move';
    }
    
    return '';
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          iconSize: 28,
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey[200],
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

// Custom painter for crop overlay with grid
class CropOverlayPainter extends CustomPainter {
  final Offset cropStart;
  final Offset cropEnd;

  CropOverlayPainter({
    required this.cropStart,
    required this.cropEnd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final left = cropStart.dx * size.width;
    final top = cropStart.dy * size.height;
    final right = cropEnd.dx * size.width;
    final bottom = cropEnd.dy * size.height;
    
    final cropRect = Rect.fromLTRB(left, top, right, bottom);

    // Draw dark overlay outside crop area
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, top), overlayPaint);
    canvas.drawRect(Rect.fromLTRB(0, top, left, bottom), overlayPaint);
    canvas.drawRect(Rect.fromLTRB(right, top, size.width, bottom), overlayPaint);
    canvas.drawRect(Rect.fromLTRB(0, bottom, size.width, size.height), overlayPaint);

    // Draw crop border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(cropRect, borderPaint);

    // Draw grid lines (rule of thirds)
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final cropWidth = right - left;
    final cropHeight = bottom - top;

    // Vertical grid lines
    canvas.drawLine(
      Offset(left + cropWidth / 3, top),
      Offset(left + cropWidth / 3, bottom),
      gridPaint,
    );
    canvas.drawLine(
      Offset(left + 2 * cropWidth / 3, top),
      Offset(left + 2 * cropWidth / 3, bottom),
      gridPaint,
    );

    // Horizontal grid lines
    canvas.drawLine(
      Offset(left, top + cropHeight / 3),
      Offset(right, top + cropHeight / 3),
      gridPaint,
    );
    canvas.drawLine(
      Offset(left, top + 2 * cropHeight / 3),
      Offset(right, top + 2 * cropHeight / 3),
      gridPaint,
    );

    // Draw corner handles with L-shape
    void drawCornerHandle(Offset corner, bool isLeft, bool isTop) {
      final handlePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;

      final accentPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      const handleLength = 25.0;
      final hOffset = isLeft ? handleLength : -handleLength;
      final vOffset = isTop ? handleLength : -handleLength;

      canvas.drawLine(corner, corner + Offset(hOffset, 0), handlePaint);
      canvas.drawLine(corner, corner + Offset(hOffset, 0), accentPaint);
      
      canvas.drawLine(corner, corner + Offset(0, vOffset), handlePaint);
      canvas.drawLine(corner, corner + Offset(0, vOffset), accentPaint);

      canvas.drawCircle(corner, 6, handlePaint);
      canvas.drawCircle(corner, 5, accentPaint);
    }

    drawCornerHandle(Offset(left, top), true, true);
    drawCornerHandle(Offset(right, top), false, true);
    drawCornerHandle(Offset(left, bottom), true, false);
    drawCornerHandle(Offset(right, bottom), false, false);
  }

  @override
  bool shouldRepaint(CropOverlayPainter oldDelegate) => true;
}