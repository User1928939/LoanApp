import 'package:flutter/material.dart';
import '../models/loan.dart';
import '../services/service_locator.dart';
import '../theme.dart';
import '../routes.dart';
import '../services/UserSession.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  late TabController _tabController;
  bool _isLoading = false;
  int? _userId;
  List<Loan> _activeLoans = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  _tabController = TabController(length: 2, vsync: this);
  // Get userId from UserSession
  _userId = UserSession.id;
  _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _userId = UserSession.id;
      if (_userId != null) {
        // Fetch dashboard data from backend
        final response = await serviceLocator.loanService.getDashboardData(_userId!);
        
        // Get all loans from both lists
        _activeLoans = [
          ...(response['in_progress'] as List).map((json) => Loan.fromJson(json)),
          ...(response['closed'] as List).map((json) => Loan.fromJson(json))
        ];
        
        // Debug log to show loan statuses
        print('[Dashboard] Loaded loans:');
        for (var loan in _activeLoans) {
          print('Loan ${loan.id}: Status=${loan.status}, '
                'LenderConfirmed=${loan.lenderConfirmed}, '
                'BorrowerConfirmed=${loan.borrowerConfirmed}');
        }
        
        // Log counts for each status
        final pendingCount = _activeLoans.where((l) => l.status == LoanStatus.PENDING).length;
        final activeCount = _activeLoans.where((l) => l.status == LoanStatus.ACTIVE).length;
        print('[Dashboard] Loan counts - Pending: $pendingCount, Active: $activeCount');
      }
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      // Already on dashboard
    } else if (index == 1) {
      serviceLocator.navigationService.navigateTo(Routes.history);
    } else if (index == 2) {
      serviceLocator.navigationService.navigateTo(Routes.friends);
    } else if (index == 3) {
      serviceLocator.navigationService.navigateTo(Routes.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HedNiya'),
        backgroundColor: AppTheme.trustBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              serviceLocator.navigationService.navigateTo(Routes.notifications);
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              serviceLocator.navigationService.navigateTo(Routes.profile);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending Loans'),
            Tab(text: 'Active Loans'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Pending Loans tab
                _buildLoansList(
                  _activeLoans.where((loan) => loan.status == LoanStatus.PENDING).toList(),
                  isActive: false,
                ),
                // Active Loans tab
                _buildLoansList(
                  _activeLoans.where((loan) => loan.status == LoanStatus.ACTIVE).toList(),
                  isActive: true,
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final user = _userId;
          // Use navigationService for navigation and result
          final result = await serviceLocator.navigationService.navigateTo(
            Routes.createLoan,
            arguments: user,
          );
          if (result == true) {
            _loadData();
          }
        },
        backgroundColor: AppTheme.trustBlue,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: AppTheme.trustBlue,
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(
                icon: Icon(Icons.history), label: 'History'),
            BottomNavigationBarItem(
                icon: Icon(Icons.group), label: 'Friends'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person), label: 'Profile'),
                
          ],
        ),
      ),
    );
  }

  Widget _buildLoansList(List<Loan> loans, {required bool isActive}) {
    if (loans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.account_balance_wallet : Icons.history,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isActive ? 'No active loans' : 'No pending loans',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Show most recent loan at the top
    final reversedLoans = loans.reversed.toList();
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: reversedLoans.length,
        itemBuilder: (context, index) {
          final loan = reversedLoans[index];
          final isLender = loan.lenderId == _userId;
          final isPending = loan.status == LoanStatus.PENDING;
          final isConfirmed = loan.lenderConfirmed && loan.borrowerConfirmed;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isLender
                        ? const Color.fromARGB(255, 3, 184, 18)
                        : const Color.fromARGB(255, 222, 6, 6),
                    child: Icon(
                      isLender ? Icons.arrow_upward : Icons.arrow_downward,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    isLender ? 'Lending' : 'Borrowing',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Due: ${_formatDate(loan.dueDate)}\nStatus: ${isPending ? "Pending" : isConfirmed ? "Confirmed" : "In Progress"}'),
                  trailing: Text(
                    '\ ${loan.amount.toStringAsFixed(2)} MAD',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  onTap: () {
                    serviceLocator.navigationService.navigateTo(
                      Routes.loanDetails,
                      arguments: loan,
                    );
                  },
                ),
                if (loan.status == LoanStatus.PENDING && 
                    ((isLender && !loan.lenderConfirmed) || (!isLender && !loan.borrowerConfirmed)))
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Colors.green),
                            ),
                            onPressed: () async {
                              try {
                                final updatedLoan = await serviceLocator.loanService.confirmLoan(
                                  loan.id,
                                  _userId!,
                                  true,
                                );
                                if (!mounted) return;
                                
                                String message = 'Loan confirmed successfully';
                                if (updatedLoan.status == LoanStatus.ACTIVE) {
                                  message = 'Loan activated! Both parties have confirmed.';
                                } else {
                                  message = 'Your confirmation has been recorded. Waiting for other party.';
                                }
                                
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(message)),
                                );
                                await _loadData(); // Refresh the list
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error confirming loan: $e')),
                                );
                                print('Error confirming loan: $e'); // Add debug print
                              }
                            },
                            child: const Text('Accept', style: TextStyle(color: Colors.green)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Colors.red),
                            ),
                            onPressed: () async {
                              try {
                                await serviceLocator.loanService.confirmLoan(
                                  loan.id,
                                  _userId!,
                                  false,
                                );
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Loan rejected')),
                                );
                                await _loadData(); // Refresh the list
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error rejecting loan: $e')),
                                );
                                print('Error rejecting loan: $e'); // Add debug print
                              }
                            },
                            child: const Text('Reject', style: TextStyle(color: Colors.red)),
                          ),
                        ),
                      ],
                    ),
                  )
                  ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
