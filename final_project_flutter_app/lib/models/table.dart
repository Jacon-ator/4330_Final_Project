class Table {
  final String id;
  final String name;
  final int totalCapacity;
  final String backgroundImage = 'art/Poker Party Gameplay Mock Up.png';
  final bool isAvailable;
  int pot = 0;
  bool potIsRight =
      false; // Indicates if the pot is correctly distributed among players

  Table({
    required this.id,
    required this.name,
    required this.totalCapacity,
    required this.isAvailable,
  });

  @override
  String toString() {
    return 'Table{id: $id, name: $name, capacity: $totalCapacity, isAvailable: $isAvailable}';
  }
}
