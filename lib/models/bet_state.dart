/// Betting state for the game
class BetState {
  final double totalCoins;
  final int? selectedCar; // 0, 1, or 2
  final double betAmount;

  BetState({
    this.totalCoins = 100.0,
    this.selectedCar,
    this.betAmount = 0.0,
  });

  BetState copyWith({
    double? totalCoins,
    int? selectedCar,
    double? betAmount,
  }) {
    return BetState(
      totalCoins: totalCoins ?? this.totalCoins,
      selectedCar: selectedCar ?? this.selectedCar,
      betAmount: betAmount ?? this.betAmount,
    );
  }

  bool canPlaceBet() {
    return selectedCar != null &&
        betAmount > 0.0 &&
        betAmount <= totalCoins &&
        (totalCoins - betAmount) >= 0.0;
  }

  double calculateWinnings(int winner) {
    if (selectedCar == null || betAmount == 0) return 0.0;
    if (selectedCar == winner) {
      return betAmount * 2.0; // 2x odds
    }
    return 0.0;
  }
}
