import 'dart:io';
import 'package:flutter/material.dart';
import 'package:welltrack/components/app_layout.dart';
import 'package:welltrack/components/main_navigation.dart';
import 'package:welltrack/models/journal_entry.dart';
import 'package:welltrack/services/journal_service.dart';
import 'package:welltrack/widgets/audio_player_widget.dart';
import 'package:intl/intl.dart';

class SeeMyThoughtsPage extends StatefulWidget {
  final int? originIndex;
  final DateTime? selectedDate;
  
  const SeeMyThoughtsPage({
    super.key,
    this.originIndex,
    this.selectedDate,
  });

  @override
  State<SeeMyThoughtsPage> createState() => _SeeMyThoughtsPageState();
}

class _SeeMyThoughtsPageState extends State<SeeMyThoughtsPage> {
  final _journalService = JournalService();
  List<JournalEntry> _entries = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadEntries();
  }
  
  Future<void> _loadEntries() async {
    try {
      final entries = widget.selectedDate != null
          ? await _journalService.getJournalEntriesForDate(widget.selectedDate!)
          : await _journalService.getAllJournalEntries();
      
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading entries: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NonMainPageWrapper(
      originIndex: widget.originIndex,
      child: AppLayout(
        pageTitle: 'My Journal',
        showLogo: false,
        isMainPage: false,
        showBackButton: true,
        content: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _entries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.book_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No journal entries yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start by creating your first entry',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(24.0),
                    itemCount: _entries.length,
                    itemBuilder: (context, index) {
                      final entry = _entries[index];
                      return Column(
                        children: [
                          if (index == 0 || !_isSameDay(entry.date, _entries[index - 1].date))
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      DateFormat('dd/MM/yyyy').format(entry.date),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          _buildEntryWidget(entry, index),
                        ],
                      );
                    },
                  ),
      ),
    );
  }
  
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
  
  Widget _buildEntryWidget(JournalEntry entry, int index) {
    final isEven = index % 2 == 0;
    
    Widget content;
    Color? backgroundColor;
    
    switch (entry.type) {
      case JournalType.text:
        backgroundColor = isEven ? Colors.deepPurple.shade50 : Colors.deepPurple.shade100;
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.textContent ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(entry.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        );
        break;
        
      case JournalType.photo:
        backgroundColor = isEven ? Colors.green.shade50 : Colors.green.shade100;
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry.photoPath != null && File(entry.photoPath!).existsSync())
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(entry.photoPath!),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 48),
                      ),
                    );
                  },
                ),
              ),
            if (entry.caption != null && entry.caption!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                entry.caption!,
                style: const TextStyle(fontSize: 14),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(entry.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        );
        break;
        
      case JournalType.audio:
        backgroundColor = isEven ? Colors.orange.shade50 : Colors.orange.shade100;
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry.audioPath != null && File(entry.audioPath!).existsSync())
              AudioPlayerWidget(
                audioPath: entry.audioPath!,
                primaryColor: Colors.orange,
                backgroundColor: Colors.orange.shade200,
              )
            else
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.orange.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.orange,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Audio file not found',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            if (entry.transcription != null && entry.transcription!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.subtitles,
                          size: 16,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Transcription',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.transcription!,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (entry.caption != null && entry.caption!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                entry.caption!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(entry.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        );
        break;
    }
    
    return Align(
      alignment: isEven ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: _ChatBubble(
          color: backgroundColor,
          child: content,
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final Widget child;
  final Color? color;
  
  const _ChatBubble({required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color ?? Colors.grey.shade200,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
} 