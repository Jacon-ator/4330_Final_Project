import 'dart:async';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// A notification box that displays game messages
class NotificationBox extends PositionComponent {
  final Color backgroundColor;
  final Color borderColor;
  final List<GameNotification> _notifications = [];
  final int maxNotifications;
  final double spacing;
  
  NotificationBox({
    required Vector2 position,
    required Vector2 size,
    this.backgroundColor = const Color(0xFF2A2A2A),
    this.borderColor = Colors.white,
    this.maxNotifications = 3,
    this.spacing = 40.0,
  }) : super(position: position, size: size);
  
  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(12.0),
    );
    
    // Draw shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawRRect(rrect.shift(const Offset(3, 3)), shadowPaint);
    
    // Draw background with semi-transparency
    final bgPaint = Paint()..color = backgroundColor.withOpacity(0.7);
    canvas.drawRRect(rrect, bgPaint);
    
    // Draw border
    final borderPaint = Paint()
      ..color = borderColor.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(rrect, borderPaint);
    
    super.render(canvas);
  }
  
  /// Add a new notification to the box
  void addNotification(String message, {Color backgroundColor = const Color(0xFF1A5C32), double duration = 3.0}) {
    // Remove oldest notification if we've reached the maximum
    if (_notifications.length >= maxNotifications) {
      final oldestNotification = _notifications.removeAt(0);
      oldestNotification.removeFromParent();
    }

    // Create a temporary text component to measure the text width
    final textMeasure = TextComponent(
      text: message,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    
    // Ensure the text fits within the box width with some padding
    final maxWidth = size.x - 40; // 20px padding on each side
    String displayText = message;
    
    // If text is too wide, truncate it with ellipsis
    if (textMeasure.width > maxWidth) {
      // Approximate truncation - can be improved with more complex logic
      final ratio = maxWidth / textMeasure.width;
      final charCount = (message.length * ratio).floor() - 3; // Leave room for '...'
      displayText = message.substring(0, charCount) + '...';
    }

    // Calculate position for the new notification within the box
    final notificationPosition = Vector2(
      10,  // Left align with padding
      20 + (_notifications.length * spacing), // Start from top with padding
    );

    // Create the notification
    final notification = GameNotification(
      message: displayText,
      position: notificationPosition,
      backgroundColor: backgroundColor,
      duration: duration,
      maxWidth: maxWidth,
    );

    // Add the notification
    add(notification);
    _notifications.add(notification);
  }
}

/// A single notification message
class GameNotification extends PositionComponent {
  final String message;
  final Color backgroundColor;
  final double duration;
  final double? maxWidth;
  Timer? _timer;

  GameNotification({
    required this.message,
    required Vector2 position,
    this.backgroundColor = const Color(0xFF1A5C32),
    this.duration = 3.0,
    this.maxWidth,
  }) : super(position: position);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Create text component with improved styling
    final textComponent = TextComponent(
      text: message,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          shadows: [
            Shadow(
              blurRadius: 2.0,
              color: Colors.black54,
              offset: Offset(1.0, 1.0),
            ),
          ],
        ),
      ),
    );
    
    // Constrain width if maxWidth is provided
    if (maxWidth != null) {
      textComponent.size.x = maxWidth!;
    }
    
    await add(textComponent);
    
    // Set the size based on the text size plus padding
    size = Vector2(textComponent.width + 30, textComponent.height + 16);
    textComponent.position = Vector2(15, 8);
    
    // Create a custom background component with rounded corners
    final background = _RoundedRectComponent(
      size: size,
      position: Vector2.zero(),
      backgroundColor: backgroundColor,
    );
    
    // Add the background first so it appears behind the text
    await add(background);
    background.priority = -1; // Ensure background is behind text
    
    // Start the timer to remove the notification after the specified duration
    _timer = Timer(
      duration,
      onTick: () {
        removeFromParent();
      },
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer?.update(dt);
  }
}

/// Manager for the notification system
class NotificationManager extends PositionComponent {
  late NotificationBox _notificationBox;
  final Vector2 boxPosition;
  final Vector2 boxSize;
  
  NotificationManager({
    required this.boxPosition,
    required this.boxSize,
    double spacing = 40.0,
    int maxNotifications = 3,
  }) : super(position: Vector2.zero());
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Create the notification box
    _notificationBox = NotificationBox(
      position: boxPosition,
      size: boxSize,
      maxNotifications: 3,
      spacing: 40.0,
    );
    
    // Add the box to the component tree
    await add(_notificationBox);
  }
  
  /// Show a notification with the given message
  void showNotification(String message, {Color backgroundColor = const Color(0xFF1A5C32), double duration = 3.0}) {
    _notificationBox.addNotification(message, backgroundColor: backgroundColor, duration: duration);
  }
}

/// A custom component for drawing rounded rectangles with borders
class _RoundedRectComponent extends PositionComponent {
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double cornerRadius;
  
  _RoundedRectComponent({
    required Vector2 size,
    required Vector2 position,
    required this.backgroundColor,
    this.borderColor = Colors.white,
    this.borderWidth = 1.5,
    this.cornerRadius = 10.0,
  }) : super(size: size, position: position);
  
  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(cornerRadius),
    );
    
    // Draw shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    canvas.drawRRect(rrect.shift(const Offset(2, 2)), shadowPaint);
    
    // Draw background
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRRect(rrect, bgPaint);
    
    // Draw border
    final borderPaint = Paint()
      ..color = borderColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawRRect(rrect, borderPaint);
    
    super.render(canvas);
  }
}
