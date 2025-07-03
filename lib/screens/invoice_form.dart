import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class InvoiceForm extends StatefulWidget {
  const InvoiceForm({super.key});

  @override
  State<InvoiceForm> createState() => _InvoiceFormState();
}
santhoji
class _InvoiceFormState extends State<InvoiceForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController clientNameController = TextEditingController();
  final TextEditingController serviceController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  DateTime? dueDate;
  String status = 'Unpaid';
  bool isLoading = false;

  Future<void> saveInvoice() async {
    final user = FirebaseAuth.instance.currentUser;
    if (_formKey.currentState!.validate() && dueDate != null) {
      setState(() => isLoading = true);
      await FirebaseFirestore.instance.collection('invoices').add({
        'user_id': user?.uid ?? 'anonymous',
        'client_name': clientNameController.text.trim(),
        'service': serviceController.text.trim(),
        'amount': double.parse(amountController.text),
        'due_date': dueDate,
        'status': status,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        isLoading = false;
        clientNameController.clear();
        serviceController.clear();
        amountController.clear();
        dueDate = null;
        status = 'Unpaid';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invoice saved successfully!")),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields.")));
    }
  }

  Future<void> pickDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => dueDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dueDateStr = dueDate == null
        ? "Pick Due Date"
        : DateFormat.yMMMd().format(dueDate!);

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text(
          "New Invoice",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 72, 125, 151),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(
                Icons.description_outlined,
                size: 70,
                color: Colors.blueGrey,
              ),
              const SizedBox(height: 10),
              const Text(
                "Create Invoice",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: clientNameController,
                decoration: const InputDecoration(
                  labelText: "Client Name",
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Enter client name' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: serviceController,
                decoration: const InputDecoration(
                  labelText: "Service",
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.work_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Enter service name' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Amount (₹)",
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Enter amount' : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Due Date: $dueDateStr",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => pickDueDate(context),
                    child: const Text(
                      "Select Date",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(
                  labelText: "Status",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                dropdownColor: Colors.white,
                items: ['Unpaid', 'Paid'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    status = val!;
                  });
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : saveInvoice,
                  icon: const Icon(
                    Icons.save_alt,
                    size: 20,
                    color: Colors.white,
                  ),
                  label: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : const Text(
                          "Submit Invoice",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color.fromARGB(255, 72, 125, 151),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InvoiceFormEdit extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> initialData;

  const InvoiceFormEdit({
    super.key,
    required this.docId,
    required this.initialData,
  });

  @override
  State<InvoiceFormEdit> createState() => _InvoiceFormEditState();
}

class _InvoiceFormEditState extends State<InvoiceFormEdit> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController clientController;
  late TextEditingController serviceController;
  late TextEditingController amountController;
  late DateTime dueDate;
  late String status;

  @override
  void initState() {
    super.initState();
    clientController = TextEditingController(
      text: widget.initialData['client_name'],
    );
    serviceController = TextEditingController(
      text: widget.initialData['service'],
    );
    amountController = TextEditingController(
      text: widget.initialData['amount'].toString(),
    );
    dueDate = (widget.initialData['due_date'] as Timestamp).toDate();
    status = widget.initialData['status'];
  }

  Future<void> updateInvoice() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('invoices')
          .doc(widget.docId)
          .update({
            'client_name': clientController.text.trim(),
            'service': serviceController.text.trim(),
            'amount': double.parse(amountController.text),
            'due_date': dueDate,
            'status': status,
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invoice updated successfully!")),
      );

      Navigator.pop(context);
    }
  }

  Future<void> pickDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => dueDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dueDateStr = DateFormat.yMMMd().format(dueDate);

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text(
          "Edit Invoice",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 72, 125, 151),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: clientController,
                decoration: InputDecoration(
                  labelText: "Client Name",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: serviceController,
                decoration: InputDecoration(
                  labelText: "Service",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Amount (₹)",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Due Date: $dueDateStr",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: pickDueDate,
                    child: const Text(
                      "Change Date",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField(
                value: status,
                decoration: InputDecoration(
                  labelText: "Status",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                dropdownColor: Colors.white,
                items: ['Unpaid', 'Paid']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => status = val!),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: updateInvoice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 72, 125, 151),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Update Invoice",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
