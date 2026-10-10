import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../domain/models/conversation.dart';
import '../../../core/theme/elynos_theme.dart';
import '../../training/views/training_screen.dart';
import '../../connectors/views/connectors_screen.dart';

class ElyonsDrawer extends StatefulWidget {
  final List<Conversation> conversations;
  final String? activeConversationId;
  final ValueChanged<String> onSelectConversation;
  final VoidCallback onNewChat;
  final Function(String) onDeleteConversation;

  const ElyonsDrawer({
    super.key,
    required this.conversations,
    this.activeConversationId,
    required this.onSelectConversation,
    required this.onNewChat,
    required this.onDeleteConversation,
  });

  @override
  State<ElyonsDrawer> createState() => _ElyonsDrawerState();
}

class _ElyonsDrawerState extends State<ElyonsDrawer> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredConversations = widget.conversations.where((c) {
      if (_searchQuery.isEmpty) return true;
      return c.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Top Header: User Profile
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.black,
                    child: Icon(Icons.bolt, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'ELYNOS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.keyboard_double_arrow_left_rounded, color: Colors.black, size: 24),
                  ),
                ],
              ),
            ),

            // Top Menu Items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.history_toggle_off_rounded,
                    title: 'Automations',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Automations: Background triggers active.')),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.bookmarks_outlined,
                    title: 'Library',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Library: Offline snippets & artifacts.')),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.folder_open_rounded,
                    title: 'Projects',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Projects: Built apps & websites.')),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.psychology_outlined,
                    title: 'Elynos Trainer (On-Device)',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TrainingScreen()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.hub_outlined,
                    title: 'Connectors',
                    badge: 'Soon',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ConnectorsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Sovereign Banner Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Elynos 1 Axiom • 100k Context',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '100% Offline • Low RAM (<150MB)',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Conversations Section Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Row(
                children: const [
                  Text(
                    'Conversations',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.keyboard_arrow_up_rounded, color: Color(0xFF9CA3AF), size: 20),
                ],
              ),
            ),

            // Conversations List
            Expanded(
              child: filteredConversations.isEmpty
                  ? const Center(
                      child: Text(
                        'No conversations yet',
                        style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredConversations.length,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemBuilder: (context, index) {
                        final conv = filteredConversations[index];
                        final isSelected = conv.id == widget.activeConversationId;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFF2F2F4) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            dense: true,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              widget.onSelectConversation(conv.id);
                              Navigator.pop(context);
                            },
                            title: Text(
                              conv.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: isSelected ? Colors.black : const Color(0xFF374151),
                              ),
                            ),
                            subtitle: Text(
                              '${conv.updatedAt.day} ${_getMonth(conv.updatedAt.month)}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w600),
                            ),
                            trailing: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 16, color: Color(0xFF9CA3AF)),
                              color: Colors.white,
                              onSelected: (val) {
                                if (val == 'delete') {
                                  widget.onDeleteConversation(conv.id);
                                }
                              },
                              itemBuilder: (ctx) => [
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete Chat', style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const Divider(color: Color(0xFFE5E7EB), height: 1),

            // Bottom Actions: Search Bar, Settings, New Chat
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Row(
                children: [
                  // Search Bar
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, size: 18, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              onChanged: (val) => setState(() => _searchQuery = val),
                              style: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.w600),
                              decoration: const InputDecoration(
                                hintText: 'Search',
                                hintStyle: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w600),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Settings / Connectors Gear Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F4),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.settings_outlined, color: Colors.black87, size: 20),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ConnectorsScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 6),

                  // New Chat Pencil Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F4),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit_note_rounded, color: Colors.black, size: 22),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        widget.onNewChat();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? badge,
  }) {
    return ListTile(
      dense: true,
      onTap: onTap,
      leading: Icon(icon, color: Colors.black, size: 22),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: Colors.black),
      ),
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF6B7280),
                ),
              ),
            )
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
