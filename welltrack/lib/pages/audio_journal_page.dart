import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:welltrack/components/app_layout.dart';
import 'package:welltrack/components/main_navigation.dart';
import 'package:welltrack/models/journal_entry.dart';
import 'package:welltrack/services/journal_service.dart';
import 'package:welltrack/services/transcription_service.dart';
import 'package:welltrack/providers/user_provider.dart';
import 'package:welltrack/widgets/audio_player_widget.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioJournalPage extends StatefulWidget {
  final int? originIndex;
  final DateTime selectedDate;
  
  const AudioJournalPage({
    super.key,
    this.originIndex,
    required this.selectedDate,
  });

  @override
  State<AudioJournalPage> createState() => _AudioJournalPageState();
}

class _AudioJournalPageState extends State<AudioJournalPage> with SingleTickerProviderStateMixin {
  final _captionController = TextEditingController();
  final _transcriptionController = TextEditingController();
  final _journalService = JournalService();
  final _audioRecorder = AudioRecorder();
  final _transcriptionService = TranscriptionService();
  
  bool _isRecording = false;
  bool _isPaused = false;
  bool _hasRecording = false;
  bool _isSaving = false;
  bool _isTranscribing = false;
  String? _recordingPath;
  String _transcription = '';
  Duration _recordingDuration = Duration.zero;
  Timer? _timer;
  
