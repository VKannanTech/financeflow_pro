class AuthService {
  static User? _currentUser;

  static User? get currentUser => _currentUser;

  static Future<bool> login(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (email == "user@demo.com" && password == "123456") {
      _currentUser = User(
        id: "1",
        name: "John Anderson",
        email: email,
        profileImage: "https://via.placeholder.com/150",
        balance: 24580.75,
        accountNumber: "**** **** **** 1234",
        recentTransactions: [
          Transaction(
            id: "1",
            title: "Salary Deposit",
            description: "Monthly salary from TechCorp",
            amount: 5500.00,
            type: "credit",
            status: "completed",
            date: DateTime.now().subtract(const Duration(hours: 2)),
            category: "Salary",
            icon: "💰",
          ),
          Transaction(
            id: "2",
            title: "Grocery Shopping",
            description: "SuperMarket purchase",
            amount: 156.30,
            type: "debit",
            status: "completed",
            date: DateTime.now().subtract(const Duration(hours: 5)),
            category: "Shopping",
            icon: "🛒",
          ),
          Transaction(
            id: "3",
            title: "Electric Bill",
            description: "Monthly electricity payment",
            amount: 89.50,
            type: "debit",
            status: "pending",
            date: DateTime.now().subtract(const Duration(hours: 8)),
            category: "Bills",
            icon: "⚡",
          ),
          Transaction(
            id: "4",
            title: "Investment Return",
            description: "Stock dividend payment",
            amount: 245.80,
            type: "credit",
            status: "completed",
            date: DateTime.now().subtract(const Duration(days: 1)),
            category: "Investment",
            icon: "📈",
          ),
        ],
      );
      return true;
    }
    return false;
  }

  static void logout() {
    _currentUser = null;
  }
}