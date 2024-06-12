import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final String userId;
  final String dueDate;
  final String name;
  final String priority;
  final String? notes;
  final Timestamp createdAt;
  final DocumentReference reference;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.userId,
    required this.dueDate,
    required this.name,
    required this.priority,
    this.notes,
    required this.createdAt,
    required this.reference,
  });

  factory Task.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      userId: data['userId'] ?? '',
      dueDate: _parseDueDate(data['dueDate']),
      name: data['name'] ?? '',
      priority: data['priority'] ?? '',
      notes: data['notes'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      reference: doc.reference,
    );
  }

  static String _parseDueDate(dynamic dueDate) {
    if (dueDate is Timestamp) {
      return (dueDate as Timestamp).toDate().toString();
    } else {
      return dueDate as String;
    }
  }
}
