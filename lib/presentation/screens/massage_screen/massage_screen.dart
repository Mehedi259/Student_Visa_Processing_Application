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
import '../../../global/utils/snackbar_utils.dart';

/// Bubble color config by posterType
class _BubbleStyle {
  final Color backgroundColor;
  final Color textColor;
  final bool isRightAligned;

  const _BubbleStyle({
    required this.backgroundColor,
    required this.textColor,
    required this.isRightAligned,
  });
}

_BubbleStyle _getBubbleStyle(String posterType) {
  switch (posterType.toLowerCase()) {
    case 'student':
      return const _BubbleStyle(
        backgroundColor: Color(0xFF375BA4),
        textColor: Colors.white,
        isRightAligned: true,
      );
    case 'coach':
      return const _BubbleStyle(
        backgroundColor: Color(0xFFF5F5F7),
        textColor: Color(0xFF1D1B20),
        isRightAligned: false,
      );
    case 'organizationmember':
    default:
      return const _BubbleStyle(
        backgroundColor: Color(0xFF00D148),
        textColor: Color(0xFFFDFDFD),
        isRightAligned: false,
      );
  }
}


String _formatPosterLabel(String posterName, String posterType) {
  switch (posterType.toLowerCase()) {
    case 'coach':
      return '$posterName - Coach';
    case 'organizationmember':
      return '$posterName - Organization';
    default:
      return posterName;
  }
}

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
  
  // Track expanded state for each message (using String key for messageId)
  final Map<String, bool> _expandedMessages = {};

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollToBottom(animated: false);
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─── Scroll helpers ───────────────────────────────────────────────────────

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    final target = _scrollController.position.maxScrollExtent;
    if (animated) {
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(target);
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;

    final atBottom = pos.pixels >= pos.maxScrollExtent - 100;
    if (_showScrollToBottom == atBottom) {
      setState(() => _showScrollToBottom = !atBottom);
    }

    if (pos.pixels <= pos.minScrollExtent + 200) {
      _controller.loadMoreMessages(context: context);
    }
  }

  // ─── Search ───────────────────────────────────────────────────────────────

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchController.clear();
        _controller.searchMessages('');
        // Scroll to bottom when search is cleared
        Future.delayed(const Duration(milliseconds: 100), () {
          _scrollToBottom(animated: true);
        });
      }
    });
  }

  // ─── Send ─────────────────────────────────────────────────────────────────

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _controller
        .sendMessage(
      subject: 'Message',
      body: text,
      context: context,
    )
        .then((_) => Future.delayed(
      const Duration(milliseconds: 300),
      _scrollToBottom,
    ));

    _messageController.clear();
  }

  // ─── Attachment dialog ────────────────────────────────────────────────────

  void _showAttachmentOptions(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: _buildAttachmentPopup(context),
      ),
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
                        width: 24, height: 24),
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
                        width: 24, height: 24),
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

  // ─── Open / download attachment ───────────────────────────────────────────

  Future<void> _openAttachment(String url) async {
    try {
      if (mounted) SnackbarUtils.showInfo(context, 'Opening attachment...');
      final uri = Uri.parse(url);
      bool launched = false;

      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}

      if (!launched) {
        try {
          launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
        } catch (_) {}
      }

      final lower = url.toLowerCase();
      if (!launched &&
          (lower.endsWith('.jpg') ||
              lower.endsWith('.jpeg') ||
              lower.endsWith('.png'))) {
        await _downloadAndOpen(url);
      } else if (!launched && mounted) {
        SnackbarUtils.showError(
          context,
          'Could not open attachment. Please check your browser settings.',
        );
      }
    } catch (e) {
      if (mounted) SnackbarUtils.showError(context, 'Error: $e');
    }
  }

  Future<void> _downloadAndOpen(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/${url.split('/').last}');
        await file.writeAsBytes(response.bodyBytes);
        final launched = await launchUrl(
          Uri.file(file.path),
          mode: LaunchMode.externalApplication,
        );
        if (!launched && mounted) {
          SnackbarUtils.showWarning(
              context, 'File downloaded to: ${file.path}');
        }
      } else {
        throw Exception('Failed to download file');
      }
    } catch (e) {
      if (mounted) SnackbarUtils.showError(context, 'Download failed: $e');
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _formatTime(DateTime dateTime) =>
      DateFormat('dd MMM yyyy @ HH:mm').format(dateTime);

  /// Strip HTML tags to get plain text length
  String _stripHtmlTags(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
  }

  /// Truncate HTML content to approximately N characters
  String _truncateHtml(String html, int maxLength) {
    final plainText = _stripHtmlTags(html);
    if (plainText.length <= maxLength) {
      return html;
    }

    // Simple truncation - find a good breaking point
    int breakPoint = maxLength;
    final words = plainText.substring(0, maxLength).split(' ');
    if (words.length > 1) {
      words.removeLast(); // Remove partial word
      final truncated = words.join(' ');
      breakPoint = truncated.length;
    }

    // Try to preserve HTML structure for the truncated part
    String result = '';
    int charCount = 0;
    bool inTag = false;

    for (int i = 0; i < html.length && charCount < breakPoint; i++) {
      final char = html[i];
      result += char;

      if (char == '<') {
        inTag = true;
      } else if (char == '>') {
        inTag = false;
      } else if (!inTag) {
        charCount++;
      }
    }

    return result;
  }

  /// Build HTML widget with highlighted search terms
  Widget _buildHighlightedHtml(String html, Color textColor) {
    if (_controller.searchQuery.value.isEmpty) {
      return HtmlWidget(
        html,
        textStyle: TextStyle(
          fontSize: 14,
          color: textColor,
          height: 1.4,
        ),
      );
    }

    // Highlight search query in HTML
    final query = _controller.searchQuery.value;
    final plainText = _stripHtmlTags(html);
    
    // Case-insensitive search and replace with highlighted version
    final highlightedHtml = html.replaceAllMapped(
      RegExp(RegExp.escape(query), caseSensitive: false),
      (match) => '<mark style="background-color: #FFEB3B; color: #000000; padding: 2px 4px; border-radius: 3px;">${match.group(0)}</mark>',
    );

    return HtmlWidget(
      highlightedHtml,
      textStyle: TextStyle(
        fontSize: 14,
        color: textColor,
        height: 1.4,
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildMessageList(width)),
          _buildAttachmentPreview(),
          _buildMessageInput(width),
        ],
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 3),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Message Board',
        style: TextStyle(
          fontSize: 20,
          fontFamily: 'Nunito Sans',
          fontWeight: FontWeight.w600,
          color: Color(0xFF1D1B20),
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      actions: [
        IconButton(
          icon: Assets.images.massageBoardSearchIcon.image(
              width: 24, height: 24),
          onPressed: _toggleSearch,
        ),
      ],
    );
  }

  // ─── Search bar ───────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    if (!_isSearchVisible) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: (query) {
          _controller.searchMessages(query);
          // Scroll to bottom after search to show latest matching messages
          if (query.isNotEmpty) {
            Future.delayed(const Duration(milliseconds: 100), () {
              _scrollToBottom(animated: true);
            });
          }
        },
        decoration: InputDecoration(
          hintText: 'Search messages...',
          prefixIcon: const Icon(Icons.search),
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
      ),
    );
  }

  // ─── Message list ─────────────────────────────────────────────────────────

  Widget _buildMessageList(double width) {
    return Stack(
      children: [
        Obx(() {
          if (_controller.isLoading.value && _controller.messages.isEmpty) {
            return _buildShimmerLoading();
          }

          final messages = _controller.filteredMessages;

          if (messages.isEmpty) {
            return const Center(child: Text('No messages found'));
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            cacheExtent: 800,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: true,
            itemCount: messages.length +
                (_controller.isLoadingMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == 0 && _controller.isLoadingMore.value) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final msgIndex =
              _controller.isLoadingMore.value ? index - 1 : index;
              final message = messages[msgIndex];
              final style = _getBubbleStyle(message.posterType);

              return Padding(
                key: ValueKey(message.messageId),
                padding: const EdgeInsets.only(bottom: 16),
                child: style.isRightAligned
                    ? _buildRightBubble(
                    width: width, message: message, style: style)
                    : _buildLeftBubble(
                    width: width, message: message, style: style),
              );
            },
          );
        }),

        // Scroll-to-bottom FAB
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          right: 16,
          bottom: _showScrollToBottom ? 16 : -60,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              onTap: _scrollToBottom,
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
    );
  }

  // ─── Right bubble (Student — Blue) ────────────────────────────────────────

  Widget _buildRightBubble({
    required double width,
    required dynamic message,
    required _BubbleStyle style,
  }) {
    final messageId = message.messageId.toString();
    final bodyText = _stripHtmlTags(message.body);
    final shouldCollapse = bodyText.length > 200;
    
    // Auto-expand if search query is found in the message
    final hasSearchMatch = _controller.searchQuery.value.isNotEmpty &&
        bodyText.toLowerCase().contains(_controller.searchQuery.value);
    
    final isExpanded = _expandedMessages[messageId] ?? hasSearchMatch;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: width * 0.75),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: style.backgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(6),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (shouldCollapse && !isExpanded)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHighlightedHtml(
                      _truncateHtml(message.body, 200),
                      style.textColor,
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _expandedMessages[messageId] = true;
                        });
                      },
                      child: Text(
                        '...Show more',
                        style: TextStyle(
                          fontSize: 13,
                          color: style.textColor.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHighlightedHtml(
                      message.body,
                      style.textColor,
                    ),
                    if (shouldCollapse && isExpanded) ...[
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _expandedMessages[messageId] = false;
                          });
                        },
                        child: Text(
                          'Show less',
                          style: TextStyle(
                            fontSize: 13,
                            color: style.textColor.withOpacity(0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              if (message.hasAttachment) ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _openAttachment(message.attachment!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.attach_file,
                            color: Colors.white, size: 16),
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
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  // ─── Left bubble (Coach — Light Grey | OrganizationMember — Green) ────────

  Widget _buildLeftBubble({
    required double width,
    required dynamic message,
    required _BubbleStyle style,
  }) {
    final messageId = message.messageId.toString();
    final bodyText = _stripHtmlTags(message.body);
    final shouldCollapse = bodyText.length > 200;
    
    // Auto-expand if search query is found in the message
    final hasSearchMatch = _controller.searchQuery.value.isNotEmpty &&
        bodyText.toLowerCase().contains(_controller.searchQuery.value);
    
    final isExpanded = _expandedMessages[messageId] ?? hasSearchMatch;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: width * 0.75),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: style.backgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
              bottomLeft: Radius.circular(6),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (shouldCollapse && !isExpanded)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHighlightedHtml(
                      _truncateHtml(message.body, 200),
                      style.textColor,
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _expandedMessages[messageId] = true;
                        });
                      },
                      child: Text(
                        '...Show more',
                        style: TextStyle(
                          fontSize: 13,
                          color: style.textColor.withOpacity(0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHighlightedHtml(
                      message.body,
                      style.textColor,
                    ),
                    if (shouldCollapse && isExpanded) ...[
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _expandedMessages[messageId] = false;
                          });
                        },
                        child: Text(
                          'Show less',
                          style: TextStyle(
                            fontSize: 13,
                            color: style.textColor.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              if (message.hasAttachment) ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _openAttachment(message.attachment!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.attach_file,
                            color: Colors.white, size: 16),
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
        // ── "Lindsey Heben - Coach" / "Patrick Kelley - Organization" ────────
        Row(
          children: [
            Flexible(
              child: Text(
                _formatPosterLabel(message.posterName, message.posterType),
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

  // ─── Attachment preview strip ─────────────────────────────────────────────

  Widget _buildAttachmentPreview() {
    return Obx(() {
      if (_controller.selectedFileName.value.isEmpty) {
        return const SizedBox.shrink();
      }
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
    });
  }

  // ─── Message input row ────────────────────────────────────────────────────

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
                      textInputAction: TextInputAction.send,
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
          Obx(() => Container(
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
          )),
        ],
      ),
    );
  }

  // ─── Shimmer placeholder ──────────────────────────────────────────────────

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        final isRight = index % 2 == 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: isRight
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
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
                      bottomLeft: isRight
                          ? const Radius.circular(20)
                          : const Radius.circular(6),
                      bottomRight: isRight
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