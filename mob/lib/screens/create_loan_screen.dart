import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:loadn_app/models/Friend.dart';
import '../models/loan.dart';
import '../services/service_locator.dart';
import '../theme.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CreateLoanScreen extends StatefulWidget {
  final int userId; // 👈 add this
  const CreateLoanScreen({super.key, required this.userId});

  @override
  State<CreateLoanScreen> createState() => _CreateLoanScreenState();
}

class _CreateLoanScreenState extends State<CreateLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  bool _isLending = true;
  bool _isLoading = false;
  bool _isContactPickerOpen = false;
  int? _selectedFriendId; // to store the chosen friend’s ID

  @override
  void dispose() {
    _amountController.dispose();
    _contactController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.trustBlue,
        foregroundColor: Colors.white,
        title: const Text('Create New Loan'),
      ),
      backgroundColor: AppTheme.background,
      body: _isContactPickerOpen
          ? _buildContactPicker()
          : _buildLoanForm(widget.userId),
    );
  }

  Widget _buildLoanForm(int userId) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Loan type selector
            const Text('Loan Type', style: AppTheme.subheadingStyle),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _isLending = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isLending ? Colors.black : Colors.white,
                      foregroundColor:
                          _isLending ? Colors.white : Colors.grey[700],
                    ),
                    child: const Text('Lending'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _isLending = false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          !_isLending ? Colors.black : Colors.white,
                      foregroundColor:
                          !_isLending ? Colors.white : Colors.grey[700],
                    ),
                    child: const Text('Borrowing'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Amount field
            const Text('Amount', style: AppTheme.subheadingStyle),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: AppTheme.inputDecoration('0.00').copyWith(
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: Text(
                    'MAD',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 0, minHeight: 0),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Contact field
            const Text('Contact', style: AppTheme.subheadingStyle),
            const SizedBox(height: 8),
            TextFormField(
              controller: _contactController,
              readOnly: true,
              decoration:
                  AppTheme.inputDecoration('Select a contact').copyWith(
                suffixIcon: IconButton(
                  icon: const Icon(Icons.person_search),
                  onPressed: () {
                    setState(() {
                      _isContactPickerOpen = true;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a contact';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Due date field
            const Text('Due Date', style: AppTheme.subheadingStyle),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDueDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('MMM dd, yyyy').format(_dueDate),
                        style: AppTheme.bodyStyle),
                    const Icon(Icons.calendar_today, color: AppTheme.primary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Note field
            const Text('Note (optional)', style: AppTheme.subheadingStyle),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              decoration:
                  AppTheme.inputDecoration('Add a note about this loan'),
            ),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitLoan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isLending
                            ? 'Send Loan'
                            : 'Request Loan',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactPicker() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search contacts',
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<UserFriend>>(
            future: _loadFriends(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No friends found'));
              }

              final friends = snapshot.data!;
              return ListView.builder(
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final friend = friends[index];
                  return ListTile(
                    leading: CircleAvatar(
                        child: Text(friend.email[0].toUpperCase())),
                    title: Text(friend.email),
                    subtitle: Text("ID: ${friend.id}"),
                    onTap: () {
                      setState(() {
                        _contactController.text = friend.email;
                        _selectedFriendId = friend.id;
                        _isContactPickerOpen = false;
                      });
                    },
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _isContactPickerOpen = false;
                });
              },
              child: const Text('CANCEL'),
            ),
          ),
        ),
      ],
    );
  }

  Future<List<UserFriend>> _loadFriends() async {
    final response = await http.get(
      Uri.parse("http://127.0.0.1:8000/users/${widget.userId}/friends"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List raw = body["friends"] ?? [];
      return raw.map((f) => UserFriend.fromJson(f)).toList();
    } else {
      throw Exception("Failed to load friends: ${response.body}");
    }
  }

  Future<void> _selectDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (pickedDate != null && pickedDate != _dueDate) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }

  Future<void> _submitLoan() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      print('[CreateLoanScreen] Send Loan button pressed');
      try {
        final amount = double.parse(_amountController.text);
        final lenderId = _isLending ? widget.userId : _selectedFriendId ?? 0;
        final borrowerId = _isLending ? _selectedFriendId ?? 0 : widget.userId;
        final currency = 'MAD'; // or get from UI
        final dueDate = _dueDate.toIso8601String().split('T').first;
        print('[CreateLoanScreen] Calling createLoanApi with: lenderId=$lenderId, borrowerId=$borrowerId, amount=$amount, currency=$currency, dueDate=$dueDate');
        await serviceLocator.loanService.createLoanApi(
          lenderId: lenderId,
          borrowerId: borrowerId,
          amount: amount,
          currency: currency,
          dueDate: dueDate,
          createdById: widget.userId,  // Current user is creating the loan
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isLending
                  ? 'Loan request sent successfully'
                  : 'Loan request submitted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          serviceLocator.navigationService.goBackWithResult(true);
        }
      } catch (e, stack) {
        print('[CreateLoanScreen] Error: $e');
        print('[CreateLoanScreen] Stacktrace: $stack');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
