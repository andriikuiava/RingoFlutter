class Currency {
  int id;
  String name;
  String symbol;

  Currency({
    required this.id,
    required this.name,
    required this.symbol,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
    );
  }

  @override
  String toString() {
    return 'Currency{id: $id, name: $name, symbol: $symbol}';
  }
}
