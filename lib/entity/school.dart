class School {
  final String documentId;
  final String address;
  final String board;
  final String schoolId;
  final String schoolName;

  School(
      {this.documentId,
      this.address,
      this.board,
      this.schoolId,
      this.schoolName});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is School &&
          runtimeType == other.runtimeType &&
          documentId == other.documentId &&
          address == other.address &&
          board == other.board &&
          schoolId == other.schoolId &&
          schoolName == other.schoolName;

  @override
  int get hashCode =>
      documentId.hashCode ^
      address.hashCode ^
      board.hashCode ^
      schoolId.hashCode ^
      schoolName.hashCode;

  @override
  String toString() {
    return 'School Entity{documentId: $documentId, address: $address, board: $board, schoolId: $schoolId, schoolName: $schoolName}';
  }
}
