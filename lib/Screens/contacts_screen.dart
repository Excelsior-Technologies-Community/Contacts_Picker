import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  TextEditingController searchController = TextEditingController();

  List<Contact> allContacts = [];
  List<Contact> filteredContacts = [];
  List<GlobalKey> tileKeys = [];
  bool isLoading = true;

  // For Fast Search
  Timer? _debounce;

  // Alphabet List
  final List<String> alphabets = List.generate(
    26,
    (i) => String.fromCharCode(65 + i),
  );

  // Filter Options
  String selectedFilter = "All";

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
    var status = await Permission.contacts.status;

    if (!status.isGranted) {
      status = await Permission.contacts.request();
    }

    if (!status.isGranted) {
      setState(() => isLoading = false);
      return;
    }

    final contacts = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: true,
    );

    print("TOTAL CONTACTS: ${contacts.length}");
    print("Permission status: ${await Permission.contacts.status}");

    contacts.sort((a, b) => a.displayName.compareTo(b.displayName));

    tileKeys = List.generate(contacts.length, (_) => GlobalKey());

    setState(() {
      allContacts = contacts;
      filteredContacts = contacts;
      isLoading = false;
    });
  }

  // FAST SEARCH + DEBOUNCE

  void applySearch(String query) {
    final filtered = allContacts.where((contact) {
      final name = contact.displayName.toLowerCase();
      final number = contact.phones.isNotEmpty
          ? contact.phones.first.number.toLowerCase()
          : "";

      return name.contains(query.toLowerCase()) ||
          number.contains(query.toLowerCase());
    }).toList();

    setState(() => filteredContacts = filtered);
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 200), () {
      applySearch(query);
      applyFilter(selectedFilter);
    });
  }

  // FILTER FUNCTION

  void applyFilter(String filter) {
    List<Contact> temp = allContacts;

    if (filter == "With Number") {
      temp = temp.where((c) => c.phones.isNotEmpty).toList();
    } else if (filter == "With Email") {
      temp = temp.where((c) => c.emails.isNotEmpty).toList();
    } else if (filter == "With Photo") {
      temp = temp.where((c) => c.photoOrThumbnail != null).toList();
    }

    final searched = temp.where((contact) {
      final name = contact.displayName.toLowerCase();
      final search = searchController.text.toLowerCase();
      return name.contains(search);
    }).toList();

    setState(() {
      filteredContacts = searched;
    });
  }

  // FAST ALPHABET SCROLLER

  void scrollToLetter(String letter) {
    List<Contact> result = allContacts.where((c) {
      return c.displayName.toUpperCase().startsWith(letter);
    }).toList();

    if (result.isEmpty) return;

    setState(() {
      filteredContacts = result;
    });

    Future.delayed(Duration(milliseconds: 100), () {
      Scrollable.ensureVisible(
        tileKeys[0].currentContext!,
        duration: Duration(milliseconds: 200),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contacts", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // FILTER DROPDOWN
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField(
                          value: selectedFilter,
                          items:
                              ["All", "With Number", "With Email", "With Photo"]
                                  .map(
                                    (x) => DropdownMenuItem(
                                      value: x,
                                      child: Text(x),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            selectedFilter = value!;
                            applyFilter(value);
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  // SEARCH BAR
                  TextField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    decoration: InputDecoration(
                      hintText: "Search...",
                      prefixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

                  // CONTACT LIST + A-Z SCROLLER
                  Expanded(
                    child: Stack(
                      children: [
                        filteredContacts.isEmpty
                            ? Center(child: Text("No contacts found"))
                            : ListView.builder(
                                itemCount: filteredContacts.length,
                                itemBuilder: (context, index) {
                                  final c = filteredContacts[index];
                                  final phone = c.phones.isNotEmpty
                                      ? c.phones.first.number
                                      : "No Number";

                                  return ListTile(
                                    key: tileKeys[index],
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blue.shade100,
                                      backgroundImage:
                                          c.photoOrThumbnail != null
                                          ? MemoryImage(c.photoOrThumbnail!)
                                          : null,
                                      child: c.photoOrThumbnail == null
                                          ? Text(
                                              c.displayName.isNotEmpty
                                                  ? c.displayName[0]
                                                        .toUpperCase()
                                                  : "?",
                                              style: TextStyle(fontSize: 20),
                                            )
                                          : null,
                                    ),
                                    title: Text(c.displayName),
                                    subtitle: Text(phone),
                                    // onTap: () => Navigator.pop(context, c),
                                  );
                                },
                              ),

                        // FAST A–Z SCROLLER
                        Positioned(
                          right: 0,
                          top: 20,
                          bottom: 20,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: alphabets.map((letter) {
                                return GestureDetector(
                                  onTap: () => scrollToLetter(letter),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      letter,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
