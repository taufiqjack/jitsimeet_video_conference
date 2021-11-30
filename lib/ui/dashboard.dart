import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jitsi_meet/jitsi_meet.dart';

class Dashboartd extends StatefulWidget {
  const Dashboartd({Key? key}) : super(key: key);

  @override
  _DashboartdState createState() => _DashboartdState();
}

class _DashboartdState extends State<Dashboartd> {
  final GlobalKey<FormState> _key = GlobalKey();
  bool _isSoundOn = true;
  bool _isCameraOn = true;

  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final FocusNode _codeNode = FocusNode();
  final FocusNode _nameCode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text('Video Conference'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
          child: SafeArea(
            child: Form(
                key: _key,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _namaController,
                      decoration: const InputDecoration(
                        label: Text('Nama Kamu'),
                        border: OutlineInputBorder(),
                      ),
                      focusNode: _nameCode,
                      validator: (value) {
                        if (value.toString().isEmpty) {
                          // return 'Nama tidak boleh kosong';
                          return _showToast();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        label: Text('Meeting ID'),
                        border: OutlineInputBorder(),
                      ),
                      focusNode: _codeNode,
                      validator: (value) {
                        if (value.toString().isEmpty) {
                          // return 'Meeting ID tidak boleh kosong';
                          return _showToast();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CheckboxListTile(
                      title: const Text('Mikrofon'),
                      value: _isSoundOn,
                      onChanged: (checkstat) {
                        setState(() {
                          _isSoundOn = checkstat!;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Kamera'),
                      value: _isCameraOn,
                      onChanged: (checkstat) {
                        setState(() {
                          _isCameraOn = checkstat!;
                        });
                      },
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (_key.currentState!.validate()) {
                                _joinRoom();
                              }
                            });
                          },
                          child: const Text(
                            'Join/Create',
                          )),
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }

  void _joinRoom() async {
    try {
      Map<FeatureFlagEnum, bool> featureFlags = {
        FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
        FeatureFlagEnum.INVITE_ENABLED: false
      };

      if (Platform.isAndroid) {
        featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
      } else if (Platform.isIOS) {
        featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
      }

      var options = JitsiMeetingOptions(room: _codeController.text)
        ..userDisplayName = _namaController.text
        ..audioMuted = !_isSoundOn
        ..videoMuted = !_isCameraOn;

      debugPrint('JitsiMeetingOptions : $options');

      await JitsiMeet.joinMeeting(options,
          listener: JitsiMeetingListener(onConferenceWillJoin: (message) {
            debugPrint('${options.room} will join with message : $message');
          }, onConferenceJoined: (message) {
            debugPrint('${options.room} joined with message : $message');
          }, onConferenceTerminated: (message) {
            debugPrint('${options.room} termninated with nessage : $message');
          }));
    } catch (error) {
      debugPrint('error : $error');
    }
  }

  _showToast() {
    Fluttertoast.showToast(
      msg: 'Form nama dan meeting ID wajib diisi',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      fontSize: 12,
    );
  }
}
