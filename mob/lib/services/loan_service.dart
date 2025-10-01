
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/loan.dart';
abstract class LoanService {
  Future<Loan> createLoanApi({
    required int lenderId,
    required int borrowerId,
    required double amount,
    required String currency,
    required String dueDate,
    required int createdById,
  });
  Future<List<Loan>> getActiveLoans(int userId);
  Future<Loan> createLoan(Loan loan);
  Future<Loan> confirmLoan(int loanId, int userId, bool isConfirmed);
  Future<Loan> updateLoanDueDate(int loanId, DateTime newDueDate);
  Future<void> deleteLoan(int loanId);
  Stream<List<Loan>> watchActiveLoans(int userId);
  Future<Map<String, dynamic>> getDashboardData(int userId);
}

class ApiLoanService implements LoanService {
  Future<Loan> createLoanApi({
    required int lenderId,
    required int borrowerId,
    required double amount,
    required String currency,
    required String dueDate,
    required int createdById,
  }) async {
    final url = Uri.parse('http://localhost:8000/loans');
    print('[LoanService] Sending loan creation request to: $url');
    print('[LoanService] Request body: ' + jsonEncode({
      'lender_id': lenderId,
      'borrower_id': borrowerId,
      'amount': amount,
      'currency': currency,
      'due_date': dueDate,
      'created_by_id': createdById,
    }));
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'accept': 'application/json'},
        body: jsonEncode({
          'lender_id': lenderId,
          'borrower_id': borrowerId,
          'amount': amount,
          'currency': currency,
          'due_date': dueDate,
          'created_by_id': createdById,
        }),
      );
      print('[LoanService] Response status: ${response.statusCode}');
      print('[LoanService] Response body: ${response.body}');
      if (response.statusCode == 201) {
        return Loan.fromJson(jsonDecode(response.body));
      } else {
        print('[LoanService] Error: Failed to create loan. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to create loan: ${response.statusCode} ${response.body}');
      }
    } catch (e, stack) {
      print('[LoanService] Exception: $e');
      print('[LoanService] Stacktrace: $stack');
      rethrow;
    }
  }
  Future<Map<String, dynamic>> getDashboardData(int userId) async {
    final url = Uri.parse('http://localhost:8000/loans/dashboard/$userId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load dashboard data: ${response.statusCode}');
    }
  }
  // This would be implemented with API calls to your backend
  // For now, we'll provide mock implementations

  @override
  Future<List<Loan>> getActiveLoans(int userId) async {
    // Mock implementation
    return Future.delayed(
      const Duration(seconds: 1),
      () => [
        Loan(
          id: 23,
          lenderId: 22,
          borrowerId: 43,
          amount: 88.0,
          currency: Currency.MAD,
          dueDate: DateTime.now().add(const Duration(days: 25)),
          status: LoanStatus.ACTIVE,
          lenderConfirmed: true,
          borrowerConfirmed: true,
          confirmedAt: null,
          createdById: 22,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Loan(
          id: 3,
          lenderId: 22,
          borrowerId: 55,
          amount: 14.0,
          currency: Currency.USD,
          dueDate: DateTime.now().add(const Duration(days: 12)),
          status: LoanStatus.ACTIVE,
          lenderConfirmed: true,
          borrowerConfirmed: true,
          confirmedAt: null,
          createdById: 22,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
    );
  }


  // getCompletedLoans removed

  @override
  Future<Loan> createLoan(Loan loan) async {
    // Mock implementation
    return Future.delayed(
      const Duration(seconds: 1),
      () => Loan(
        id: 34,
        lenderId: loan.lenderId,
        borrowerId: loan.borrowerId,
        amount: loan.amount,
        currency: loan.currency,
        dueDate: loan.dueDate,
        status: LoanStatus.PENDING,
        lenderConfirmed: true,
        borrowerConfirmed: false,
        confirmedAt: null,
        createdById: loan.lenderId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<Loan> confirmLoan(
    int loanId,
    int userId,
    bool isConfirmed,
  ) async {
    final url = Uri.parse('http://localhost:8000/loans/$loanId/confirm');
    print('[LoanService] Confirming loan: POST $url');
    print('[LoanService] Request body: {"user_id": $userId, "confirmed": $isConfirmed}');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'accept': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'confirmed': isConfirmed,
        }),
      );

      print('[LoanService] Response status: ${response.statusCode}');
      print('[LoanService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final loan = Loan.fromJson(jsonDecode(response.body));
        print('[LoanService] Loan parsed successfully: ${loan.status}');
        return loan;
      } else {
        throw Exception('Failed to confirm loan: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('[LoanService] Error confirming loan: $e');
      rethrow;
    }
  }

  @override
  Future<Loan> updateLoanDueDate(int loanId, DateTime newDueDate) async {
    // Mock implementation
    return Future.delayed(
      const Duration(seconds: 1),
      () => Loan(
        id: loanId,
        lenderId: 2,
        borrowerId: 9,
        amount: 15.0,
        currency: Currency.USD,
        dueDate: newDueDate,
        status: LoanStatus.ACTIVE,
        lenderConfirmed: true,
        borrowerConfirmed: true,
        confirmedAt: DateTime.now(),
        createdById: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now(),
      ),
    );
  }


  // markLoanAsCompleted removed

  @override
  Future<void> deleteLoan(int loanId) async {
    // Mock implementation
    return Future.delayed(const Duration(seconds: 1));
  }

  @override
  Stream<List<Loan>> watchActiveLoans(int userId) {
    // Mock implementation
    return Stream.periodic(
      const Duration(seconds: 10),
      (_) => [
        Loan(
          id: 34,
          lenderId: 44,
          borrowerId: 64,
          amount: 1.0,
          currency: Currency.MAD,
          dueDate: DateTime.now().add(const Duration(days: 25)),
          status: LoanStatus.ACTIVE,
          lenderConfirmed: true,
          borrowerConfirmed: true,
          confirmedAt: null,
          createdById: 44,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
    );
  }
}
