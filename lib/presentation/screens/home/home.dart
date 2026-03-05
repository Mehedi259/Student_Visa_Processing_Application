// lib/presentation/screens/home/home.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/route_path.dart';
import '../../../core/routes/routes.dart';
import '../../../global/controler/home/home_controler.dart';
import '../../widgets/custom_navigation/custom_navbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late HomeController controller;
  late AnimationController _legalEntryController;
  late AnimationController _ticketingController;
  late Animation<double> _legalEntryAnimation;
  late Animation<double> _ticketingAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize controller
    controller = Get.put(HomeController());

    // Legal Entry Animation Controller
    _legalEntryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _legalEntryAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0, // Will be updated from API
    ).animate(CurvedAnimation(
      parent: _legalEntryController,
      curve: Curves.easeOutCubic,
    ));

    // Ticketing Animation Controller
    _ticketingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _ticketingAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0, // Will be updated from API
    ).animate(CurvedAnimation(
      parent: _ticketingController,
      curve: Curves.easeOutCubic,
    ));

    // Listen to dashboard data changes
    ever(controller.dashboardData, (_) {
      _updateAnimations();
    });

    // If data already exists, trigger animation immediately
    if (controller.dashboardData.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateAnimations();
      });
    }
  }

  void _updateAnimations() {
    if (controller.dashboardData.value != null) {
      final legalPercentage =
          controller.dashboardData.value!.legalEntryGauge.percentage / 100;
      final ticketingPercentage =
          controller.dashboardData.value!.ticketingGauge.percentage / 100;

      _legalEntryAnimation = Tween<double>(
        begin: 0.0,
        end: legalPercentage,
      ).animate(CurvedAnimation(
        parent: _legalEntryController,
        curve: Curves.easeOutCubic,
      ));

      _ticketingAnimation = Tween<double>(
        begin: 0.0,
        end: ticketingPercentage,
      ).animate(CurvedAnimation(
        parent: _ticketingController,
        curve: Curves.easeOutCubic,
      ));

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _legalEntryController.forward();
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _ticketingController.forward();
      });
    }
  }

  @override
  void dispose() {
    _legalEntryController.dispose();
    _ticketingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.dashboardData.value == null) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF375BA4),
            ),
          );
        }

        final dashboard = controller.dashboardData.value;

        return RefreshIndicator(
          onRefresh: controller.refreshDashboard,
          color: const Color(0xFF375BA4),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    /// HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.getGreeting(),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              controller.displayName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),

                        /// Notification Button
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8F0FE),
                            shape: BoxShape.circle,
                          ),
                          child: Stack(
                            children: [
                              IconButton(
                                icon: Image.asset(
                                  'assets/images/notifications.png',
                                  width: 24,
                                  height: 24,
                                ),
                                onPressed: () => context
                                    .push(RoutePath.notification.addBasePath),
                              ),
                              if (dashboard != null &&
                                  dashboard.unreadMessages > 0)
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      '${dashboard.unreadMessages}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    /// LEGAL ENTRY PROGRESS CARD
                    if (dashboard != null)
                      AnimatedBuilder(
                        animation: _legalEntryAnimation,
                        builder: (context, child) {
                          return _buildProgressCard(
                            animation: _legalEntryAnimation,
                            title: 'Legal Entry Progress',
                            description: dashboard.legalEntryGauge.title,
                            percentage: dashboard.legalEntryGauge.percentage,
                            color: Color(dashboard.legalEntryGauge.colorValue),
                          );
                        },
                      ),

                    const SizedBox(height: 20),

                    /// TICKETING PROGRESS CARD
                    if (dashboard != null)
                      AnimatedBuilder(
                        animation: _ticketingAnimation,
                        builder: (context, child) {
                          return _buildProgressCard(
                            animation: _ticketingAnimation,
                            title: 'Ticketing Progress',
                            description: dashboard.ticketingGauge.title,
                            percentage: dashboard.ticketingGauge.percentage,
                            color: Color(dashboard.ticketingGauge.colorValue),
                          );
                        },
                      ),

                    const SizedBox(height: 20),

                    /// DEADLINE CARD
                    if (dashboard != null &&
                        dashboard.documentDeadline.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE8E8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Documents Upload Deadline: ${dashboard.documentDeadline}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 30),

                    /// MESSAGE BOARD TITLE
                    const Text(
                      'Message Board',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// MESSAGE CARD
                    if (dashboard != null)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/massages.png',
                                  width: 28,
                                  height: 28,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Messages',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (dashboard.unreadMessages > 0)
                              Row(
                                children: [
                                  Text(
                                    'You have ',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${dashboard.unreadMessages}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    ' unread message${dashboard.unreadMessages > 1 ? 's' : ''}.',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Text(
                                'No unread messages.',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () => context
                                    .push(RoutePath.massageScreen.addBasePath),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5B7FBF),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'View Messages',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
      bottomNavigationBar: const CustomNavBar(currentIndex: 0),
    );
  }

  Widget _buildProgressCard({
    required Animation<double> animation,
    required String title,
    required String description,
    required int percentage,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: animation.value,
                    strokeWidth: 8,
                    backgroundColor: const Color(0xFFE0E0E0),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Text(
                  '$percentage%',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontFamily: 'Nunito Sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5B7FBF),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
