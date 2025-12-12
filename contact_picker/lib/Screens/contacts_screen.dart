library contact_picker;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactPicker extends StatefulWidget {
  // ========= Customizable UI Styles ==========
  final InputDecoration? searchDecoration;
  final TextStyle? alphabetTextStyle;
  final TextStyle? contactNameStyle;
  final TextStyle? contactNumberStyle;

  // Replace entire tile with your own widget
  final Widget Function(Contact contact)? contactTileBuilder;

  // Custom dropdown builder
  final Widget? filterWidget;

  // Loading Widget
  final Widget? loadingWidget;

  const ContactPicker({
    this.searchDecoration,
    this.alphabetTextStyle,
    this.contactNameStyle,
    this.contactNumberStyle,
    this.contactTileBuilder,
    this.filterWidget,
    this.loadingWidget,
    super.key,
  });

  @override
  State<ContactPicker> createState() => _ContactPickerState();
}

class _ContactPickerState extends State<ContactPicker> {
  TextEditingController searchController = TextEditingController();

  List<Contact> allContacts = [];
  List<Contact> filteredContacts = [];
  List<GlobalKey> tileKeys = [];
  bool isLoading = true;

  Timer? _debounce;

  final List<String> alphabets =
  List.generate(26, (i) => String.fromCharCode(65 + i));

  String selectedFilter = "All";

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
    var status = await Permission.contacts.status;
    if (!status.isGranted) status = await Permission.contacts.request();

    if (!status.isGranted) {
      setState(() => isLoading = false);
      return;
    }

    final contacts = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: true,
    );

    contacts.sort((a, b) => a.displayName.compareTo(b.displayName));

    tileKeys = List.generate(contacts.length, (_) => GlobalKey());

    setState(() {
      allContacts = contacts;
      filteredContacts = contacts;
      isLoading = false;
    });
  }

  // FAST SEARCH
  void applySearch(String query) {
    final filtered = allContacts.where((contact) {
      final name = contact.displayName.toLowerCase();
      return name.contains(query.toLowerCase());
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

  // FILTERING
  void applyFilter(String filter) {
    List<Contact> temp = allContacts;

    if (filter == "With Number") {
      temp = temp.where((c) => c.phones.isNotEmpty).toList();
    } else if (filter == "With Email") {
      temp = temp.where((c) => c.emails.isNotEmpty).toList();
    } else if (filter == "With Photo") {
      temp = temp.where((c) => c.photoOrThumbnail != null).toList();
    }

    final searched = temp.where((c) {
      final name = c.displayName.toLowerCase();
      final text = searchController.text.toLowerCase();
      return name.contains(text);
    }).toList();

    setState(() => filteredContacts = searched);
  }

  // ALPHABET FILTER
  void scrollToLetter(String letter) {
    List<Contact> result = allContacts.where((c) {
      return c.displayName.toUpperCase().startsWith(letter);
    }).toList();

    if (result.isEmpty) return;

    setState(() => filteredContacts = result);
  }

  // DEFAULT CONTACT TILE
  Widget defaultTile(Contact c, int index) {
    final phone =
    c.phones.isNotEmpty ? c.phones.first.number : "No Number";

    return ListTile(
      key: tileKeys[index],
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        backgroundImage:
        c.photoOrThumbnail != null ? MemoryImage(c.photoOrThumbnail!) : null,
        child: c.photoOrThumbnail == null
            ? Text(
          c.displayName.isNotEmpty
              ? c.displayName[0].toUpperCase()
              : "?",
          style: widget.contactNameStyle ??
              TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        )
            : null,
      ),
      title: Text(
        c.displayName,
        style: widget.contactNameStyle ??
            TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        phone,
        style: widget.contactNumberStyle ??
            TextStyle(fontSize: 12, color: Colors.grey),
      ),
      // onTap: () => Navigator.pop(context, c),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? widget.loadingWidget ?? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // FILTER (Developer can replace)
          widget.filterWidget ??
              DropdownButtonFormField(
                value: selectedFilter,
                items: [
                  "All",
                  "With Number",
                  "With Email",
                  "With Photo"
                ]
                    .map((x) =>
                    DropdownMenuItem(value: x, child: Text(x)))
                    .toList(),
                onChanged: (value) {
                  selectedFilter = value!;
                  applyFilter(value);
                },
              ),

          SizedBox(height: 10),

          // SEARCH
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: widget.searchDecoration ??
                InputDecoration(
                  hintText: "Search...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
          ),

          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  itemCount: filteredContacts.length,
                  itemBuilder: (context, index) {
                    final c = filteredContacts[index];

                    return widget.contactTileBuilder != null
                        ? widget.contactTileBuilder!(c)
                        : defaultTile(c, index);
                  },
                ),

                // A-Z SCROLLER (Customizable style)
                Positioned(
                  right: 0,
                  top: 20,
                  bottom: 20,
                  child: SingleChildScrollView(
                    child: Column(
                      children: alphabets.map((letter) {
                        return GestureDetector(
                          onTap: () => scrollToLetter(letter),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 2),
                            child: Text(
                              letter,
                              style: widget.alphabetTextStyle ??
                                  TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
