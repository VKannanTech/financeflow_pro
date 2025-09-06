class User {
  final String id;
  final String name;
  final String email;
  final String profileImage;
  final double balance;
  final String accountNumber;
  final List<Transaction> recentTransactions;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.profileImage,
    required this.balance,
    required this.accountNumber,
    required this.recentTransactions,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImage: json['profileImage'],
      balance: json['balance'].toDouble(),
      accountNumber: json['accountNumber'],
      recentTransactions: (json['recentTransactions'] as List)
          .map((t) => Transaction.fromJson(t))
          .toList(),
    );
  }
}

class Transaction {
  final String id;
  final String title;
  final String description;
  final double amount;
  final String type; // 'credit', 'debit'
  final String status; // 'pending', 'completed', 'failed'
  final DateTime date;
  final String category;
  final String icon;

  Transaction({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.type,
    required this.status,
    required this.date,
    required this.category,
    required this.icon,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      amount: json['amount'].toDouble(),
      type: json['type'],
      status: json['status'],
      date: DateTime.parse(json['date']),
      category: json['category'],
      icon: json['icon'],
    );
  }

  Transaction copyWith({String? status}) {
    return Transaction(
      id: id,
      title: title,
      description: description,
      amount: amount,
      type: type,
      status: status ?? this.status,
      date: date,
      category: category,
      icon: icon,
    );
  }
}