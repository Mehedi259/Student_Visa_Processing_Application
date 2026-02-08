// lib/presentation/screens/massage_screen/massage_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:io';
import '../../../core/custom_assets/assets.gen.dart';
import '../../../global/controler/massage/massage_controler.dart';
import '../../widgets/custom_navigation/custom_navbar.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final MessageController _controller = Get.put(MessageController());
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isSearchVisible = false;
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Auto-scroll to bottom after messages load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollToBottom(animated: false);
      });
    });
  }

  void _scrollToBottom({bool animated = true}) {
    if (_scrollController.hasClients) {
      if (animated) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    }
  }

  void _onScroll() {
    // Show/hide scroll to bottom button
    if (_scrollController.hasClients) {
      final isAtBottom = _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100;

      if (_showScrollToBottom == isAtBottom) {
        setState(() {
          _showScrollToBottom = !isAtBottom;
        });
      }
    }

    // Load more when scrolling UP (to load older messages)
    if (_scrollController.position.pixels <=
        _scrollController.position.minScrollExtent + 200) {
      _controller.loadMoreMessages(context: context);
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchController.clear();
        _controller.searchMessages('');
      }
    });
  }

  void _sendMessage() {

    _controller
        .sendMessage(
      subject: 'Message',
      body: _messageController.text.trim(),
      context: context,
    )
        .then((_) {
      // Scroll to bottom after sending
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollToBottom();
      });
    });

    _messageController.clear();
  }

  void _showAttachmentOptions(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: _buildAttachmentPopup(context),
        );
      },
    );
  }

  Widget _buildAttachmentPopup(BuildContext context) {
    return Container(
      width: 238,
      height: 107,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
              _controller.pickImage(context: context);
            },
            child: Container(
              height: 53.5,
              padding: const EdgeInsets.symmetric(horizontal: 19.71),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Assets.images.uploadImageIcon.image(
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Upload an image',
                    style: TextStyle(
                      color: Color(0xFF1D1B20),
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(height: 1, color: Colors.grey.shade300),
          InkWell(
            onTap: () {
              Navigator.pop(context);
              _controller.pickFile(context: context);
            },
            child: Container(
              height: 52.5,
              padding: const EdgeInsets.symmetric(horizontal: 18.37),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Assets.images.uploadAttachmentIcon.image(
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Upload an attachment',
                    style: TextStyle(
                      color: Color(0xFF1D1B20),
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAttachment(String url) async {
    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opening attachment...'),
            duration: Duration(seconds: 1),
            backgroundColor: Color(0xFF5B7FBF),
          ),
        );
      }

      final uri = Uri.parse(url);

      // Try different launch modes
      bool launched = false;

      // Try 1: External Application
      try {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        print('External application failed: $e');
      }

      // Try 2: Platform Default
      if (!launched) {
        try {
          launched = await launchUrl(
            uri,
            mode: LaunchMode.platformDefault,
          );
        } catch (e) {
          print('Platform default failed: $e');
        }
      }

      // Try 3: Download and open for images
      if (!launched &&
          (url.toLowerCase().endsWith('.jpg') ||
              url.toLowerCase().endsWith('.jpeg') ||
              url.toLowerCase().endsWith('.png'))) {
        await _downloadAndOpen(url);
      } else if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Could not open attachment. Please check your browser settings.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadAndOpen(String url) async {
    try {
      // Download file
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final dir = await getTemporaryDirectory();
        final fileName = url.split('/').last;
        final file = File('${dir.path}/$fileName');

        await file.writeAsBytes(bytes);

        // Try to open the downloaded file
        final uri = Uri.file(file.path);
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (!launched && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File downloaded to: ${file.path}'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        throw Exception('Failed to download file');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy @ HH:mm').format(dateTime);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final font = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Message Board',
          style: TextStyle(
            fontSize: 18 * font,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Assets.images.massageBoardSearchIcon.image(
              width: 24,
              height: 24,
            ),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearchVisible)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: TextField(
                controller: _searchController,
                onChanged: (value) => _controller.searchMessages(value),
                decoration: InputDecoration(
                  hintText: 'Search messages...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                Obx(() {
                  if (_controller.isLoading.value &&
                      _controller.messages.isEmpty) {
                    return _buildShimmerLoading();
                  }

                  final messages = _controller.filteredMessages;

                  if (messages.isEmpty) {
                    return const Center(
                      child: Text('No messages found'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      // Disabled - no reload
                    },
                    notificationPredicate: (_) =>
                        false, // Disable pull to refresh
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      physics: const AlwaysScrollableScrollPhysics(),
                      cacheExtent: 500, // Cache more items for smooth scrolling
                      addAutomaticKeepAlives: true,
                      itemCount: messages.length +
                          (_controller.isLoadingMore.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Show loading at top for older messages
                        if (index == 0 && _controller.isLoadingMore.value) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final messageIndex =
                            _controller.isLoadingMore.value ? index - 1 : index;

                        final message = messages[messageIndex];

                        return RepaintBoundary(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: message.isFromStudent
                                ? _buildUserMessage(
                                    width: width,
                                    message: message,
                                  )
                                : _buildCoachMessage(
                                    width: width,
                                    message: message,
                                  ),
                          ),
                        );
                      },
                    ),
                  );
                }),

                // Scroll to Bottom Button (WhatsApp style)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  right: 16,
                  bottom: _showScrollToBottom ? 16 : -60,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(30),
                    child: InkWell(
                      onTap: () => _scrollToBottom(),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF5B7FBF),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            if (_controller.selectedFileName.value.isNotEmpty) {
              return Container(
                padding: const EdgeInsets.all(8),
                color: Colors.blue.shade50,
                child: Row(
                  children: [
                    const Icon(Icons.attach_file, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _controller.selectedFileName.value,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: _controller.clearAttachment,
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          _buildMessageInput(width),
        ],
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 3),
    );
  }

  Widget _buildUserMessage({
    required double width,
    required message,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: width * 0.75),
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            color: Color(0xFF5B7FBF),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(6),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HtmlWidget(
                message.body,
                textStyle: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
              if (message.hasAttachment) ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _openAttachment(message.attachment!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.attach_file, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'View Attachment',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatTime(message.messageDate),
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildCoachMessage({
    required double width,
    required message,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: width * 0.75),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
              bottomLeft: Radius.circular(6),
            ),
          ),
          child: HtmlWidget(
            message.body,
            textStyle: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Flexible(
              child: Text(
                message.posterName,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatTime(message.messageDate),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessageInput(double width) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Type your message here...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showAttachmentOptions(context),
                    child: Assets.images.clip.image(
                      width: 22,
                      height: 22,
                      color: const Color(0xFF5B7FBF),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Obx(() {
            return Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF5B7FBF),
                shape: BoxShape.circle,
              ),
              child: _controller.isSending.value
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : IconButton(
                      icon: Assets.images.sendIcon.image(
                        width: 30,
                        height: 30,
                      ),
                      onPressed: _sendMessage,
                    ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        final isUser = index % 2 == 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: isUser
                          ? const Radius.circular(20)
                          : const Radius.circular(6),
                      bottomRight: isUser
                          ? const Radius.circular(6)
                          : const Radius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: 120,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
