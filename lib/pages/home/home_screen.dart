// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:waleed_videos/pages/video/video_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _loading = false;

  _submitCode(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });
      try {
        var data = await FirebaseFirestore.instance
            .collection('codes')
            .doc(_codeController.text)
            .get();
        if (data.exists) {
          setState(() {
            _loading = false;
          });
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => VideoScreen(url: data['url']),
            ),
          );
        } else {
          setState(() {
            _loading = false;
          });
          log('code not found');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('code not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } on FirebaseException catch (e) {
        setState(() {
          _loading = false;
        });
        log(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Code Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _codeController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Code must not be empty';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  label: const Text('Enter Code'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).errorColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: () {
                    _submitCode(context);
                  },
                  child: const Text('Submit'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
