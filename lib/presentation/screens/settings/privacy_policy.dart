// ============================================
// lib/presentation/screens/settings/privacy_policy.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iywt/core/routes/routes.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/custom_assets/assets.gen.dart';
import '../../../core/routes/route_path.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          child: IconButton(
            icon: Assets.images.backIcon.image(width: 44, height: 44),
            onPressed: () => context.pop(),
          ),
        ),
        title: const Text(
          'Privacy Policy — It\'s Your World, Travel!',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Your privacy is important to\nIt\'s Your World, Travel!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: GestureDetector(
                onTap: () => _launchURL('https://www.iywt.com/privacy-policy'),
                child: const Text(
                  "IYWT's Complete Privacy Policy",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5B7FBF),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Policy Summary:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 16),

            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black87,
                ),
                children: [
                  const TextSpan(
                    text:
                    'It\'s Your World, Travel! (IYWT) may collect many kinds of "Personal Data" '
                        'about a student and family in preparation for Rotary Youth Exchange or other travel. '
                        'Data may come from the student or traveler, the family, Rotary programs or other sources. '
                        'Primarily, IYWT uses Personal Data to facilitate your success in Rotary Youth Exchange, '
                        'to benefit Rotary Youth Exchange, or for IYWT\'s legitimate business purposes. '
                        'Because most IYWT clients are involved in Rotary Youth Exchange, here is a link to the ',
                  ),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () => _launchURL('https://www.rotary.org/en/privacy-policy'),
                      child: const Text(
                        'Rotary International Privacy Policy',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF5B7FBF),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(
                    text: '. If there is a conflict, the IYWT policy will guide our actions.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black87,
                ),
                children: [
                  const TextSpan(text: 'By visiting '),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () => _launchURL('https://www.iywt.com'),
                      child: const Text(
                        'www.iywt.com',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF5B7FBF),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(
                    text:
                    ' or using any IYWT services, you agree to the IYWT Privacy Policy. '
                        'Parents and children of any age should discuss privacy issues before sharing Personal Data. '
                        '(If you believe someone under the age of 13 has shared Personal Data with IYWT, '
                        'please contact IYWT.)',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'IYWT stores any Personal Data (paper and electronic formats) with reasonable protection. '
                  'Users or their legal parents/guardians may always request access to their files. '
                  'IYWT may store Personal Data as required for legitimate business or legal purposes. '
                  'IYWT will never sell Personal Data. Personal Data is only provided to other parties '
                  'as required by legitimate circumstances. There are ways in which users can limit the '
                  'Personal Data that they provide, but such actions may also limit the ability of IYWT '
                  'to assist with Rotary Youth Exchange and other education.',
              style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
            ),

            const SizedBox(height: 16),

            const Text(
              'Remember: Technology is always changing, and IYWT may take advantage of those changes. '
                  'Both the physical and digital storage of IYWT records, including Personal Data, are in the United States. '
                  'Because some users may live outside the United States, may be citizens of other nations, '
                  'and all clients are travelling outside the United States, IYWT will transfer information across borders '
                  'as necessary to facilitate an exchange. Those transfers will be governed by the IYWT Privacy Policy.',
              style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
            ),

            const SizedBox(height: 16),

            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                children: [
                  const TextSpan(text: 'For more information, please contact IYWT at '),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () => _launchEmail('info@iywt.com'),
                      child: const Text(
                        'info@iywt.com',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF5B7FBF),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(
                    text: ' or 1969 SW Hillcrest Road, Seattle, WA 98166',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Effective as of 15 February 2018',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'IYWT reserves the right to change this policy as necessary.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // URL launcher
  static Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      print('Could not launch $url');
    }
  }

  // Email launcher
  static Future<void> _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (!await launchUrl(uri)) {
      print('Could not launch email');
    }
  }
}
