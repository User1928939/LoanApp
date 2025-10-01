import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme.dart';
import '../models/Friend.dart';  // Correct import for UserFriend model

class FriendsScreen extends StatefulWidget {
  final int userId;

  const FriendsScreen({super.key, required this.userId});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {

  Future<void> _fetchFriends() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await http.get(
        Uri.parse("http://127.0.0.1:8000/users/${widget.userId}/friends"),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List rawFriends = body["friends"] ?? [];
        setState(() {
          _friends = rawFriends.map((f) => UserFriend.fromJson(f)).toList();
        });
      } else {
        setState(() {
          _error = "Failed: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _error = "Error: $e";
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addFriendDialog() async {
    final controller = TextEditingController();
    final friendEmail = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Add Friend"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Enter friend's email"),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text("Add"),
            ),
          ],
        );
      },
    );

    if (friendEmail != null && friendEmail.isNotEmpty) {
      await _addFriend(friendEmail);
    }
  }

  Future<void> _addFriend(String email) async {
    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/users/${widget.userId}/friends/email"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Friend added!"), backgroundColor: Colors.green),
        );
        _fetchFriends();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${response.body}"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }
  List<UserFriend> _friends = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchFriends();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.trustBlue,
        foregroundColor: Colors.white,
        title: const Text("Friends"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _friends.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.group_off, size: 80, color: AppTheme.textSecondary),
                          const SizedBox(height: 16),
                          Text("You have no friends yet.", style: AppTheme.bodyStyle),
                          const SizedBox(height: 16),
                          
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchFriends,
                      child: ListView.builder(
                        itemCount: _friends.length,
                        itemBuilder: (context, i) {
                          final f = _friends[i];
                          return Dismissible(
                            key: Key(f.email),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              return await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Remove Friend"),
                                    content: Text("Are you sure you want to remove ${f.email} from your friends?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text("CANCEL"),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: const Text("REMOVE"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            onDismissed: (direction) async {
                              try {
                                final response = await http.delete(
                                  Uri.parse("http://127.0.0.1:8000/users/${widget.userId}/friends/${f.id}"),
                                  headers: {"Content-Type": "application/json"},
                                );

                                if (response.statusCode == 200) {
                                  setState(() {
                                    _friends.remove(f);
                                  });
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("${f.email} has been removed from your friends"),
                                        backgroundColor: Colors.green,
                                        action: SnackBarAction(
                                          label: 'UNDO',
                                          textColor: Colors.white,
                                          onPressed: () {
                                            _addFriend(f.email);
                                          },
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Failed to remove friend"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Error removing friend: $e"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            background: Container(
                              color: Colors.red,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              alignment: Alignment.centerRight,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(Icons.delete, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    "Remove Friend",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            child: Card(
                              color: AppTheme.card,
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                child: Row(
                                  children: [
                                    const Icon(Icons.person, color: Colors.black),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        f.email.isNotEmpty ? f.email : '-',
                                        style: AppTheme.bodyStyle.copyWith(fontSize: 16),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF222B45), // subtle dark gray
        foregroundColor: Colors.white,
        onPressed: _addFriendDialog,
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
