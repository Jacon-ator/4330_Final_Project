import 'package:flutter/material.dart';

class PlayerBalanceNotifier extends ChangeNotifier {
  final Map<String, int> _playerBalances = {};

  // Add a player with an initial balance
  void addPlayer(String playerName, int initialBalance) {
    _playerBalances[playerName] = initialBalance;
    notifyListeners();
  }

  // Update a player's balance
  void updateBalance(String playerName, int newBalance) {
    if (_playerBalances.containsKey(playerName)) {
      _playerBalances[playerName] = newBalance;
      notifyListeners();
    }
  }

  // Get a player's balance
  int getBalance(String playerName) {
    return _playerBalances[playerName] ?? 0;
  }

  // Remove a player
  void removePlayer(String playerName) {
    if (_playerBalances.containsKey(playerName)) {
      _playerBalances.remove(playerName);
      notifyListeners();
    }
  }

  // Get all player balances
  Map<String, int> get allBalances => Map.unmodifiable(_playerBalances);
}
