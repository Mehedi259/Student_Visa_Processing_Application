import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iywt/core/routes/routes.dart';

import '../../../../core/custom_assets/assets.gen.dart';
import '../../../../core/routes/route_path.dart';
import '../../../widgets/custom_navigation/custom_navbar.dart';
import '../college_transcript/college_transcript_widget/details.dart';
import '../college_transcript/college_transcript_widget/requirements.dart';
import '../college_transcript/college_transcript_widget/status.dart';
import '../college_transcript/college_transcript_widget/uploads.dart';


class CollegeTranscriptScannerScreen extends StatefulWidget {
  const CollegeTranscriptScannerScreen({super.key});

  @override
  State<CollegeTranscriptScannerScreen> createState() => _CollegeTranscriptScannerScreenState();
}

class _CollegeTranscriptScannerScreenState extends State<CollegeTranscriptScannerScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double horizontalPadding = size.width * 0.05;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),

      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE8F3FF),
                borderRadius: BorderRadius.circular(25),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.asset(
                  Assets.images.backIcon.path,
                  width: 157,
                  height: 118,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          'College Transcript',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Nunito Sans',
            fontWeight: FontWeight.w500,
            color: Color(0xFF1D1B20),
          ),
        ),
        backgroundColor: const Color(0xFFFDFDFD),
        elevation: 0,
      ),

      body: Column(
        children: [
          _buildTabBar(horizontalPadding),
          Expanded(
            child: _buildTabContent(horizontalPadding),
          ),
        ],
      ),

      floatingActionButton:
      _selectedTabIndex == 3 ? _buildFloatingButtons() : null,

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: const CustomNavBar(currentIndex: 2),
    );
  }

  // -------------------- TAB BAR --------------------
  Widget _buildTabBar(double hPadding) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: hPadding, vertical: 10),
      height: 45,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF0F8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _buildTab('Details', 0),
          _buildTab('Requirements', 1),
          _buildTab('Status', 2),
          _buildTab('Uploads', 3),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF375BA4) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? const Color(0xFFF5F5F7)
                    : const Color(0xFF1D1B20),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // -------------------- TAB CONTENT --------------------
  Widget _buildTabContent(double hPadding) {
    switch (_selectedTabIndex) {
      case 0:
        return  DetailsTab(horizontalPadding: hPadding);
      case 1:
        return RequirementsTab(horizontalPadding: hPadding);
      case 2:
        return StatusTab(horizontalPadding: hPadding);
      case 3:
        return UploadsTab(horizontalPadding: hPadding);
      default:
        return const SizedBox();
    }
  }

  // -------------------- FLOATING BUTTON --------------------
  Widget _buildFloatingButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80), // bottom navbar er jonne space
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'document',
            backgroundColor: const Color(0xFF375BA4),
            child: Image.asset(
              Assets.images.uploadAttachmentIcon.path,
              color: Colors.white,
              width: 28,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            heroTag: 'scan',
            backgroundColor: const Color(0xFF375BA4),
            child: Image.asset(
              Assets.images.scanner.path,
              color: Colors.white,
              width: 28,
            ),
            onPressed: () =>
                context.push(RoutePath.collegeTranscriptScanner.addBasePath),
          ),
        ],
      ),
    );
  }
}
