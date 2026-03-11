import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  List<dynamic> _payments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    final userId = AuthService().currentUser?.userId;
    if (userId == null) return;
    try {
      final response = await ApiService().get('payments/$userId');
      if (mounted) setState(() { _payments = response as List; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _setDefault(int paymentId) async {
    final userId = AuthService().currentUser?.userId;
    if (userId == null) return;
    try {
      await ApiService().post('payments/default', {'user_id': userId, 'payment_method_id': paymentId});
      await _loadPayments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _deletePayment(int paymentId) async {
    final userId = AuthService().currentUser?.userId;
    if (userId == null) return;
    try {
      await ApiService().post('payments/delete', {'user_id': userId, 'payment_method_id': paymentId});
      await _loadPayments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _showAddDialog() {
    final cardTypeController = TextEditingController();
    final lastFourController = TextEditingController();
    final expiryMonthController = TextEditingController();
    final expiryYearController = TextEditingController();
    String selectedType = 'VISA';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text("Add Payment Method"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Card type selector
                Row(
                  children: ['VISA', 'MASTERCARD', 'AMEX'].map((type) {
                    final isSelected = selectedType == type;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setDialogState(() => selectedType = type),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF8C44FF).withOpacity(0.2) : Colors.black26,
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected ? Border.all(color: const Color(0xFF8C44FF)) : null,
                          ),
                          child: Text(type, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF8C44FF) : Colors.grey)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: lastFourController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: const InputDecoration(labelText: "Last 4 digits", counterText: ""),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: expiryMonthController,
                        keyboardType: TextInputType.number,
                        maxLength: 2,
                        decoration: const InputDecoration(labelText: "MM", counterText: ""),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: expiryYearController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        decoration: const InputDecoration(labelText: "YYYY", counterText: ""),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () async {
                if (lastFourController.text.length != 4 || expiryMonthController.text.isEmpty || expiryYearController.text.isEmpty) {
                  return;
                }
                final userId = AuthService().currentUser?.userId;
                if (userId == null) return;
                try {
                  await ApiService().post('payments/add', {
                    'user_id': userId,
                    'card_type': selectedType,
                    'card_last_four': lastFourController.text,
                    'expiry_month': expiryMonthController.text,
                    'expiry_year': expiryYearController.text,
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
                  await _loadPayments();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
                  }
                }
              },
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }

  IconData _cardIcon(String type) {
    switch (type.toUpperCase()) {
      case 'VISA': return Icons.credit_card;
      case 'MASTERCARD': return Icons.credit_card;
      case 'AMEX': return Icons.credit_card;
      default: return Icons.credit_card;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment Methods")),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFF8C44FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8C44FF)))
          : _payments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
                        child: const Icon(Icons.credit_card_off, size: 40, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      const Text("No payment methods", style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 10),
                      const Text("Tap + to add one", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _payments.length,
                  itemBuilder: (context, index) {
                    final pm = _payments[index];
                    final isDefault = pm['is_default'] == 1 || pm['is_default'] == true;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(16),
                        border: isDefault ? Border.all(color: const Color(0xFF8C44FF), width: 1.5) : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
                            child: Icon(_cardIcon(pm['card_type']), color: isDefault ? const Color(0xFF8C44FF) : Colors.grey),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text("${pm['card_type']} •••• ${pm['card_last_four']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                    if (isDefault) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: const Color(0xFF8C44FF), borderRadius: BorderRadius.circular(4)),
                                        child: const Text("DEFAULT", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text("Expires ${pm['expiry_month']}/${pm['expiry_year']}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: Colors.grey),
                            color: const Color(0xFF2A2A2A),
                            onSelected: (value) {
                              if (value == 'default') _setDefault(pm['payment_method_id']);
                              if (value == 'delete') _deletePayment(pm['payment_method_id']);
                            },
                            itemBuilder: (_) => [
                              if (!isDefault) const PopupMenuItem(value: 'default', child: Text("Set as Default")),
                              const PopupMenuItem(value: 'delete', child: Text("Delete", style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
