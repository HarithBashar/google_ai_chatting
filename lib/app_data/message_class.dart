class Message {
  String message;
  int sender; // 0 for user & 1 for AI

  Message({
    required this.message,
    required this.sender,
  });

  Map<String, dynamic> toJson () {
    return {
      "message": message,
      "sender": sender,
    };
  }

}
