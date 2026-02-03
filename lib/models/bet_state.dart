/// Betting state for the game
class BetState {
  final double totalMoney; // VNĐ
  final int? selectedCar; // 0, 1, or 2
  final double betAmount; // VNĐ

  BetState({
    this.totalMoney = 100000.0,
    this.selectedCar,
    this.betAmount = 0.0,
  });

  BetState copyWith({double? totalMoney, int? selectedCar, double? betAmount}) {
    return BetState(
      totalMoney: totalMoney ?? this.totalMoney,
      selectedCar: selectedCar ?? this.selectedCar,
      betAmount: betAmount ?? this.betAmount,
    );
  }

  bool canPlaceBet() {
    return selectedCar != null &&
        betAmount > 0.0 &&
        betAmount <= totalMoney &&
        (totalMoney - betAmount) >= 0.0;
  }

  double calculateWinnings(int winner) {
    if (selectedCar == null || betAmount == 0) return 0.0;
    if (selectedCar == winner) {
      return betAmount * 2.0; // 2x odds
    }
    return 0.0;
  }

  /// Check if user has run out of money
  bool isBroke() {
    return totalMoney <= 0;
  }
}
