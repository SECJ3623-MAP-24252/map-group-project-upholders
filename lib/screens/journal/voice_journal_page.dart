import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:map_upholders/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/voice_journal_viewmodel.dart';

class VoiceJournalPage extends StatelessWidget {
  const VoiceJournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VoiceJournalViewModel(),
      child: const _VoiceJournalView(),
    );
  }
}

class _VoiceJournalView extends StatelessWidget {
  const _VoiceJournalView();


  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceJournalViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Voice Journal', style: TextStyle(color: Colors.brown)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.brown),
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.brown),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
          drawer: AppDrawer(currentRoute: "/voice-journal"),
          backgroundColor: const Color(0xFFFCF8F4),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          vm.isRecording
                              ? "Recording... Tap to stop"
                              : "Tap mic to record a voice journal for today!",
                          style: TextStyle(
                            color: Colors.brown[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () async {
                            if (vm.isRecording) {
                              await vm.stopRecording();
                            } else {
                              await vm.startRecording();
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: vm.isRecording ? 82 : 68,
                            height: vm.isRecording ? 82 : 68,
                            decoration: BoxDecoration(
                              color: vm.isRecording ? Colors.red[300] : const Color(0xFFA7B77A),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.brown.withOpacity(0.10),
                                  blurRadius: 20,
                                  offset: const Offset(0, 7),
                                ),
                              ],
                            ),
                            child: Icon(
                              vm.isRecording ? Icons.stop : Icons.mic,
                              color: Colors.white,
                              size: 38,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.only(left: 18.0, bottom: 6, top: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Journal History",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              Expanded(
                child: vm.history.isEmpty
                    ? const Center(
                  child: Text("No voice journals yet. Start recording!", style: TextStyle(color: Colors.grey)),
                )
                    : ListView.builder(
                  itemCount: vm.history.length,
                  itemBuilder: (context, idx) {
                    final entry = vm.history[idx];
                    final isPlayingThis = vm.isPlaying && vm.playingPath == entry.filePath;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      color: Colors.white,
                      child: ListTile(
                        leading: Icon(Icons.mic, color: Color(0xFFA7B77A), size: 36),
                        title: Text(
                          DateFormat('EEE, MMM d, yyyy – HH:mm').format(entry.date),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0, bottom: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Detected emotion: ${entry.emotion}",
                                style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.green),
                              ),
                              if (entry.transcript != null && entry.transcript!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    "Transcript: ${entry.transcript}",
                                    style: TextStyle(fontSize: 12, color: Colors.brown[400]),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isPlayingThis ? Icons.stop : Icons.play_arrow,
                            color: Colors.brown,
                          ),
                          onPressed: () async {
                            if (!isPlayingThis) {
                              await vm.play(entry.filePath);
                            } else {
                              await vm.stopPlayback();
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }
}
