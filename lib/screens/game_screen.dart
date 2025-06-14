import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:map/models/quiz_card.dart';

// Enum and helper functions remain unchanged
enum GameState { loading, answering, showingResult, error }

String capitalizeFirst(String? text) {
  if (text == null || text.isEmpty) return text ?? '';
  for (int i = 0; i < text.length; i++) {
    if (RegExp(r'[a-zA-Z]').hasMatch(text[i])) {
      return text.substring(0, i) + text[i].toUpperCase() + text.substring(i + 1);
    }
  }
  return text;
}

String capitalizeSentences(String? text) {
  if (text == null || text.trim().isEmpty) return text ?? '';
  String processedText = text.trim();
  processedText = capitalizeFirst(processedText);
  processedText = processedText.replaceAllMapped(
    RegExp(r'(?<=[.!?]\s+)\w'),
        (match) => match.group(0)!.toUpperCase(),
  );
  processedText = processedText.replaceAllMapped(
    RegExp(r'(?<=[.!?])\w'),
        (match) => match.group(0)!.toUpperCase(),
  );
  return processedText;
}

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // State variables remain unchanged
  GameState _gameState = GameState.loading;
  List<QuizCard> _allCards = [];
  QuizCard? _currentCard;
  List<ChoiceCard> _currentChoices = [];
  String _errorMessage = '';
  bool _lastAnswerCorrect = false;
  final math.Random _random = math.Random();
  bool _isHintVisible = false;

  // Animation Controllers remain unchanged
  late AnimationController _feedbackAnimationController;
  Animation<Color?>? _feedbackColorAnimation;
  late AnimationController _cardIntroAnimationController;
  late AnimationController _explanationAnimationController;

  // Progress tracking
  int _questionCount = 0;
  int _correctCount = 0;

  // Duolingo colors
  final Color _primaryColor = const Color(0xFF58CC02);
  final Color _secondaryColor = const Color(0xFF1CB0F6);
  final Color _accentColor = const Color(0xFFFFC800);
  final Color _incorrectColor = const Color(0xFFFF4B4B);
  final Color _backgroundLightColor = const Color(0xFFFAFAFA);
  final Color _backgroundDarkColor = const Color(0xFF2B70C9);
  final Color _textColor = const Color(0xFF4B4B4B);

  @override
  void initState() {
    super.initState();
    _feedbackAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _feedbackColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.transparent,
    ).animate(_feedbackAnimationController)..addListener(() {
      if(mounted) setState(() {});
    });
    _cardIntroAnimationController = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this
    );
    _explanationAnimationController = AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this
    );
    _fetchCards();
  }

  @override
  void dispose() {
    _feedbackAnimationController.dispose();
    _cardIntroAnimationController.dispose();
    _explanationAnimationController.dispose();
    super.dispose();
  }

  // All methods remain unchanged
  Future<void> _fetchCards() async {
    if (!mounted) return;
    setState(() { _gameState = GameState.loading; _errorMessage = ''; });

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('cards')
          .get();

      if (snapshot.docs.isEmpty) {
        if (!mounted) return;
        setState(() { _errorMessage = "No quiz cards found!"; _gameState = GameState.error; });
        return;
      }

      final List<QuizCard> fetchedCards = [];
      for (var doc in snapshot.docs) {
        try {
          fetchedCards.add(QuizCard.fromFirestore(doc));
        } catch (e) {
          print("Error parsing card ${doc.id}: $e");
        }
      }
      _allCards = fetchedCards;

      if (_allCards.isEmpty) {
        setState(() {
          _errorMessage = snapshot.docs.isNotEmpty ? "Error parsing card data." : "No valid quiz cards found!";
          _gameState = GameState.error;
        });
        return;
      }

      _loadRandomQuestion();

    } catch (e) {
      if (!mounted) return;
      print("Error fetching cards: $e");
      setState(() {
        if (e is FirebaseException && e.code == 'permission-denied') {
          _errorMessage = "Permission denied. Check Firestore rules.";
        } else if (e is FirebaseException && e.code == 'unavailable'){
          _errorMessage = "Network error. Could not reach Firestore.";
        }
        else {
          _errorMessage = "Failed to load questions. Please try again.";
        }
        _gameState = GameState.error;
      });
    }
  }

  void _loadRandomQuestion() {
    if (_allCards.isEmpty || !mounted) {
      setState(() { _gameState = GameState.error; _errorMessage = _allCards.isEmpty ? "No cards available." : "Component unmounted."; });
      return;
    }
    _cardIntroAnimationController.reset();
    _explanationAnimationController.reset();
    setState(() {
      _currentCard = _allCards[_random.nextInt(_allCards.length)];
      _isHintVisible = false;
      _gameState = GameState.answering;
    });
    _prepareChoices();
    Future.delayed(const Duration(milliseconds: 50), () { if (mounted) _cardIntroAnimationController.forward(); });
  }

  void _prepareChoices() {
    if (_currentCard == null || !mounted) return;
    List<ChoiceCard> choices = [];
    choices.add(ChoiceCard(text: _currentCard!.answer, isCorrect: true));
    choices.addAll(_currentCard!.distractors.map((text) => ChoiceCard(text: text, isCorrect: false)));
    choices.shuffle(_random);
    _currentChoices = choices.take(4).toList();
    if (_currentCard!.cardType == 'multipleChoice' && (_currentChoices.where((c) => c.isCorrect).length + _currentChoices.where((c) => !c.isCorrect).length) < 2) {
      print("Warning: Multiple choice card ${_currentCard!.id} has less than 2 total choices (answer + distractors).");
    }
  }

  void _checkAnswer(bool isCorrect) {
    if (!mounted || _gameState != GameState.answering) return;
    _lastAnswerCorrect = isCorrect;

    // Update progress
    _questionCount++;
    if (isCorrect) {
      _correctCount++;
    }

    final animation = ColorTween(
      begin: Colors.transparent,
      end: isCorrect ? _primaryColor.withOpacity(0.15) : _incorrectColor.withOpacity(0.1),
    ).animate(CurvedAnimation(
      parent: _feedbackAnimationController,
      curve: Curves.easeOut,
    ));
    _feedbackColorAnimation = animation;
    _feedbackAnimationController.forward().then((_) {
      if(!mounted) return;
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        _feedbackAnimationController.reverse();
      });
    });
    setState(() {
      _gameState = GameState.showingResult;
      _isHintVisible = false;
    });
    _explanationAnimationController.forward();
  }

  void _showHint() {
    if (_isHintVisible) {
      setState(() { _isHintVisible = false; });
      return;
    }

    final currentHint = _currentCard?.hint;
    if (currentHint != null && currentHint.isNotEmpty && mounted) {
      setState(() {
        _isHintVisible = true;
      });

      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && _isHintVisible) {
          setState(() {
            _isHintVisible = false;
          });
        }
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "No hint available for this question.",
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: _secondaryColor,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  // REDESIGNED UI FOR MAIN BUILD METHOD - Duolingo style
  @override
  Widget build(BuildContext context) {
    Widget bodyContent;
    switch (_gameState) {
      case GameState.loading:
        bodyContent = Center(
          child: Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 0,
                )
              ],
            ),
            child: CircularProgressIndicator(
              color: _primaryColor,
              strokeWidth: 5,
            ),
          ),
        );
        break;
      case GameState.error:
        bodyContent = Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 0,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: _incorrectColor,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _fetchCards,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    "TRY AGAIN",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        break;
      default:
        bodyContent = _buildGameContentUI();
        break;
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: _backgroundLightColor,
        ),
        child: AnimatedBuilder(
            animation: _feedbackAnimationController,
            builder: (context, _) {
              return Container(
                color: _feedbackColorAnimation?.value ?? Colors.transparent,
                child: SafeArea(child: bodyContent),
              );
            }
        ),
      ),
    );
  }

  // REDESIGNED GAME CONTENT UI WITH DUOLINGO STYLE
  Widget _buildGameContentUI() {
    if (_currentCard == null) {
      return Center(
        child: Text(
          "Error: No current question.",
          style: TextStyle(
            color: _textColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive Size Calculation
        const double horizontalPadding = 16.0 * 2;
        const double verticalPadding = 16.0 * 2;
        final double availableWidth = constraints.maxWidth - horizontalPadding;
        final double availableHeight = constraints.maxHeight - verticalPadding;
        final double questionPanelMaxHeight = availableHeight * 0.30;
        final double gridAvailableHeight = availableHeight - questionPanelMaxHeight - 20;
        final double gridAvailableWidth = availableWidth;
        final double spacing = (gridAvailableWidth * 0.06).clamp(8.0, 16.0);
        final double cardMaxWidth = (gridAvailableWidth - spacing) / 2;
        final double cardMaxHeight = (gridAvailableHeight - spacing).clamp(90.0, double.infinity) / 2;
        double cardSize = math.min(cardMaxWidth, cardMaxHeight);
        cardSize = cardSize.clamp(90.0, 200.0);

        // STACK LAYOUT
        return Stack(
          children: [
            // Progress bar at the top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildProgressBar(),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 48.0, 16.0, 16.0),
              child: Column(
                children: [
                  // --- Top: Question Panel ---
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: questionPanelMaxHeight,
                      minHeight: 70,
                    ),
                    child: _buildQuestionPanel(
                      _currentCard!.prompt,
                      onHintPressed: (_gameState == GameState.answering) ? _showHint : null,
                      key: ValueKey<String>('question_${_currentCard!.id}'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Middle: Answer Grid ---
                  Expanded(
                    child: Center(
                      child: IgnorePointer(
                        ignoring: _gameState == GameState.showingResult,
                        child: Opacity(
                          opacity: _gameState == GameState.showingResult ? 0.7 : 1.0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _currentChoices.isNotEmpty
                                      ? _buildCard(0, _currentChoices, cardSize, 0)
                                      : SizedBox(width: cardSize),
                                  SizedBox(width: spacing),
                                  _currentChoices.length > 1
                                      ? _buildCard(1, _currentChoices, cardSize, 1)
                                      : SizedBox(width: cardSize),
                                ],
                              ),
                              SizedBox(height: spacing),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _currentChoices.length > 2
                                      ? _buildCard(2, _currentChoices, cardSize, 2)
                                      : SizedBox(width: cardSize),
                                  SizedBox(width: spacing),
                                  _currentChoices.length > 3
                                      ? _buildCard(3, _currentChoices, cardSize, 3)
                                      : SizedBox(width: cardSize),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- Overlay Layer (Explanation Panel) ---
            if (_gameState == GameState.showingResult)
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildExplanationPanel(explanation: _currentCard?.explanation),
              ),

            // --- Overlay Layer (Hint Panel) ---
            IgnorePointer(
              ignoring: !_isHintVisible,
              child: AnimatedOpacity(
                opacity: _isHintVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: _buildHintPanel(hint: _currentCard?.hint),
              ),
            ),
          ],
        );
      },
    );
  }

  // PROGRESS BAR - DUOLINGO STYLE
  Widget _buildProgressBar() {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Health icons
          Row(
            children: List.generate(3, (index) {
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.favorite,
                  color: _incorrectColor,
                  size: 20,
                ),
              );
            }),
          ),

          // Progress bar
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _questionCount > 0 ? _correctCount / _questionCount : 0,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                  minHeight: 10,
                ),
              ),
            ),
          ),

          // XP display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _accentColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${_correctCount * 10} XP",
                  style: TextStyle(
                    color: _textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // REDESIGNED QUESTION PANEL - DUOLINGO STYLE
  Widget _buildQuestionPanel(String question, {Key? key, VoidCallback? onHintPressed}) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.school_rounded,
                color: _primaryColor,
                size: 20,
              ),
              Text(
                "TRANSLATE THIS SENTENCE",
                style: TextStyle(
                  color: _secondaryColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              GestureDetector(
                onTap: onHintPressed != null && !_isHintVisible ? _showHint : null,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: onHintPressed != null
                        ? _accentColor
                        : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lightbulb_outline,
                    color: onHintPressed != null
                        ? _textColor
                        : Colors.grey,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(
            child: AutoSizeText(
              capitalizeSentences(question),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _textColor,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
              minFontSize: 14,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // REDESIGNED CARD ITEM FOR DUOLINGO STYLE
  Widget _buildCard(int index, List<ChoiceCard> cards, double size, int animationIndex) {
    if (index < 0 || index >= cards.length) {
      return SizedBox(width: size, height: size);
    }

    final intervalStart = (animationIndex * 0.12).clamp(0.0, 1.0);
    final intervalEnd = (intervalStart + 0.4).clamp(0.0, 1.0);
    final animation = CurvedAnimation(
        parent: _cardIntroAnimationController,
        curve: Interval(
            intervalStart,
            intervalEnd,
            curve: Curves.easeOutQuad
        )
    );

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(animation);

    final cardData = cards[index];

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: slideAnimation,
        child: ScaleTransition(
          scale: animation,
          child: CardItem(
            key: ValueKey("${_currentCard?.id ?? 'no_id'}_choice_${cardData.text.hashCode}"),
            card: cardData,
            onSwipe: () => _checkAnswer(cardData.isCorrect),
            size: size,
            primaryColor: _primaryColor,
            secondaryColor: _secondaryColor,
            textColor: _textColor,
          ),
        ),
      ),
    );
  }

  // REDESIGNED EXPLANATION PANEL - DUOLINGO STYLE
  Widget _buildExplanationPanel({String? explanation}) {
    final Color resultColor = _lastAnswerCorrect ? _primaryColor : _incorrectColor;
    final String resultText = _lastAnswerCorrect ? "Correct!" : "Incorrect";
    final String explanationText = explanation ?? "No explanation available.";
    final String correctAnswerDisplay = capitalizeFirst(_currentCard?.answer) ?? 'N/A';

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
          parent: _explanationAnimationController,
          curve: Curves.easeOutQuart
      )),
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Result header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: resultColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _lastAnswerCorrect ? Icons.check_circle : Icons.cancel,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    resultText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Explanation content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Correct Answer:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4B4B4B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _primaryColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      correctAnswerDisplay,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Explanation:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4B4B4B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    capitalizeSentences(explanationText),
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(220, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      onPressed: _loadRandomQuestion,
                      child: const Text(
                        "CONTINUE",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
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

  // REDESIGNED HINT PANEL - DUOLINGO STYLE
  Widget _buildHintPanel({String? hint}) {
    final String hintText = hint ?? "Hint not available.";

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 100.0, left: 20, right: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _accentColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lightbulb,
                    color: _textColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "HINT",
                    style: TextStyle(
                      color: _textColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                capitalizeSentences(hintText),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: _textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// CardItem widget modified to match the Duolingo style
class CardItem extends StatefulWidget {
  final ChoiceCard card;
  final VoidCallback onSwipe;
  final double size;
  final Color primaryColor;
  final Color secondaryColor;
  final Color textColor;

  const CardItem({
    Key? key,
    required this.card,
    required this.onSwipe,
    required this.size,
    required this.primaryColor,
    required this.secondaryColor,
    required this.textColor,
  }) : super(key: key);

  @override
  _CardItemState createState() => _CardItemState();
}

class _CardItemState extends State<CardItem> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _resetController;
  Offset _dragOffset = Offset.zero;
  double _dragAngle = 0.0;
  bool _isPressed = false;
  final double swipeThreshold = 100.0;
  final double _perspective = 0.001;
  final double _maxTilt = 0.12;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    )..addListener(_onAnimationTick)
      ..addStatusListener(_onSwipeAnimationStatusChanged);
    _resetController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..addListener(_onAnimationTick);
  }

  void _onAnimationTick() { if (mounted) setState(() {}); }

  @override
  void dispose() {
    _controller.removeListener(_onAnimationTick);
    _controller.removeStatusListener(_onSwipeAnimationStatusChanged);
    _resetController.removeListener(_onAnimationTick);
    _controller.dispose();
    _resetController.dispose();
    super.dispose();
  }

  void _onSwipeAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onSwipe();
      if (mounted) {
        _dragOffset = Offset.zero;
        _dragAngle = 0.0;
        _controller.reset();
      }
    }
  }

  void _animateCardOff() {
    if (!mounted || _controller.isAnimating) return;
    final screenWidth = MediaQuery.of(context).size.width;
    final endX = _dragOffset.dx.sign * screenWidth * 1.2;
    final endY = _dragOffset.dy * 1.5;
    final endOffset = Offset(endX, endY);
    final offsetAnim = Tween<Offset>(begin: _dragOffset, end: endOffset)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    final angleAnim = Tween<double>(begin: _dragAngle, end: _dragOffset.dx.sign * 0.5)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    void listener() {
      if(_controller.isAnimating && mounted) {
        setState(() {
          _dragOffset = offsetAnim.value;
          _dragAngle = angleAnim.value;
        });
      }
    }
    _controller.addListener(listener);
    _controller.forward(from: 0.0).whenCompleteOrCancel(() {
      if(mounted) _controller.removeListener(listener);
    });
  }

  void _animateResetCard() {
    if (!mounted || _resetController.isAnimating || _controller.isAnimating) return;
    final curve = Curves.elasticOut;
    final offsetAnim = Tween<Offset>(begin: _dragOffset, end: Offset.zero)
        .animate(CurvedAnimation(parent: _resetController, curve: curve));
    final angleAnim = Tween<double>(begin: _dragAngle, end: 0.0)
        .animate(CurvedAnimation(parent: _resetController, curve: curve));
    void listener() {
      if (_resetController.isAnimating && mounted) {
        setState(() {
          _dragOffset = offsetAnim.value;
          _dragAngle = angleAnim.value;
        });
      }
    }
    _resetController.addListener(listener);
    _resetController.forward(from: 0.0).whenCompleteOrCancel(() {
      if (mounted) {
        if (_resetController.status == AnimationStatus.completed) {
          setState(() {
            _dragOffset = Offset.zero;
            _dragAngle = 0.0;
          });
        }
        _resetController.removeListener(listener);
        _resetController.reset();
      }
    });
  }

  Matrix4 _getTiltTransform() {
    final tiltX = (_dragOffset.dy / (widget.size * 1.2)).clamp(-1.0, 1.0) * _maxTilt;
    final tiltY = -(_dragOffset.dx / (widget.size * 1.2)).clamp(-1.0, 1.0) * _maxTilt;
    return Matrix4.identity()..setEntry(3, 2, _perspective)..rotateX(tiltX)..rotateY(tiltY);
  }

  @override
  Widget build(BuildContext context) {
    final double scale = _isPressed ? 0.94 : 1.0;
    final bool isDisabled = context.findAncestorStateOfType<_GameScreenState>()?._gameState == GameState.showingResult ?? false;

    return GestureDetector(
      onPanStart: isDisabled ? null : (details) {
        if (_resetController.isAnimating) _resetController.stop();
        if (_controller.isAnimating) _controller.stop();
        if (mounted) setState(() => _isPressed = true);
      },
      onPanUpdate: isDisabled ? null : (details) {
        if (mounted) setState(() {
          _dragOffset += details.delta;
          _dragAngle = (_dragOffset.dx / (widget.size * 2.5)).clamp(-0.4, 0.4);
        });
      },
      onPanEnd: isDisabled ? null : (details) {
        if (!mounted) return;
        final currentDragOffset = _dragOffset;
        setState(() => _isPressed = false);
        if (currentDragOffset.distance > swipeThreshold) {
          if(!_controller.isAnimating) _animateCardOff();
        } else {
          if(!_resetController.isAnimating && !_controller.isAnimating) _animateResetCard();
        }
      },
      onPanCancel: isDisabled ? null : () {
        if (!mounted) return;
        setState(() => _isPressed = false);
        if (!_controller.isAnimating && !_resetController.isAnimating) _animateResetCard();
      },
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..translate(_dragOffset.dx, _dragOffset.dy)
          ..multiply(_getTiltTransform())
          ..rotateZ(_dragAngle),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: widget.secondaryColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: AutoSizeText(
                      capitalizeFirst(widget.card.text),
                      textAlign: TextAlign.center,
                      wrapWords: true,
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      maxLines: 5,
                      minFontSize: 10,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}