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
| Jared Arrowood  | Backend Game Logic, UI development, Firebase linking to Game Logic|
| Austin Cao  | Shop implementation, Chat implementation, Backend|
| Jacob Kinchen  | All the art, initial setup of the repository, skinning the UI elements|
| Hoa Nguyen  | Game Logic, Firebase setup, CI/CD Pipline, General bug fixing|
| Adian Elier  | Hand evaluation, card evaluator, unit testing |
| Anna Olinde  | Frontend implementation, general UI/UX flow |
| Philemon Holmes  |Music creation, connecting the music to the game|
| Troy Williams  | Firebase initial setup, assisting with chat implementation|
| Matthew Nguyen | Profile Page, general bug fixing|
| Minseo Lee  | Terminal on the game screen, bot implementation |

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
