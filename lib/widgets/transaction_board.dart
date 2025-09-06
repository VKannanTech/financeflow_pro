import 'package:flutter/material.dart';
import '../models/user.dart';

class TransactionBoard extends StatefulWidget {
  final List<Transaction> transactions;

  const TransactionBoard({
    super.key,
    required this.transactions,
  });

  @override
  State<TransactionBoard> createState() => _TransactionBoardState();
}

class _TransactionBoardState extends State<TransactionBoard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  List<Transaction> pending = [];
  List<Transaction> completed = [];
  List<Transaction> failed = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _categorizeTransactions();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _categorizeTransactions() {
    pending.clear();
    completed.clear();
    failed.clear();

    for (var transaction in widget.transactions) {
      switch (transaction.status.toLowerCase()) {
        case 'pending':
          pending.add(transaction);
          break;
        case 'completed':
          completed.add(transaction);
          break;
        case 'failed':
          failed.add(transaction);
          break;
      }
    }
  }

  void _moveTransaction(Transaction transaction, String newStatus) {
    setState(() {
      pending.removeWhere((t) => t.id == transaction.id);
      completed.removeWhere((t) => t.id == transaction.id);
      failed.removeWhere((t) => t.id == transaction.id);

      final updatedTransaction = transaction.copyWith(status: newStatus);

      switch (newStatus) {
        case 'pending':
          pending.add(updatedTransaction);
          break;
        case 'completed':
          completed.add(updatedTransaction);
          break;
        case 'failed':
          failed.add(updatedTransaction);
          break;
      }
    });

    _animationController.forward().then((_) {
      _animationController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Summary Cards
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[50]!, Colors.blue[100]!],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Pending',
                    pending.length,
                    Colors.orange,
                    Icons.hourglass_top,
                  ),
                ),
                Expanded(
                  child: _buildSummaryCard(
                    'Completed',
                    completed.length,
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
                Expanded(
                  child: _buildSummaryCard(
                    'Failed',
                    failed.length,
                    Colors.red,
                    Icons.error,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Transaction Columns
          Expanded(
            child: Row(
              children: [
                _buildTransactionColumn(
                  'Pending',
                  Colors.orange,
                  Icons.hourglass_top,
                  pending,
                  isDraggableSource: true,
                ),
                const SizedBox(width: 12),
                _buildDropZoneColumn(
                  'Completed',
                  Colors.green,
                  Icons.check_circle,
                  completed,
                  'completed',
                ),
                const SizedBox(width: 12),
                _buildDropZoneColumn(
                  'Failed',
                  Colors.red,
                  Icons.error,
                  failed,
                  'failed',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String title,
      int count,
      Color color,
      IconData icon,
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionColumn(
      String title,
      Color color,
      IconData icon,
      List<Transaction> transactions, {
        bool isDraggableSource = false,
      }) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: transactions.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return _buildTransactionCard(
                    transaction,
                    color,
                    isDraggable: isDraggableSource,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropZoneColumn(
      String title,
      Color color,
      IconData icon,
      List<Transaction> transactions,
      String targetStatus,
      ) {
    return Expanded(
      child: DragTarget<Transaction>(
        onAccept: (transaction) {
          _moveTransaction(transaction, targetStatus);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Transaction moved to $title'),
              backgroundColor: color,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        builder: (context, candidateData, rejectedData) {
          final isHighlighted = candidateData.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: isHighlighted ? Border.all(color: color, width: 2) : null,
              boxShadow: [
                BoxShadow(
                  color: isHighlighted
                      ? color.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.1),
                  blurRadius: isHighlighted ? 15 : 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isHighlighted ? color.withOpacity(0.8) : color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(icon, color: Colors.white, size: 20),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: transactions.isEmpty
                      ? _buildDropZone(color, isHighlighted)
                      : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return _buildTransactionCard(
                        transaction,
                        color,
                        isDraggable: false,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionCard(
      Transaction transaction,
      Color color, {
        bool isDraggable = false,
      }) {
    final isCredit = transaction.type == 'credit';
    final amountColor = isCredit ? Colors.green : Colors.red;
    final sign = isCredit ? '+' : '-';

    final card = Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    transaction.icon,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$sign\${transaction.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: amountColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (isDraggable)
                Icon(
                  Icons.drag_indicator,
                  color: Colors.grey[400],
                  size: 16,
                ),
            ],
          ),
        ],
      ),
    );

    if (!isDraggable) return card;

    return Draggable<Transaction>(
      data: transaction,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.05,
          child: Container(
            width: 200,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      transaction.icon,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '$sign\${transaction.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: card,
      ),
      child: card,
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 40,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'No transactions',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropZone(Color color, bool isHighlighted) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isHighlighted ? color.withOpacity(0.1) : Colors.grey[50],
        border: Border.all(
          color: isHighlighted ? color.withOpacity(0.5) : Colors.grey[300]!,
          width: 2,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            scale: isHighlighted ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isHighlighted ? Icons.add_circle : Icons.add_circle_outline,
              size: 40,
              color: isHighlighted ? color : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isHighlighted ? 'Drop here!' : 'Drop transactions here',
            style: TextStyle(
              color: isHighlighted ? color : Colors.grey[500],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
