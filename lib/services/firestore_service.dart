import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:invoice_generator_app/models/invoice.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Stream<List<Invoice>> getInvoices() => _db
      .collection('invoices')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Invoice.fromMap(doc.id, doc.data()))
          .toList());

  Future<void> addInvoice(Invoice invoice) async {
    final docRef = _db.collection('invoices').doc();
    await docRef.set(invoice.toMap());
  }

  Future<void> updateInvoice(Invoice invoice) async {
    await _db.collection('invoices').doc(invoice.id).update(invoice.toMap());
  }

  Future<void> deleteInvoice(String id) async {
    await _db.collection('invoices').doc(id).delete();
  }
}
