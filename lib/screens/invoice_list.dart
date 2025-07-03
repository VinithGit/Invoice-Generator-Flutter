import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'invoice_form.dart'; // Make sure this file includes InvoiceFormEdit class

class InvoiceList extends StatelessWidget {
  const InvoiceList({super.key});

  bool isOverdue(DateTime dueDate) {
    return dueDate.isBefore(DateTime.now());
  }

  Future<void> deleteInvoice(String docId) async {
    await FirebaseFirestore.instance.collection('invoices').doc(docId).delete();
  }

  Future<void> markAsResent(String docId) async {
    await FirebaseFirestore.instance.collection('invoices').doc(docId).update({
      'resent': true,
      'resent_timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text(
          "All Invoices",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 72, 125, 151),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('invoices')
            .where('user_id', isEqualTo: userId)
            // .orderBy('due_date') // ✅ Optional: Uncomment once all invoices have due_date
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No invoices found.",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final invoice = docs[index];
              final dueDate = (invoice['due_date'] as Timestamp).toDate();
              final isPaid = invoice['status'] == 'Paid';
              final overdue = isOverdue(dueDate) && !isPaid;

              return Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color.fromARGB(255, 72, 125, 151),
                    child: const Icon(Icons.receipt_long, color: Colors.white),
                  ),
                  title: Text(
                    invoice['client_name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text("Service: ${invoice['service']}"),
                      Text("Amount: ₹${invoice['amount']}"),
                      Text("Due: ${DateFormat.yMMMd().format(dueDate)}"),
                      Text(
                        "Status: ${invoice['status']} ${overdue ? "(Overdue)" : ""}",
                        style: TextStyle(
                          color: overdue
                              ? Colors.redAccent
                              : (isPaid ? Colors.green : Colors.red),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    color: Colors.white,
                    onSelected: (value) {
                      if (value == 'delete') deleteInvoice(invoice.id);
                      //if (value == 'resend') markAsResent(invoice.id);
                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => InvoiceFormEdit(
                              docId: invoice.id,
                              initialData:
                                  invoice.data() as Map<String, dynamic>,
                            ),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text("Edit")),
                      PopupMenuItem(value: 'delete', child: Text("Delete")),
                     // PopupMenuItem(value: 'resend', child: Text("Resend")),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
