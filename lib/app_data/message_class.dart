import 'package:google_ai_chat/app_data/constants.dart';

class Message {
  String message;
  int sender; // 0 for user & 1 for AI
  DateTime timeSent;
  String id;
  String modelName;

  Message({
    required this.message,
    required this.sender,
    required this.timeSent,
    required this.id,
    required this.modelName,
  });

  // Method to convert a Message object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'sender': sender,
      'timeSent': timeSent.toIso8601String(),
      'id': id,
      'modelName': modelName,
    };
  }

  // Factory constructor to create a Message object from a JSON map
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      message: json['message'],
      sender: json['sender'],
      timeSent: DateTime.parse(json['timeSent']),
      id: json['id'] ?? generateId(),
      modelName: json['modelName'] ?? geminiModule,
    );
  }

  @override
  String toString() {
    return "${sender == 0? "User" : "AI"}: $message";
  }
}
