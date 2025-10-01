
import 'package:flutter/material.dart';
import '../models/loan.dart';
import '../services/service_locator.dart';
import '../theme.dart';
import '../services/UserSession.dart';
import '../services/user_service.dart';

class LoanDetailsScreen extends StatefulWidget {
  final Loan loan;
  const LoanDetailsScreen({super.key, required this.loan});
  @override
  State<LoanDetailsScreen> createState() => _LoanDetailsScreenState();
}

class _LoanDetailsScreenState extends State<LoanDetailsScreen> {
  late Loan _loan;
  late int _userId;
  late bool _isLender;
  String? _lenderEmail;
  String? _borrowerEmail;

  @override
  void initState() {
    super.initState();
    _loan = widget.loan;
    _userId = UserSession.id ?? 0;
    _isLender = _loan.lenderId == _userId;
    _fetchEmails();
  }

  Future<void> _fetchEmails() async {
    final userService = ApiUserService();
    try {
      final lenderProfile = await userService.getUserProfile(_loan.lenderId);
      final borrowerProfile = await userService.getUserProfile(_loan.borrowerId);
      setState(() {
        _lenderEmail = lenderProfile.email;
        _borrowerEmail = borrowerProfile.email;
      });
    } catch (e) {
      debugPrint('Error fetching user emails: $e');
    }
  }

  Future<void> _confirmLoan() async {
    try {
      await serviceLocator.loanService.confirmLoan(_loan.id, _userId, true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loan confirmed successfully')),
        );
      }
    } catch (e) {
      debugPrint('Error confirming loan: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error confirming loan: $e')),
        );
      }
    }
  }

  Future<void> _markAsCompleted() async {
    try {
      await serviceLocator.loanService.deleteLoan(_loan.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loan marked as completed')),
        );
      }
    } catch (e) {
      debugPrint('Error marking loan as completed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error marking loan as completed: $e')),
        );
      }
    }
  }

  Future<void> _requestDueDateChange() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _loan.dueDate.add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null && picked != _loan.dueDate) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Updating due date...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      try {
        await serviceLocator.loanService.updateLoanDueDate(_loan.id, picked);
        final otherUserId = _isLender ? _loan.borrowerId : _loan.lenderId;
        await serviceLocator.notificationService.sendDueDateReminderNotification(otherUserId, _loan.id, picked);
        
        if (mounted) {
          Navigator.of(context).pop(); // Dismiss loading dialog
          
          // Show success animation
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Due Date Updated!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Notification sent successfully',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );

          // Auto-dismiss success dialog after 2 seconds
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
        }
      } catch (e) {
        debugPrint('Error updating due date: $e');
        if (mounted) {
          Navigator.of(context).pop(); // Dismiss loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating due date: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildLoanStatusIndicator() {
    Color color;
    IconData icon;
    String text;
    if (_loan.status == LoanStatus.CLOSED) {
      color = AppTheme.success;
      icon = Icons.check_circle;
      text = 'Completed';
    } else if (_loan.status == LoanStatus.ACTIVE) {
      if (_loan.dueDate.isBefore(DateTime.now())) {
        color = AppTheme.error;
        icon = Icons.warning;
        text = 'Overdue';
      } else {
        color = const Color.fromARGB(255, 247, 79, 79);
        icon = Icons.timer;
        text = 'Active';
      }
    } else if (_loan.status == LoanStatus.PENDING) {
      color = AppTheme.warning;
      icon = Icons.hourglass_empty;
      text = 'Pending Confirmation';
    } else {
      color = AppTheme.textSecondary;
      icon = Icons.help;
      text = 'Unknown';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final daysRemaining = _loan.dueDate.difference(DateTime.now()).inDays;
    final isOverdue = daysRemaining < 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Details'),
        backgroundColor: AppTheme.trustBlue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: AppTheme.card,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: _isLender ? const Color.fromARGB(255, 3, 184, 18) : const Color.fromARGB(255, 222, 6, 6),
                      child: Icon(_isLender ? Icons.arrow_upward : Icons.arrow_downward, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isLender ? 'Lending' : 'Borrowing',
                            style: AppTheme.headingStyle.copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Amount: ${_loan.amount.toStringAsFixed(2)} MAD',
                            style: AppTheme.bodyStyle.copyWith(fontSize: 15),
                          ),
                          const SizedBox(height: 8),
                          _buildLoanStatusIndicator(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: AppTheme.card,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_isLender ? 'Borrower Email' : 'Lender Email', style: AppTheme.subheadingStyle),
                    const SizedBox(height: 8),
                    Text(_isLender ? (_borrowerEmail ?? '...') : (_lenderEmail ?? '...'), style: AppTheme.bodyStyle),
                    const Divider(height: 32, color: AppTheme.divider),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: const Color.fromARGB(255, 0, 0, 0)),
                        const SizedBox(width: 8),
                        Text(isOverdue ? 'Overdue by' : 'Due in', style: AppTheme.subheadingStyle),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(isOverdue ? '${daysRemaining.abs()} days overdue' : '$daysRemaining days', style: AppTheme.bodyStyle.copyWith(color: isOverdue ? AppTheme.error : AppTheme.textPrimary)),
                        const SizedBox(width: 4),
                        Text('(${_loan.dueDate.month}/${_loan.dueDate.day}/${_loan.dueDate.year})', style: AppTheme.captionStyle),
                      ],
                    ),
                    if (_loan.description != null && _loan.description!.isNotEmpty) ...[
                      const Divider(height: 32, color: AppTheme.divider),
                      Row(
                        children: [
                          Icon(Icons.description, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          Text('Description', style: AppTheme.subheadingStyle),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(_loan.description!, style: AppTheme.bodyStyle),
                    ],
                    if (_loan.hederaTransactionId != null) ...[
                      const Divider(height: 32, color: AppTheme.divider),
                      
                      
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_loan.status == LoanStatus.PENDING) ...[
              Card(
                color: AppTheme.card,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Confirmation Status', style: AppTheme.subheadingStyle),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Lender confirmed:', style: AppTheme.bodyStyle),
                          Icon(_loan.lenderConfirmed ? Icons.check_circle : Icons.radio_button_unchecked, color: _loan.lenderConfirmed ? AppTheme.success : AppTheme.textSecondary),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Borrower confirmed:', style: AppTheme.bodyStyle),
                          Icon(_loan.borrowerConfirmed ? Icons.check_circle : Icons.radio_button_unchecked, color: _loan.borrowerConfirmed ? AppTheme.success : AppTheme.textSecondary),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_loan.status == LoanStatus.PENDING && !(_isLender ? _loan.lenderConfirmed : _loan.borrowerConfirmed))
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirmLoan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  child: const Text('Confirm Loan',style: TextStyle(color: Colors.green)),
                  // style: AppTheme.primaryButtonStyle, --- IGNORE ---
                  // child: const Text('Confirm Loan'), --- IGNORE ---  
                ),
              ),
            if (_loan.status == LoanStatus.ACTIVE) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _markAsCompleted,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  child: Text(_isLender ? 'Mark as Repaid' : 'Mark as Paid'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _requestDueDateChange,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Request Due Date Change'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
