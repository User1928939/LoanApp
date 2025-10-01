class Contact {
  final String id;
  final String name;
  final String phoneNumber;
  final String? email;
  final String? photoUrl;
  final bool isAppUser;

  Contact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    this.photoUrl,
    this.isAppUser = false,
  });
}

abstract class ContactsService {
  Future<List<Contact>> getContacts();
  Future<List<Contact>> searchContacts(String query);
  Future<Contact?> getContactByPhone(String phoneNumber);
  Future<Contact?> getContactById(String contactId);
}

class PhoneContactsService implements ContactsService {
  // This would be implemented with device contacts API
  // For now, we'll provide mock implementations

  @override
  Future<List<Contact>> getContacts() async {
    // Mock implementation
    return Future.delayed(
      const Duration(seconds: 1),
      () => [
        Contact(
          id: 'contact1',
          name: 'Alice Johnson',
          phoneNumber: '+1234567890',
          email: 'alice@example.com',
          isAppUser: true,
        ),
        Contact(
          id: 'contact2',
          name: 'Bob Smith',
          phoneNumber: '+0987654321',
          email: 'bob@example.com',
          isAppUser: false,
        ),
        Contact(
          id: 'contact3',
          name: 'Carol Williams',
          phoneNumber: '+1122334455',
          email: 'carol@example.com',
          isAppUser: true,
        ),
      ],
    );
  }

  @override
  Future<List<Contact>> searchContacts(String query) async {
    // Mock implementation
    return Future.delayed(
      const Duration(seconds: 1),
      () => [
        Contact(
          id: 'contact1',
          name: 'Alice Johnson',
          phoneNumber: '+1234567890',
          email: 'alice@example.com',
          isAppUser: true,
        ),
      ],
    );
  }

  @override
  Future<Contact?> getContactByPhone(String phoneNumber) async {
    // Mock implementation
    return Future.delayed(
      const Duration(seconds: 1),
      () => Contact(
        id: 'contact1',
        name: 'Alice Johnson',
        phoneNumber: phoneNumber,
        email: 'alice@example.com',
        isAppUser: true,
      ),
    );
  }

  @override
  Future<Contact?> getContactById(String contactId) async {
    // Mock implementation
    return Future.delayed(
      const Duration(seconds: 1),
      () => Contact(
        id: contactId,
        name: 'Alice Johnson',
        phoneNumber: '+1234567890',
        email: 'alice@example.com',
        isAppUser: true,
      ),
    );
  }
}
