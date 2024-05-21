
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';
import 'Start_Page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:wakelock/wakelock.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Wakelock.enable();
  runApp( MyApp());
}



class MyApp extends StatelessWidget {
  static List<Order> Data =[];
  static int Cur_state =0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:  _app2(),
    );
  }
}

class _app2  extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return app();
  }

}
class app extends State<_app2>{
  String ip="";

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 250,
                  child: TextField(
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight:FontWeight.bold
                    ),
                    decoration: InputDecoration(
                      labelText: "ip server: ",
                      labelStyle: TextStyle(
                          fontSize: 20,
                          fontWeight:FontWeight.bold
                      ),
                      border: OutlineInputBorder(
        
                          borderRadius: BorderRadius.circular(20)
                      ),
                    ),
                    onChanged: (value){
                      ip=value;
                    },
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                    child: Text(
                        "Done",
                        style: TextStyle(fontSize: 18)
                    ),
                    style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: Colors.red)
                            )
                        )
                    ),
                    onPressed: (){
                      if(ip.length!=0){
                        IO.Socket socket = IO.io('$ip', <String, dynamic>{
                          'transports': ['websocket'],
                          'autoConnect': false,
                        });
                        socket.connect();
        
        
                        socket.on("data",(data) {
                          print("helllllllllllo");
                          MyApp.Data =[];
                          MyApp.Cur_state=data["indx"];
                          List<Map<String,dynamic>> map=data["Orders"].cast<Map<String ,dynamic>>();
                          for(int i =0;i<map.length;i++){
                            MyApp.Data.add(
                                new Order(
                                  color: map[i]["color_S"],
                                  IsOn: map[i]["isOn"],
                                  Wait: map[i]["shouldWaitForMotion"],
                                  infin:(map[i]["duration"]==null),
                                  h: (map[i]["duration"]!=null)?map[i]["duration"]["hours"]:0,
                                  min: (map[i]["duration"]!=null)?map[i]["duration"]["minutes"]:0,
                                  sec: (map[i]["duration"]!=null)?map[i]["duration"]["seconds"]:0,
                                  IsDetected:map[i]["detected"]
                                )
                              // user(map[i]["name"],num[i],map[i]["ava"])
                            );
                          }
        
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MyHomePage(socket),)
                          );
                        }
                        );
                      }
                    }
                )
              ],
            ),
          ),
        ),
      )
    );
  }

}
class Order {
  int h,min,sec;
  bool infin;
  String color;
  bool IsOn;
  bool Wait;
  bool IsDetected;
  bool opened=false;
  Order({required this.color,required this.IsOn,required this.Wait, this.IsDetected=false,this.infin=false,this.h=0,this.min=0,this.sec=0});
}