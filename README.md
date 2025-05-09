# Poker Party Project

This is a Flutter-based Texas Hold'em poker game developed as part of the CSC 4330 final project.

## Features
- Multiplayer poker gameplay with AI opponents
- Firebase backend for online play
- Custom card and table skins
- Profile management
- In-game audio and sound effects

## Team Contributions

| Team Member | Contributions |
|-------------|---------------|
| [Your Name] | - Game state management<br>- Component lifecycle implementation<br>- Card dealing and evaluation logic<br>- UI component integration |
| Jared Arrowood  | - [Backend Game Logic, UI development, Firebase linking to Game Logic]|
| TeamMate 2  | - [Add their contributions here]<br>- [Feature 1]<br>- [Feature 2]<br>- [Task 3] |
| TeamMate 3  | - [Add their contributions here]<br>- [Feature 1]<br>- [Feature 2]<br>- [Task 3] |
| TeamMate 4  | - [Add their contributions here]<br>- [Feature 1]<br>- [Feature 2]<br>- [Task 3] |

## Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure Firebase (see Firebase setup instructions)
4. Run `flutter run` to start the app

## Implementation Notes

### Component Lifecycle Management
- All UI components are initialized in `onLoad()` method
- Game state is managed centrally and synchronized with Firebase
- Direct references to frequently used components are stored as class members to avoid race conditions

### Known Issues
- [List any known issues here]
