import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:image_picker/image_picker.dart';

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
    if (await FlutterContacts.requestPermission()) {
      var contacts = await FlutterContacts.getContacts();
      setState(() => _contacts = contacts);
    } else {
      setState(() => _permissionDenied = true);
    }
  }

  void _addContact() async {
    final newContact = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddContactPage()),
    );
    if (newContact != null) {
      await newContact.insert();
      _fetchContacts();
    }
  }

  void _deleteContact(Contact contact) async {
    await contact.delete();
    _fetchContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Own Contacts App'),
        backgroundColor: Colors.blue,
      ),
      body: _body(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addContact,
        child: const Icon(Icons.contact_emergency_outlined),
      ),
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
                  MaterialPageRoute(
                    builder:
                        (_) => ContactPage(contact!, onDelete: _deleteContact),
                  ),
                );
              });
            },
          ),
    );
  }
}

class ContactPage extends StatelessWidget {
  final Contact contact;
  final Function(Contact) onDelete;

  const ContactPage(this.contact, {super.key, required this.onDelete});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(contact.displayName),
      actions: [
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            onDelete(contact);
            Navigator.pop(context);
          },
        ),
      ],
    ),
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

class AddContactPage extends StatefulWidget {
  @override
  _AddContactPageState createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final _formKey = GlobalKey<FormState>();
  String firstName = '';
  String lastName = '';
  String phoneNumber = '';
  String email = '';
  File? _image;

  Future _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (pickedImage != null) {
      setState(() => _image = File(pickedImage.path));
    }
  }

  void _saveContact() async {
    if (_formKey.currentState!.validate()) {
      final newContact =
          Contact()
            ..name.first = firstName
            ..name.last = lastName
            ..phones = [Phone(phoneNumber)]
            ..emails = email.isNotEmpty ? [Email(email)] : [];
      Navigator.pop(context, newContact);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Contact'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null ? const Icon(Icons.camera_alt) : null,
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
                onChanged: (value) => firstName = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Last Name'),
                onChanged: (value) => lastName = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
                onChanged: (value) => phoneNumber = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (value) => email = value,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveContact,
                child: const Text('Save Contact'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
