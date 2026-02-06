import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/order.dart';

class OrderTile extends StatelessWidget {

  final Order order;
  final VoidCallback onTap;

  const OrderTile({
    super.key,
    required this.onTap,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {

    // SMART COLOR LOGIC
    final isPending = order.status.toLowerCase() == 'pending';
    final statusColor = isPending ? Colors.orange : Colors.green;
    final currencyFormat = NumberFormat.currency(locale: 'en_IN' , symbol: '₹');


    // DATE FORMATTING
    final date = DateTime.parse(order.createdAt);
    final formattedDate =DateFormat('MMM d').format(date);


    return Card(
      margin: EdgeInsets.only(bottom: 20),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // LEFT STATUS STRIP - NAANNI NAANI NAAANI
        leading: Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        // CENTER : CUSTOMER & ITEM
        title: Text(
          order.customerName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          "${order.items.length} Item(s) • $formattedDate",
          style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(order.totalAmount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(width: 8,),
            const Icon(Icons.chevron_right,color: Colors.grey,)
          ],
        ),
      ),
    );
  }
}
