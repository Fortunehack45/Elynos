import 'package:flutter/material.dart';
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

class _HomeScreenContent extends StatelessWidget {
  const _HomeScreenContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: ElyonsColors.background,
      appBar: ElyonsAppBar(
        activeTab: viewModel.activeTopTab,
        onTabChanged: viewModel.setTopTab,
        onOpenDrawer: () => scaffoldKey.currentState?.openDrawer(),
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
      body: _buildBody(context, viewModel),
      bottomNavigationBar: viewModel.activeTopTab == 0
          ? ElyonsBottomBar(
              currentMode: viewModel.currentMode,
              onOpenModeSheet: () => _openModeSheet(context, viewModel),
              onSend: (text, {attachedFiles = const []}) =>
                  viewModel.sendMessage(text, attachedFiles: attachedFiles),
              isPrivateMode: viewModel.isPrivateMode,
              isLoading: viewModel.isLoading,
            )
          : null,
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
        onSelectPrompt: (prompt) => viewModel.sendMessage(prompt),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: viewModel.messages.length,
      itemBuilder: (context, index) {
        final message = viewModel.messages[index];
        return ChatBubble(message: message);
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
