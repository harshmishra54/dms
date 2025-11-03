import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class EventPhotosSection extends StatefulWidget {
  final List<File> eventPhotos;
  final void Function(List<File>) onPhotosChanged;

  const EventPhotosSection({
    Key? key,
    required this.eventPhotos,
    required this.onPhotosChanged,
  }) : super(key: key);

  @override
  State<EventPhotosSection> createState() => _EventPhotosSectionState();
}

class _EventPhotosSectionState extends State<EventPhotosSection> {
  final ImagePicker _picker = ImagePicker();

  Future<bool> _requestPermission(Permission permission) async {
    var status = await permission.status;
    if (status.isDenied || status.isRestricted) {
      status = await permission.request();
    }
    return status.isGranted;
  }

  Future<void> _showSelectImageDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select Image'),
          children: [
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                _takePhoto();
              },
              child: const Text('Take Photo'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                _chooseFromGallery();
              },
              child: const Text('Choose from gallery'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _takePhoto() async {
    final cameraPermission = await _requestPermission(Permission.camera);
    if (!cameraPermission) {
      _showPermissionDeniedDialog('Camera permission is required to take photos.');
      return;
    }
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      _showPhotoConfirmationDialog(File(photo.path));
    }
  }

  Future<void> _chooseFromGallery() async {
    final photosPermission = await _requestPermission(Permission.photos);
    final storagePermission = await _requestPermission(Permission.storage);

    if (!photosPermission && !storagePermission) {
      _showPermissionDeniedDialog('Gallery permission is required to select photos.');
      return;
    }

    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      final newFiles = pickedFiles.map((xfile) => File(xfile.path)).toList();

      // Max 5 photos check
      final currentCount = widget.eventPhotos.length;
      final availableSlots = 5 - currentCount;
      if (availableSlots <= 0) {
        _showMaxPhotosDialog();
        return;
      }

      final filesToAdd = newFiles.length > availableSlots
          ? newFiles.sublist(0, availableSlots)
          : newFiles;

      final updatedList = List<File>.from(widget.eventPhotos)..addAll(filesToAdd);
      widget.onPhotosChanged(updatedList);
    }
  }

  void _showPermissionDeniedDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Denied'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  void _showPhotoConfirmationDialog(File photo) {
    // Max 5 photos check before confirming
    if (widget.eventPhotos.length >= 5) {
      _showMaxPhotosDialog();
      return;
    }

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Photo'),
          content: Image.file(photo),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Incorrect'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedList = List<File>.from(widget.eventPhotos);
                updatedList.add(photo);
                widget.onPhotosChanged(updatedList);
                Navigator.pop(context);
              },
              child: const Text('Correct'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMaxPhotosDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limit Reached'),
        content: const Text('You can only add up to 5 photos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Event Photos (upto 5)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Please capture portrait(horizontal) shop front side Photo',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showSelectImageDialog,
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: widget.eventPhotos.isEmpty
                ? const Center(
              child: Icon(
                Icons.image_outlined,
                size: 60,
                color: Colors.grey,
              ),
            )
                : ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(8),
              itemCount: widget.eventPhotos.length,
              itemBuilder: (context, index) {
                final photo = widget.eventPhotos[index];
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 120,
                      height: 130,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: FileImage(photo),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () {
                          final updatedList =
                          List<File>.from(widget.eventPhotos);
                          updatedList.removeAt(index);
                          widget.onPhotosChanged(updatedList);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black54,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
