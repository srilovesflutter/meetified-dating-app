import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum TransactionStatus {
  pending,
  verifying,
  completed,
  failed,
  refunded
}

enum TransactionType {
  premium,
  refund
}

class TransactionModel extends Equatable {
  final String transactionId;
  final String userId;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? upiTransactionId;
  final String? failureReason;
  final Map<String, dynamic> metadata;

  const TransactionModel({
    required this.transactionId,
    required this.userId,
    required this.amount,
    required this.type,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.upiTransactionId,
    this.failureReason,
    required this.metadata,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      transactionId: json['transactionId'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => TransactionType.premium,
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => TransactionStatus.pending,
      ),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      completedAt: json['completedAt'] != null 
          ? (json['completedAt'] as Timestamp).toDate() 
          : null,
      upiTransactionId: json['upiTransactionId'] as String?,
      failureReason: json['failureReason'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'userId': userId,
      'amount': amount,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'upiTransactionId': upiTransactionId,
      'failureReason': failureReason,
      'metadata': metadata,
    };
  }

  TransactionModel copyWith({
    String? transactionId,
    String? userId,
    double? amount,
    TransactionType? type,
    TransactionStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? upiTransactionId,
    String? failureReason,
    Map<String, dynamic>? metadata,
  }) {
    return TransactionModel(
      transactionId: transactionId ?? this.transactionId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      upiTransactionId: upiTransactionId ?? this.upiTransactionId,
      failureReason: failureReason ?? this.failureReason,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isCompleted => status == TransactionStatus.completed;
  bool get isPending => status == TransactionStatus.pending;
  bool get isFailed => status == TransactionStatus.failed;
  bool get isRefunded => status == TransactionStatus.refunded;

  Duration get processingTime {
    if (completedAt == null) return Duration.zero;
    return completedAt!.difference(createdAt);
  }

  @override
  List<Object?> get props => [
        transactionId,
        userId,
        amount,
        type,
        status,
        createdAt,
        completedAt,
        upiTransactionId,
        failureReason,
        metadata,
      ];
}

class UPIVerificationResult extends Equatable {
  final bool isVerified;
  final String? transactionId;
  final double? amount;
  final DateTime? timestamp;
  final String? method;
  final String? errorMessage;

  const UPIVerificationResult({
    required this.isVerified,
    this.transactionId,
    this.amount,
    this.timestamp,
    this.method,
    this.errorMessage,
  });

  factory UPIVerificationResult.verified({
    required String transactionId,
    required double amount,
    required DateTime timestamp,
    required String method,
  }) {
    return UPIVerificationResult(
      isVerified: true,
      transactionId: transactionId,
      amount: amount,
      timestamp: timestamp,
      method: method,
    );
  }

  factory UPIVerificationResult.failed({
    required String errorMessage,
  }) {
    return UPIVerificationResult(
      isVerified: false,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isVerified, transactionId, amount, timestamp, method, errorMessage];
}