import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: FlutterContactsExample());
  }
}

class FlutterContactsExample extends StatefulWidget {
  const FlutterContactsExample({super.key});

  @override
  State<FlutterContactsExample> createState() => _FlutterContactsExampleState();
}

class _FlutterContactsExampleState extends State<FlutterContactsExample> {
  List<Contact>? _contacts;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() {
    FlutterContacts.addListener(() => _fetchContacts());
    _fetchContacts();
  }

  Future _fetchContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      setState(() => _permissionDenied = true);
    } else {
      var contacts = await FlutterContacts.getContacts();
      setState(() => _contacts = contacts);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Own Contacts App')),
      body: _body(),
    );
  }

  Widget _body() {
    if (_permissionDenied) {
      return const Center(child: Text('Permission denied'));
    }
    if (_contacts == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      itemCount: _contacts!.length,
      itemBuilder:
          (context, i) => ListTile(
            title: Text(_contacts![i].displayName),
            onTap: () {
              FlutterContacts.getContact(_contacts![i].id).then((contact) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ContactPage(contact!)),
                );
              });
            },
          ),
    );
  }
}

class ContactPage extends StatelessWidget {
  final Contact contact;
  const ContactPage(this.contact, {super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(contact.displayName)),
    body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('First name: ${contact.name.first}'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Last name: ${contact.name.last}'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Phone number: ${contact.phones.isNotEmpty ? contact.phones.first.number : '(none)'}',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Email address: ${contact.emails.isNotEmpty ? contact.emails.first.address : '(none)'}',
            ),
          ),
        ],
      ),
    ),
  );
}
