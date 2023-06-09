import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'EspaceUser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'app_state.dart';

class ProfileForm extends StatefulWidget {
  const ProfileForm({Key? key}) : super(key: key);

  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  DateTime? _birthdate;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<ApplicationState>(context);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // If the user is not logged in, show a message or redirect to login page
      return const Text('You need to login first');
    }
    final currentUserId = user.uid;
    return SingleChildScrollView(
        child: Column(children: <Widget>[
      Form(
        key: _formKey,
        child: Column(
          children: [
            Text(
              'First Name',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your first name.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Last Name',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your last name.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Date of birth',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16.0),
            InkWell(
              onTap: () {
                DatePicker.showDatePicker(
                  context,
                  showTitleActions: true,
                  minTime: DateTime(1900),
                  maxTime: DateTime.now(),
                  onChanged: (date) {},
                  onConfirm: (date) {
                    setState(() {
                      _birthdate = date;
                    });
                  },
                  currentTime: _birthdate ?? DateTime.now(),
                  locale: LocaleType.en,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _birthdate == null
                          ? 'Birthdate'
                          : 'Birthdate: ${_birthdate!.day}/${_birthdate!.month}/${_birthdate!.year}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                final currentUserId = user!.uid;

                if (_formKey.currentState!.validate() && _birthdate != null) {
                  // Save the form data.
                  final firstName = _firstNameController.text;
                  final lastName = _lastNameController.text;
                  final birthDate = _birthdate!;

                  try {
                    await FirebaseFirestore.instance
                        .collection('UserProfile')
                        .doc(currentUserId)
                        .set({
                      'firstName': firstName,
                      'lastName': lastName,
                      'birthDate': birthDate,
                      'userId': currentUserId,
                    });

                    print('User profile updated successfully!');
                    context.push('/espace-user/${_firstNameController.text}');

                    //context.push('/espace-user');
                  } catch (error) {
                    print('Failed to update user profile: $error');
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      )
    ]));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}
