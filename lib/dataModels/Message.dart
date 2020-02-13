class Message {
  String messageBody;

  String senderId;
  String receiverId;

  int messageStatus;
  String date;

  Message(
      {this.messageBody,
      this.senderId,
      this.receiverId,
      this.messageStatus,
      this.date});
}
