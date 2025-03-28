import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const EngkyApp());
}

class EngkyApp extends StatelessWidget {
  const EngkyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Engky',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        brightness: Brightness.light,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int score = 0;
  List<VocabWord> vocabularyList = [];
  VocabWord? currentWord;
  bool isLoading = true;
  final Random _random = Random();
  final PageController _pageController = PageController();
  
  // For animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadResources();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadResources() async {
    await _loadVocabulary();
    await _loadScore();
    _getRandomWord();
    setState(() {
      isLoading = false;
    });
    _animationController.forward();
  }

  Future<void> _loadVocabulary() async {
    try {
      final String response = await rootBundle.loadString('assets/vocabulary.json');
      final data = await json.decode(response);
      setState(() {
        vocabularyList = List<VocabWord>.from(
          data['words'].map((word) => VocabWord.fromJson(word)),
        );
      });
    } catch (e) {
      print('Error loading vocabulary: $e');
      // If no vocabulary file exists, use a default set
      setState(() {
        vocabularyList = [
          VocabWord(word: 'apple', meaning: 'แอปเปิ้ล'),
          VocabWord(word: 'book', meaning: 'หนังสือ'),
          VocabWord(word: 'cat', meaning: 'แมว'),
          VocabWord(word: 'dog', meaning: 'สุนัข'),
          VocabWord(word: 'elephant', meaning: 'ช้าง'),
        ];
      });
    }
  }
  
  void _getRandomWord() {
    if (vocabularyList.isEmpty) return;
    
    setState(() {
      _animationController.reset();
      currentWord = vocabularyList[_random.nextInt(vocabularyList.length)];
      _animationController.forward();
    });
  }

  Future<void> _loadScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      score = prefs.getInt('total_score') ?? 0;
    });
  }

  Future<void> _saveScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('total_score', score);
  }

  void _incrementScore(int points) {
    setState(() {
      score += points;
    });
    _saveScore();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || currentWord == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.language,
                size: 120,
                color: Colors.purple,
              ),
              const SizedBox(height: 24),
              const Text(
                'engky',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: vocabularyList.length,
        onPageChanged: (index) {
          _getRandomWord();
        },
        itemBuilder: (context, index) {
          return VocabPracticePage(
            vocab: currentWord!,
            onScoreUpdated: _incrementScore,
            onSkip: () {
              _getRandomWord();
            },
            score: score,
          );
        },
      ),
    );
  }
}

class VocabPracticePage extends StatefulWidget {
  final VocabWord vocab;
  final Function(int) onScoreUpdated;
  final VoidCallback onSkip;
  final int score;

  const VocabPracticePage({
    Key? key,
    required this.vocab,
    required this.onScoreUpdated,
    required this.onSkip,
    required this.score,
  }) : super(key: key);

  @override
  _VocabPracticePageState createState() => _VocabPracticePageState();
}

class _VocabPracticePageState extends State<VocabPracticePage> with SingleTickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  
  bool isListening = false;
  String recognizedText = '';
  bool hasChecked = false;
  bool isCorrect = false;
  double _timerValue = 0.0;
  Timer? _countdownTimer;
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _setupTts();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    flutterTts.stop();
    _animationController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    await _speech.initialize(
      onStatus: (status) {
        print('Speech status: $status');
      },
      onError: (error) => print('Error: $error'),
    );
  }

  Future<void> _setupTts() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _speakWord() async {
    _animateButton();
    await flutterTts.speak(widget.vocab.word);
  }

  Future<void> _listen() async {
    // Reset states
    setState(() {
      recognizedText = '';
      isListening = true;
      hasChecked = false;
      isCorrect = false;
      _timerValue = 0.0;
    });

    try {
      // Start listening
      _speech.listen(
        onResult: (result) {
          setState(() {
            recognizedText = result.recognizedWords.toLowerCase();
          });
        },
        listenFor: const Duration(seconds: 5),
        localeId: 'en_US',
      );
      
      // Start 5 second countdown timer with updates every 100ms
      _countdownTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        setState(() {
          _timerValue += 0.02; // 0.02 * 50 = 1.0 (full progress in 5 seconds)
        });
        
        if (_timerValue >= 1.0) {
          _countdownTimer?.cancel();
          _forceCheckAnswer();
        }
      });
    } catch (e) {
      print('Error starting speech recognition: $e');
      setState(() {
        isListening = false;
      });
    }
  }

  // Force check answer after timer expires
  void _forceCheckAnswer() {
    if (!hasChecked) {
      // Force stop listening
      _speech.stop();
      
      // Check answer regardless of whether we heard anything
      final userAnswer = recognizedText.trim().toLowerCase();
      final correctAnswer = widget.vocab.word.toLowerCase();
      
      setState(() {
        isCorrect = userAnswer == correctAnswer;
        hasChecked = true;
        isListening = false;
        
        if (isCorrect) {
          widget.onScoreUpdated(1); // Add 1 point for correct answer
        }
      });
    }
  }
  
  void _resetAndSkip() {
    _countdownTimer?.cancel();
    _speech.stop();
    setState(() {
      recognizedText = '';
      hasChecked = false;
      isListening = false;
      isCorrect = false;
      _timerValue = 0.0;
    });
    widget.onSkip();
  }
  
  void _animateButton() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Gradient header with word display
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF7F00FF),  // Dark purple
                  Color(0xFF6200EA),  // Medium purple
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.score}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Word display
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.vocab.word,
                            style: const TextStyle(
                              fontSize: 80,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 40),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              widget.vocab.meaning,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Interaction area
        Container(
          color: Colors.white,
          padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
          child: Column(
            children: [
              // Listen to the pronunciation text
              if (!isListening && !hasChecked)
                const Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    'Listen to the pronunciation and practice speaking',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Listen button
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _speakWord,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00BCD4),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.volume_up,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Listen',
                        style: TextStyle(
                          color: Color(0xFF00BCD4),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  // Speak button
                  Column(
                    children: [
                      GestureDetector(
                        onTap: isListening ? null : _listen,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: isListening ? Colors.grey : Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.mic,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Speak',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  // Skip button
                  Column(
                    children: [
                      GestureDetector(
                        onTap: _resetAndSkip,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                            color: Color(0xFF7F00FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.skip_next,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Skip',
                        style: TextStyle(
                          color: Color(0xFF7F00FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Result area
              if (hasChecked)
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isCorrect ? Colors.green.shade100 : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.cancel,
                          color: isCorrect ? Colors.green : Colors.red,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isCorrect ? 'Correct! 🎉' : 'Try Again 💪',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isCorrect ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                        ),
                        if (!isCorrect && recognizedText.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'You said: $recognizedText',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              
              // Progress bar for 5-second countdown
              if (isListening)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        child: LinearProgressIndicator(
                          value: _timerValue,
                          backgroundColor: Colors.grey.shade200,
                          color: Colors.orange,
                          minHeight: 8,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        recognizedText.isEmpty ? 'Speak now... (5s)' : 'I heard: $recognizedText',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class VocabWord {
  final String word;
  final String meaning;

  VocabWord({
    required this.word,
    required this.meaning,
  });

  factory VocabWord.fromJson(Map<String, dynamic> json) {
    return VocabWord(
      word: json['word'],
      meaning: json['meaning'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'meaning': meaning,
    };
  }
}