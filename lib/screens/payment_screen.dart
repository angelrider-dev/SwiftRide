import 'package:flutter/material.dart';
import '../constants/colors.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedPayment = 0;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'name': 'Cash',
      'subtitle': 'Pay with cash on arrival',
      'icon': Icons.money,
      'color': Colors.green,
    },
    {
      'name': 'JazzCash',
      'subtitle': 'Pay via JazzCash wallet',
      'icon': Icons.account_balance_wallet,
      'color': Colors.red,
    },
    {
      'name': 'EasyPaisa',
      'subtitle': 'Pay via EasyPaisa wallet',
      'icon': Icons.account_balance_wallet,
      'color': Colors.green,
    },
    {
      'name': 'Credit/Debit Card',
      'subtitle': 'Visa, Mastercard accepted',
      'icon': Icons.credit_card,
      'color': primaryBlue,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        title: const Text('Payment Methods', style: TextStyle(color: whiteColor)),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryBlue, lightBlue],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Methods',
                          style: TextStyle(
                            color: whiteColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Choose your preferred payment method',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.payment, color: accentOrange, size: 40),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Select Payment Method',
              style: TextStyle(
                color: primaryBlue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Payment Methods List
            ...List.generate(_paymentMethods.length, (index) {
              final method = _paymentMethods[index];
              final isSelected = _selectedPayment == index;

              return GestureDetector(
                onTap: () => setState(() => _selectedPayment = index),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryBlue : whiteColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? primaryBlue : Colors.grey.shade200,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.2)
                              : (method['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          method['icon'] as IconData,
                          color: isSelected ? whiteColor : method['color'] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              method['name'] as String,
                              style: TextStyle(
                                color: isSelected ? whiteColor : primaryBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              method['subtitle'] as String,
                              style: TextStyle(
                                color: isSelected ? Colors.white70 : greyColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isSelected ? accentOrange : greyColor,
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${_paymentMethods[_selectedPayment]['name']} selected as default payment!',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Payment Method',
                  style: TextStyle(
                    color: whiteColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}