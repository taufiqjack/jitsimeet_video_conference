import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jitsi_meet/jitsi_meet.dart';

class Dashboartd extends StatefulWidget {
  const Dashboartd({Key? key}) : super(key: key);

  @override
  _DashboartdState createState() => _DashboartdState();
}

class _DashboartdState extends State<Dashboartd> {
  bool _isSound = true;
  bool _isCamera = true;

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
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _namaController,
                decoration: const InputDecoration(
                  label: Text('Nama Kamu'),
                  border: OutlineInputBorder(),
                ),
                focusNode: _nameCode,
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _codeController,
                decoration: const InputDecoration(
                  label: Text('Meeting ID'),
                  border: OutlineInputBorder(),
                ),
                focusNode: _codeNode,
              ),
              const SizedBox(
                height: 10,
              ),
              CheckboxListTile(
                title: const Text('Sound'),
                value: _isSound,
                onChanged: (checkstat) {
                  setState(() {
                    _isSound = checkstat!;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Camera'),
                value: _isCamera,
                onChanged: (checkstat) {
                  setState(() {
                    _isCamera = checkstat!;
                  });
                },
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () {
                      _joinRoom();
                    },
                    child: const Text(
                      'Join',
                    )),
              ),
            ],
          )),
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
        ..audioMuted = !_isSound
        ..videoMuted = !_isCamera;

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
}
