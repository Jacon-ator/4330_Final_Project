import 'package:flutter/material.dart';

class RaiseSlider extends StatefulWidget {
  final int minRaise;
  final int maxRaise;
  final int currentChips;
  final ValueChanged<int> onChanged;

  const RaiseSlider({
    super.key,
    required this.minRaise,
    required this.maxRaise,
    required this.currentChips,
    required this.onChanged,
  });

  @override
  State<RaiseSlider> createState() => _RaiseSliderState();
}

class _RaiseSliderState extends State<RaiseSlider> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.minRaise.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Raise Amount: \$${_currentValue.toInt()}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF1E4C3), // Light highlight
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Color(0xFFD48C2D), // Gold-orange track
            inactiveTrackColor: Color(0xFF3B8C2C).withOpacity(0.5),
            thumbColor: Color(0xFFF1E4C3), // Light knob
            overlayColor: Color(0xFFD48C2D).withOpacity(0.3),
            trackHeight: 4.0,
          ),
          child: Slider(
            value: _currentValue,
            min: widget.minRaise.toDouble(),
            max: widget.maxRaise.toDouble(),
            divisions: (widget.maxRaise - widget.minRaise).clamp(1, 100),
            label: '\$${_currentValue.toInt()}',
            onChanged: (double value) {
              setState(() {
                _currentValue = value;
              });
              widget.onChanged(value.toInt());
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Min: \$${widget.minRaise}',
                style: TextStyle(color: Color(0xFFF1E4C3))),
            Text('Max: \$${widget.maxRaise}',
                style: TextStyle(color: Color(0xFFF1E4C3))),
            Text('You: \$${widget.currentChips}',
                style: TextStyle(color: Color(0xFFF1E4C3))),
          ],
        ),
      ],
    );
  }
}
