# 📱Contacts Picker  
A fully customizable, fast, and feature-rich contact picker for Flutter with:

- 🔍 **Fast Search (Debounce + Optimized)**
- 🔤 **A–Z Alphabet Scroller**
- 🧩 **Customizable UI (Searchbar, Tiles, Dropdown, Alphabet Bar)**
- 🎨 **Fully override-able widgets with builder functions**
- ⚡ **High performance even with 5000+ contacts**
- 🧾 **Filters: All, With Number, With Email, With Photo**

---

## 🚀 Features

| Feature | Description |
|--------|-------------|
| 🔍 Fast Search | Debounce-based smooth search across 5k+ contacts |
| 🔤 Alphabet Scroll | WhatsApp-like quick jump to letters |
| 🧩 Customizable UI | Replace search bar, filter dropdown, tile UI, alphabet UI |
| 📱 Native Contacts | Fetch contacts using `flutter_contacts` |
| 🔐 Runtime Permissions | Handled automatically |
| 🎨 Theming | Provide your own styles & widgets |
| 🔧 Builder support | Create your own contact tile |

---
## demo video


https://github.com/user-attachments/assets/01679f45-ebe2-496d-883d-b48f0ba68040



## 📦 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  contact_picker:
    path:
      url: '.../contacts_picker/contact_picker'
```

Using GitHub (recommended during development)
```yaml
dependencies:
  contact_picker:
    git:
      url: https://github.com/YOUR_USERNAME/contact_picker.git
```

## ⚙️ Android Setup (Important)
Add permission to your AndroidManifest.xml:
```
<uses-permission android:name="android.permission.READ_CONTACTS" />
```
For Android 11+ (Recommended):
```
<queries>
    <intent>
        <action android:name="android.intent.action.PICK" />
        <data android:mimeType="vnd.android.cursor.dir/contact" />
    </intent>
</queries>
```

## 📘 Basic Usage
```
import 'package:flutter/material.dart';
import 'package:contact_picker/contact_picker.dart';

class ContactDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ContactPicker(),
    );
  }
}
```
## 🎨 Full Customization Example
```
ContactPicker(
  // ⭐ Custom Search Bar
  searchDecoration: InputDecoration(
    hintText: "Search Contacts...",
    prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),

  // ⭐ Custom Alphabet Style
  alphabetTextStyle: TextStyle(
    fontSize: 14,
    color: Colors.deepPurple,
    fontWeight: FontWeight.bold,
  ),

  // ⭐ Replace Filter Widget
  filterWidget: GestureDetector(
    onTap: () {
      // You can apply your own filter logic
      print("Custom filter tapped");
    },
    child: Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list, color: Colors.deepPurple),
          SizedBox(width: 10),
          Text("Filter", style: TextStyle(color: Colors.deepPurple)),
        ],
      ),
    ),
  ),

  // ⭐ Customize Name & Number Style
  contactNameStyle: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
  contactNumberStyle: TextStyle(
    fontSize: 12,
    color: Colors.grey,
  ),

  // ⭐ Replace Entire Tile
  contactTileBuilder: (contact) {
    final phone = contact.phones.isNotEmpty
        ? contact.phones.first.number
        : "No Number";

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.shade100,
          child: Text(
            contact.displayName[0].toUpperCase(),
            style: TextStyle(color: Colors.deepPurple),
          ),
        ),
        title: Text(contact.displayName),
        subtitle: Text(phone),
        onTap: () => Navigator.pop(context, contact),
      ),
    );
  },

  // ⭐ Custom Loader
  loadingWidget: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: Colors.deepPurple),
        SizedBox(height: 10),
        Text("Loading contacts..."),
      ],
    ),
  ),
)
```
## 📁 Folder Structure (Library)
```
contact_picker/
 ├── lib/
 │    ├── contact_picker.dart
 │    └── screens/
 │         └── contacts_picker.dart
 ├── pubspec.yaml
 ├── README.md
 ├── LICENSE
 └── CHANGELOG.md
```
## 📜 License
```
Copyright (c) 2025 Excelsior Technologies

Permission is hereby granted, free of charge, to any person obtaining a copy  
of this software and associated documentation files (the "Software"), to deal  
in the Software without restriction, including without limitation the rights  
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell  
copies of the Software, and to permit persons to whom the Software is  
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all  
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED **"AS IS"**, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
```
