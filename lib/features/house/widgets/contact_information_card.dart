import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactInformationCard extends StatelessWidget {
  final String number;
  final String? name;
  final String? companyName;
  final String? phoneNumber;

  const ContactInformationCard({
    super.key,
    required this.number,
    this.name,
    this.companyName,
    this.phoneNumber,
  });

  Future<void> _saveContact(BuildContext context) async {
    final permission = await FlutterContacts.requestPermission();

    if (!permission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact permission denied')),
      );
      return;
    }

    var contactNameAttrs = <String>{};
    if (number.isNotEmpty) {
      contactNameAttrs.add(number!);
    }
    if (name != null && name!.isNotEmpty) {
      contactNameAttrs.add(name!);
    }
    if (companyName != null && companyName!.isNotEmpty) {
      contactNameAttrs.add(companyName!);
    }

    final contact = Contact()
      ..name.first = contactNameAttrs.join(" - ")
      ..phones = phoneNumber != null ? [Phone(phoneNumber!)] : [];

    try {
      await FlutterContacts.insertContact(contact);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save contact: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(name ?? 'No Name'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (companyName != null) Text(companyName!),
            if (phoneNumber != null) Text(phoneNumber!),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (phoneNumber != null)
              IconButton(
                icon: const Icon(Icons.chat, color: Colors.teal),
                onPressed: () {
                  final phone = phoneNumber!;
                  final intlPhone = phone.startsWith('0')
                      ? '62${phone.substring(1)}'
                      : phone;
                  final whatsappUrl =
                      'https://wa.me/$intlPhone?text=Halo%20apakah%20ini%20cp%20nomor%20yg%20punya%20rumah%20%3F%20Kalau%20iya%20harganya%20berapa%20ya%20%3F%20Terima%20kasih';
                  launchUrl(Uri.parse(whatsappUrl));
                },
              ),
            IconButton(
              icon: const Icon(Icons.save_alt, color: Colors.green),
              tooltip: 'Save Contact',
              onPressed: () => _saveContact(context),
            ),
          ],
        ),
      ),
    );
  }
}
