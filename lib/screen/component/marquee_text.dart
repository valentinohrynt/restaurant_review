import 'package:flutter/material.dart';

class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final double speed;
  final double pauseAfterRound;

  const MarqueeText({
    super.key,
    required this.text,
    this.style,
    this.speed = 50,
    this.pauseAfterRound = 1.0,
  });

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _animation;
  late double _maxScrollExtent;
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _maxScrollExtent = _scrollController.position.maxScrollExtent;
        _animation = Tween<double>(
          begin: 0,
          end: _maxScrollExtent,
        ).animate(_animationController);
        
        _animation.addListener(() {
          _scrollController.jumpTo(_animation.value);
        });
        
        _animationController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Text(
        widget.text,
        style: widget.style,
      ),
    );
  }
}