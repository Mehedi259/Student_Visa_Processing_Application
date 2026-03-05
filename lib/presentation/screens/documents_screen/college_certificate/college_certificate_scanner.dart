// lib/features/screens/documents/college_certificate/college_certificate_scanner.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:developer' as developer;

import '../../../../core/custom_assets/assets.gen.dart';
import '../../../../global/controler/documents/documents_controler.dart';
import '../../../../global/utils/snackbar_utils.dart';

class CollegeCertificateScanner extends StatefulWidget {
  final String documentTitle;
  final String documentDescription;

  const CollegeCertificateScanner({
    super.key,
    this.documentTitle = '',
    this.documentDescription =
    '',
  });

  @override
  State<CollegeCertificateScanner> createState() =>
      _CollegeCertificateScannerState();
}

class _CollegeCertificateScannerState extends State<CollegeCertificateScanner> {
  final DocumentsController _controller = Get.find<DocumentsController>();
  List<String> _scannedPages = [];
  bool _isScanning = false;
  bool _hasNavigatedBack = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.documentTitle;
    _descriptionController.text = widget.documentDescription;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScanning();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _navigateBack() {
    if (!_hasNavigatedBack && mounted) {
      _hasNavigatedBack = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.pop();
        }
      });
    }
  }

  Future<void> _startScanning() async {
    if (!mounted) return;

    setState(() => _isScanning = true);

    try {
      List<String> pictures = [];

      if (Platform.isAndroid) {
        pictures = await CunningDocumentScanner.getPictures(
          noOfPages: 10,
          isGalleryImportAllowed: true,
        ) ??
            [];
      } else if (Platform.isIOS) {
        pictures = await CunningDocumentScanner.getPictures(
          iosScannerOptions: IosScannerOptions(
            imageFormat: IosImageFormat.jpg,
            jpgCompressionQuality: 0.9,
          ),
        ) ??
            [];
      } else {
        pictures = await CunningDocumentScanner.getPictures() ?? [];
      }

      if (!mounted) return;

      if (pictures.isNotEmpty) {
        setState(() {
          _scannedPages = pictures;
          _isScanning = false;
        });
        _showSaveDialog();
      } else {
        setState(() => _isScanning = false);
        _navigateBack();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isScanning = false);
        SnackbarUtils.showError(context, 'Error scanning document: $e');
        _navigateBack();
      }
    }
  }

  void _showSaveDialog() {
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      isDismissible: false,
      builder: (BuildContext dialogContext) => WillPopScope(
        onWillPop: () async => false,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF5B7FBF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_scannedPages.length}/10',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.white),
                        onPressed: _shareDocument,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Title',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(color: Colors.black),
                    decoration: _inputDecoration(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Short Description of File',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.black),
                    decoration: _inputDecoration(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBottomButton(
                          icon: Icons.note_add,
                          label: 'add pages',
                          onTap: () {
                            Navigator.pop(dialogContext);
                            _addMorePages();
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildBottomButton(
                          icon: Icons.edit,
                          label: 'Edit',
                          onTap: () {
                            Navigator.pop(dialogContext);
                            _showImagePreview();
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildBottomButton(
                          icon: Icons.upload_file,
                          label: 'Upload as PDF',
                          onTap: () {
                            Navigator.pop(dialogContext);
                            _uploadAsPDF();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _addMorePages() async {
    setState(() => _isScanning = true);

    try {
      List<String> newPictures = [];

      if (Platform.isAndroid) {
        newPictures = await CunningDocumentScanner.getPictures(
          noOfPages: 10,
          isGalleryImportAllowed: true,
        ) ??
            [];
      } else if (Platform.isIOS) {
        newPictures = await CunningDocumentScanner.getPictures(
          iosScannerOptions: IosScannerOptions(
            imageFormat: IosImageFormat.jpg,
            jpgCompressionQuality: 0.9,
          ),
        ) ??
            [];
      }

      if (!mounted) return;

      if (newPictures.isNotEmpty) {
        setState(() {
          _scannedPages.addAll(newPictures);
          _isScanning = false;
        });
        _showSaveDialog();
      } else {
        setState(() => _isScanning = false);
      }
    } catch (e) {
      setState(() => _isScanning = false);
    }
  }

  void _showImagePreview() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 600),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFF5B7FBF),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text('Preview',
                            textAlign: TextAlign.center,
                            style:
                            TextStyle(color: Colors.white, fontSize: 18)),
                      ),
                      const SizedBox(width: 48)
                    ],
                  ),
                ),
                SizedBox(
                  height: 500,
                  child: PageView.builder(
                    itemCount: _scannedPages.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Expanded(
                            child: InteractiveViewer(
                              child: Image.file(
                                File(_scannedPages[index]),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(16),
                            color: Colors.black87,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Page ${index + 1} of ${_scannedPages.length}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _scannedPages.removeAt(index);
                                    });
                                    Navigator.pop(context);

                                    if (_scannedPages.isNotEmpty) {
                                      _showImagePreview();
                                    } else {
                                      _navigateBack();
                                    }
                                  },
                                  icon: const Icon(Icons.delete),
                                  label: const Text('Delete'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _uploadAsPDF() async {
    developer.log('🚀 Upload button clicked', name: 'CollegeCertificateScanner');

    if (_scannedPages.isEmpty) {
      developer.log('❌ No pages to upload', name: 'CollegeCertificateScanner');
      if (mounted) {
        SnackbarUtils.showInfo(context, 'No pages to upload');
      }
      return;
    }

    // Check if document ID exists
    final documentId = _controller.currentDocumentId.value;
    developer.log('📄 Document ID: $documentId', name: 'CollegeCertificateScanner');

    if (documentId.isEmpty) {
      developer.log('❌ No document ID found', name: 'CollegeCertificateScanner');
      if (mounted) {
        SnackbarUtils.showError(context, 'No document selected. Please try again.');
      }
      return;
    }

    try {
      // Show loading dialog using standard Flutter dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Creating PDF...'),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      developer.log('📦 Creating PDF with ${_scannedPages.length} pages',
          name: 'CollegeCertificateScanner');

      // Create PDF
      final pdf = pw.Document();

      for (int i = 0; i < _scannedPages.length; i++) {
        final imagePath = _scannedPages[i];
        developer.log('📄 Adding page ${i + 1}: $imagePath',
            name: 'CollegeCertificateScanner');

        final imageFile = File(imagePath);
        if (!await imageFile.exists()) {
          developer.log('⚠️ Image file not found: $imagePath',
              name: 'CollegeCertificateScanner');
          continue;
        }

        final imageBytes = await imageFile.readAsBytes();
        final image = pw.MemoryImage(imageBytes);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(image, fit: pw.BoxFit.contain),
              );
            },
          ),
        );
      }

      developer.log('💾 Saving PDF to file', name: 'CollegeCertificateScanner');

      // Save PDF to temp directory
      final output = await getTemporaryDirectory();
      final fileName =
          '${_titleController.text.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      developer.log('✅ PDF created: ${file.path}',
          name: 'CollegeCertificateScanner');
      developer.log('📏 PDF size: ${await file.length()} bytes',
          name: 'CollegeCertificateScanner');

      // Close loading dialog
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      developer.log('📤 Starting upload to API',
          name: 'CollegeCertificateScanner');
      developer.log('📝 Description: ${_descriptionController.text}',
          name: 'CollegeCertificateScanner');

      // Upload the PDF
      final success = await _controller.uploadDocument(
        documentId: documentId,
        description: _descriptionController.text,
        documentFile: file,
      );

      developer.log('Upload result: $success',
          name: 'CollegeCertificateScanner');

      if (success && mounted) {
        SnackbarUtils.showSuccess(
          context,
          'Uploaded \${_scannedPages.length} page(s) as PDF successfully!',
        );

        await Future.delayed(const Duration(milliseconds: 400));
        _navigateBack();
      } else {
        developer.log('❌ Upload failed', name: 'CollegeCertificateScanner');
      }
    } catch (e, stackTrace) {
      developer.log('❌ Error in _uploadAsPDF: $e',
          name: 'CollegeCertificateScanner', error: e, stackTrace: stackTrace);

      // Close loading dialog if open
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (mounted) {
        SnackbarUtils.showError(context, 'Error creating PDF: $e');
      }
    }
  }

  Future<void> _shareDocument() async {
    if (_scannedPages.isEmpty) return;

    try {
      final List<XFile> files =
      _scannedPages.map((path) => XFile(path)).toList();

      await Share.shareXFiles(
        files,
        subject: _titleController.text,
        text: _descriptionController.text,
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset(
            Assets.images.backIcon.path,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Scanner',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50),
          child: _isScanning
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                  color: Color(0xFF5B7FBF)),
              const SizedBox(height: 20),
              Text(
                'Opening Scanner...',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.document_scanner,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 20),
              Text(
                'Scanner Ready',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Position your document and tap scan',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _startScanning,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Start Scanning'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B7FBF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}