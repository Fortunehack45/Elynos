import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../view_models/home_view_model.dart';
import '../widgets/home_empty_state.dart';
import '../widgets/private_chat_overlay.dart';
import '../widgets/mode_selector_sheet.dart';
import '../../drawer/views/elynos_drawer.dart';
import '../../chat/widgets/chat_bubble.dart';
import '../../imagine/views/imagine_view.dart';
import '../../build_mode/views/build_mode_view.dart';
import '../../../core/widgets/elynos_app_bar.dart';
import '../../../core/widgets/elynos_bottom_bar.dart';
import '../../../core/theme/elynos_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: const _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends StatefulWidget {
  const _HomeScreenContent();

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final show = (maxScroll - currentScroll) > 120;
    if (show != _showScrollToBottom) {
      setState(() {
        _showScrollToBottom = show;
      });
    }
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      if (animated) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutQuad,
        );
      } else {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: ElyonsAppBar(
        activeTab: viewModel.activeTopTab,
        onTabChanged: viewModel.setTopTab,
        onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
        onNewChat: viewModel.startNewConversation,
        isPrivateMode: viewModel.isPrivateMode,
        onTogglePrivate: viewModel.togglePrivateMode,
      ),
      drawer: ElyonsDrawer(
        conversations: viewModel.conversations,
        activeConversationId: viewModel.activeConversationId,
        onSelectConversation: viewModel.selectConversation,
        onNewChat: viewModel.startNewConversation,
        onDeleteConversation: viewModel.deleteConversation,
      ),
      // Grok Docked Layout: ElyonsBottomBar is inside Column with resizeToAvoidBottomInset
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  _buildBody(context, viewModel),

                  // Grok Scroll-to-Bottom Circular Button
                  if (_showScrollToBottom && viewModel.activeTopTab == 0)
                    Positioned(
                      right: 16,
                      bottom: 12,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _scrollToBottom();
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 22),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Bottom Input Bar (docks directly above soft keyboard across all tabs)
            ElyonsBottomBar(
              hintText: viewModel.activeTopTab == 1
                  ? 'Describe an image to synthesize...'
                  : viewModel.activeTopTab == 2
                      ? 'Describe an app or component to build...'
                      : 'Ask anything',
              currentMode: viewModel.currentMode,
              onOpenModeSheet: () => _openModeSheet(context, viewModel),
              onSend: (text, {attachedFiles = const []}) {
                viewModel.sendMessage(text, attachedFiles: attachedFiles);
                _scrollToBottom();
              },
              isPrivateMode: viewModel.isPrivateMode,
              isLoading: viewModel.isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, HomeViewModel viewModel) {
    switch (viewModel.activeTopTab) {
      case 1:
        return const ImagineView();
      case 2:
        return const BuildModeView();
      case 0:
      default:
        return _buildChatBody(context, viewModel);
    }
  }

  Widget _buildChatBody(BuildContext context, HomeViewModel viewModel) {
    if (viewModel.messages.isEmpty) {
      if (viewModel.isPrivateMode) {
        return const PrivateChatEmptyState();
      }
      return HomeEmptyState(
        onSelectPrompt: (prompt) {
          viewModel.sendMessage(prompt);
          _scrollToBottom();
        },
      );
    }

    final totalCount = viewModel.messages.length + (viewModel.isLoading ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: totalCount,
      itemBuilder: (context, index) {
        if (index == viewModel.messages.length && viewModel.isLoading) {
          // Grok Active Thinking Indicator
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lightbulb_outline_rounded, size: 16, color: Color(0xFF757575)),
                const SizedBox(width: 6),
                const Text(
                  'Thinking...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF757575),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 8),
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF757575)),
                  ),
                ),
              ],
            ),
          );
        }

        final message = viewModel.messages[index];
        return ChatBubble(
          message: message,
          onRegenerate: () {
            // Find last user message and regenerate
            final lastUserMsg = viewModel.messages.lastWhere(
              (m) => m.isUser,
              orElse: () => message,
            );
            viewModel.sendMessage(lastUserMsg.text, attachedFiles: lastUserMsg.attachedFiles ?? []);
            _scrollToBottom();
          },
        );
      },
    );
  }

  void _openModeSheet(BuildContext context, HomeViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ModeSelectorSheet(
        currentMode: viewModel.currentMode,
        onModeSelected: viewModel.setMode,
      ),
    );
  }
}
