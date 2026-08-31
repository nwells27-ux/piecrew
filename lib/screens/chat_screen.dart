import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/user_model.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';
import '../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  final PieCrewUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _service = ChatService();
  final _textCtrl = TextEditingController();
  String? _channelId;

  @override
  void initState() {
    super.initState();
    _service.ensureLocationChannel(widget.user.locationId, widget.user.locationId).then((id) {
      if (mounted) setState(() => _channelId = id);
    });
  }

  Future<void> _send() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty || _channelId == null) return;
    _textCtrl.clear();
    await _service.sendMessage(
      channelId: _channelId!,
      senderId: widget.user.uid,
      senderName: widget.user.displayName,
      senderPhotoUrl: widget.user.photoUrl,
      text: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_channelId == null) {
      return const Center(child: CircularProgressIndicator(color: PieCrewColors.pie));
    }
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<ChatMessage>>(
            stream: _service.streamMessages(_channelId!),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator(color: PieCrewColors.pie));
              }
              final messages = snapshot.data!;
              if (messages.isEmpty) {
                return Center(
                  child: Text('No messages yet. Say hi 👋',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: PieCrewColors.inkMuted)),
                );
              }
              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(14),
                itemCount: messages.length,
                itemBuilder: (context, i) {
                  final m = messages[i];
                  final isMe = m.senderId == widget.user.uid;
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      decoration: BoxDecoration(
                        color: isMe ? PieCrewColors.pie : PieCrewColors.card,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isMe ? 16 : 4),
                          bottomRight: Radius.circular(isMe ? 4 : 16),
                        ),
                        border: isMe ? null : Border.all(color: PieCrewColors.line),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMe)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(m.senderName,
                                  style: const TextStyle(
                                      fontSize: 11, fontWeight: FontWeight.w800, color: PieCrewColors.pie)),
                            ),
                          Text(m.text,
                              style: TextStyle(color: isMe ? Colors.white : PieCrewColors.ink, fontSize: 14.5)),
                          const SizedBox(height: 2),
                          Text(timeago.format(m.createdAt),
                              style: TextStyle(
                                  fontSize: 10,
                                  color: isMe ? Colors.white.withValues(alpha: 0.75) : PieCrewColors.inkFaint)),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        SafeArea(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: PieCrewColors.crustDark,
              border: Border(top: BorderSide(color: PieCrewColors.line)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Message the team…',
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                          borderSide: BorderSide(color: PieCrewColors.line, width: 1.4)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                          borderSide: BorderSide(color: PieCrewColors.pie, width: 1.8)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: PieCrewColors.pie,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: _send,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
