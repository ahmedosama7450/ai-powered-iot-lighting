
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:avatar_glow/avatar_glow.dart';
class Voice_App_ extends StatefulWidget {


  @override
  State<Voice_App_> createState() => _Voice_App_();
}

class _Voice_App_ extends State<Voice_App_> {
stt.SpeechToText _speech=stt.SpeechToText();
bool _isListening =false;
String _text ='press the button and talk';
//double Con =1.0;

  @override
  void initState(){
    super.initState();
    _speech=stt.SpeechToText();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 10, 24, 46),
        title: Text(
          "Voice App",
          style: TextStyle(
              color: Colors.white
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: SingleChildScrollView(
               // reverse: true,
                child: Container(
                  padding: EdgeInsets.fromLTRB(30, 30, 30, 30),
                  child: Text(
                     _text,
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.black,
                      fontWeight: FontWeight.w400
                    ),
                  ),
                ),
              )
          ),
          Container(
            padding: EdgeInsets.all(15),
            child: Row(
              children: [
                Expanded(
                  child: AvatarGlow(
                      animate: _isListening,
                    glowColor: Colors.red,
                    repeat: true,
                    child: IconButton(
                      icon: Icon(_isListening?Icons.mic:Icons.mic_none),
                      onPressed: (){
                        listen();
                      },
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send
                  ),
                  onPressed: (){
                    Navigator.of(context).pop(_text);
                  },
                ),

              ],
            ),
          ),
        ],
      )

    );
  }
  void listen() async{
    if(!_isListening){
      bool available = await _speech.initialize(
        // onStatus: (val)=>print('state $val'),
        // onError: (val)=>print('error $val'),
      );
      if(available){
        setState(() => _isListening=true);
          _speech.listen(
            onResult: (val)=>setState(() {
              _text =val.recognizedWords;

            }),
          );

      }
    }else{
      setState(() =>_isListening=false);
      _speech.stop();
    }
  }


}