  // Language settings
  String _selectedLocale = 'en_US'; // Default to English US
  List<Map<String, String>> _availableLocales = [
    {'id': 'en_US', 'name': 'English (US)'},
    {'id': 'en_GB', 'name': 'English (UK)'},
    {'id': 'pt_PT', 'name': 'Português (Portugal)'},
    {'id': 'pt_BR', 'name': 'Português (Brasil)'},
    {'id': 'es_ES', 'name': 'Español (España)'},
    {'id': 'es_MX', 'name': 'Español (México)'},
    {'id': 'fr_FR', 'name': 'Français'},
    {'id': 'de_DE', 'name': 'Deutsch'},
    {'id': 'it_IT', 'name': 'Italiano'},
    {'id': 'ja_JP', 'name': '日本語'},
    {'id': 'ko_KR', 'name': '한국어'},
    {'id': 'zh_CN', 'name': '中文 (简体)'},
  ];
  
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _checkPermission();
    _initializeTranscription();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    _captionController.dispose();
    _transcriptionController.dispose();
    _transcriptionService.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  Future<void> _initializeTranscription() async {
    try {
      final isAvailable = await _transcriptionService.initialize();
      debugPrint('Speech recognition initialized: $isAvailable');
      
      if (isAvailable) {
        // Get available locales from the device
        final locales = await _transcriptionService.getAvailableLocales();
        if (locales.isNotEmpty) {
          debugPrint('Available locales: ${locales.map((l) => '${l.localeId} (${l.name})').join(', ')}');
          
          // Check if device has Portuguese as a priority
          final portugueseLocale = locales.firstWhere(
            (l) => l.localeId.startsWith('pt'),
            orElse: () => locales.first,
          );
          
          if (mounted) {
            setState(() {
              _selectedLocale = portugueseLocale.localeId;
            });
          }
        }
      }
      
      if (!isAvailable && mounted) {
        debugPrint('Speech recognition not available on this device');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Automatic transcription not available. You can type manually.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error initializing transcription: $e');
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        // Get the temporary directory
        final dir = await getTemporaryDirectory();
        final recordingPath = p.join(dir.path, 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a');
        
        // Start recording with the path
        await _audioRecorder.start(const RecordConfig(), path: recordingPath);
        
        setState(() {
          _isRecording = true;
          _hasRecording = false;
          _recordingPath = recordingPath;
          _recordingDuration = Duration.zero;
          _transcription = '';
          _isTranscribing = true;
        });
        
        // Start transcription
        if (_transcriptionService.isAvailable) {
          debugPrint('Speech recognition is available, starting with locale: $_selectedLocale');
          await _transcriptionService.startListening(
            localeId: _selectedLocale,
            onResult: (result) {
              debugPrint('Transcription result: $result');
              setState(() {
                _transcription = result;
                _transcriptionController.text = result;
              });
            },
            onError: (error) {
              debugPrint('Transcription error: $error');
              setState(() {
                _isTranscribing = false;
              });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Speech recognition error: $error'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
          );
        } else {
          debugPrint('Speech recognition not available');
          setState(() {
            _isTranscribing = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Speech recognition not available on this device'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
        
        _animationController.repeat();
        _startTimer();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Microphone permission is required'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting recording: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration = Duration(seconds: timer.tick);
      });
    });
  }

  Future<void> _pauseRecording() async {
    await _audioRecorder.pause();
    setState(() {
      _isPaused = true;
    });
    _timer?.cancel();
    _animationController.stop();
  }

  Future<void> _resumeRecording() async {
    await _audioRecorder.resume();
    setState(() {
      _isPaused = false;
    });
    _animationController.repeat();
    _startTimer();
  }

  Future<void> _stopRecording() async {
    final path = await _audioRecorder.stop();
    await _transcriptionService.stopListening();
    _timer?.cancel();
    _animationController.stop();
    _animationController.reset();
    
    setState(() {
      _isRecording = false;
      _isPaused = false;
      _hasRecording = true;
      _recordingPath = path;
      _isTranscribing = false;
    });
  }

  Future<void> _discardRecording() async {
    setState(() {
      _hasRecording = false;
      _recordingPath = null;
      _recordingDuration = Duration.zero;
      _transcription = '';
      _transcriptionController.clear();
    });
  }

  Future<void> _saveEntry() async {
    if (_recordingPath == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final userProvider = context.read<UserProvider>();
      
      // Save the audio file
      final savedPath = await _journalService.saveAudioFile(_recordingPath!);
      
      final entry = JournalEntry(
        userId: userProvider.userId,
        date: widget.selectedDate,
        type: JournalType.audio,
        audioPath: savedPath,
        caption: _captionController.text.trim().isNotEmpty 
            ? _captionController.text.trim() 
            : null,
        transcription: _transcriptionController.text.trim().isNotEmpty
            ? _transcriptionController.text.trim()
            : null,
      );

      await _journalService.createJournalEntry(entry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audio journal saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving entry: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return NonMainPageWrapper(
      originIndex: widget.originIndex,
      child: AppLayout(
        pageTitle: 'Audio Journal',
        showLogo: false,
        isMainPage: false,
        showBackButton: true,
        content: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.selectedDate.day.toString().padLeft(2, '0')}/${widget.selectedDate.month.toString().padLeft(2, '0')}/${widget.selectedDate.year}',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              const Text(
                'Record your voice',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              Text(
                'Express your thoughts through voice',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              
              // Language selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.language, color: Colors.grey[600], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedLocale,
                          isExpanded: true,
                          icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                          ),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedLocale = newValue;
                              });
                            }
                          },
                          items: _availableLocales.map<DropdownMenuItem<String>>((locale) {
                            return DropdownMenuItem<String>(
                              value: locale['id'],
                              child: Text(locale['name']!),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Recording UI
              Center(
                child: Column(
                  children: [
                    // Visualizer or recording indicator
                    Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange.withOpacity(0.1),
                      ),
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _isRecording && !_isPaused ? _pulseAnimation.value : 1.0,
                              child: Container(
                                height: 120,
                                width: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isRecording 
                                      ? Colors.red.withOpacity(0.8)
                                      : (_hasRecording ? Colors.green : Colors.orange),
                                ),
                                child: Icon(
                                  _isRecording ? Icons.mic : Icons.mic_none,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Duration display
                    Text(
                      _formatDuration(_recordingDuration),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Status text
                    Text(
                      _isRecording 
                          ? (_isPaused ? 'Paused' : 'Recording...')
                          : (_hasRecording ? 'Recording complete' : 'Tap to start recording'),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Control buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!_isRecording && !_hasRecording) ...[
                          // Start button
                          ElevatedButton.icon(
                            onPressed: _startRecording,
                            icon: const Icon(Icons.fiber_manual_record),
                            label: const Text('Start Recording'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ] else if (_isRecording) ...[
                          // Pause/Resume button
                          IconButton(
                            onPressed: _isPaused ? _resumeRecording : _pauseRecording,
                            icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                            iconSize: 48,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 32),
                          // Stop button
                          IconButton(
                            onPressed: _stopRecording,
                            icon: const Icon(Icons.stop),
                            iconSize: 48,
                            color: Colors.red,
                          ),
                        ] else if (_hasRecording) ...[
                          // Re-record button
                          TextButton.icon(
                            onPressed: () {
                              _discardRecording();
                              _startRecording();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Re-record'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.orange,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              if (_hasRecording) ...[
                const SizedBox(height: 40),
                
                // Audio preview player
                if (_recordingPath != null && File(_recordingPath!).existsSync()) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Preview your recording',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        AudioPlayerWidget(
                          audioPath: _recordingPath!,
                          primaryColor: Colors.orange,
                          backgroundColor: Colors.orange.shade200,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Transcription section
                if (_hasRecording) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Transcription',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_isTranscribing)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.blue,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _transcriptionController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: _isTranscribing 
                                ? 'Listening for speech...' 
                                : 'Type what you said in the recording or edit the automatic transcription...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isTranscribing 
                              ? 'Speech recognition is active...'
                              : _transcription.isEmpty 
                                  ? 'No speech detected. You can type your transcription manually.'
                                  : 'You can edit the transcription above',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Caption input
                Text(
                  'Add a note (optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                
                TextField(
                  controller: _captionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Add a note about this recording...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.orange, width: 2),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: !_isSaving ? _saveEntry : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save Audio Journal',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}