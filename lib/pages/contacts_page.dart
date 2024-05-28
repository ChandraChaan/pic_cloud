import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    if (await requestContactsPermission(context)) {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      setState(() {
        _contacts = contacts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: _contacts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              shrinkWrap: true,
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                return ListTile(
                  title: Text(contact.displayName ?? ''),
                  subtitle: Text(contact.phones.isNotEmpty
                      ? contact.phones.first.number
                      : 'No phone number'),
                );
              },
            ),
    );
  }
}

Future<bool> requestContactsPermission(BuildContext context) async {
  var status = await Permission.contacts.status;
  if (status.isGranted) {
    return true;
  } else {
    var result = await Permission.contacts.request();
    if (result.isGranted) {
      return true;
    } else {
      await _handlePermissionDenied(context, result);
      return false;
    }
  }
}

Future<void> _handlePermissionDenied(
    BuildContext context, PermissionStatus status) async {
  if (status.isPermanentlyDenied) {
    await _showErrorDialog(context, "Please allow permissions from settings")
        .whenComplete(() => openAppSettings());
  } else {
    await _showErrorDialog(context, "Permissions are required to proceed.");
  }
}

Future<void> _showErrorDialog(BuildContext context, String message) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Permission Required'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(message),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
