import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'Voice.dart';
import 'main.dart';

class MyHomePage extends StatefulWidget {
  IO.Socket socket;
  MyHomePage(this.socket);

  @override
  State<MyHomePage> createState() => _MyHomePageState(socket);
}

class _MyHomePageState extends State<MyHomePage> {
  int indx =-1;
  IO.Socket socket;
  bool wait =false;
  _MyHomePageState(this.socket){
    socket.on("data", (data) async {
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
      wait =false;
      setState(() {

      });
    });
    socket.on("Update", (data) async {
      if(data["State"]==0){
        if( MyApp.Cur_state>data["indx"]){
          for(int i=data["indx"];i<= MyApp.Cur_state;i++){
            MyApp.Data[i].IsDetected=false;
          }
        }
        MyApp.Cur_state=data["indx"];
      }else{
        MyApp.Cur_state=data["indx"];
        MyApp.Data[MyApp.Cur_state].IsDetected=true;
      }
      setState(() {

      });
    });
    socket.on("err", (data) async {
      wait =false;
      setState(() {

      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Color(0xFFC72C41),
                borderRadius: BorderRadius.all(Radius.circular(15))
              ),
              child: Column(
                children: [
                  Center(
                    child: Text("Err Ocure",
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  SizedBox(height: 5,),
                  Text(data["Err"]),
                ],
              )
            )
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
        backgroundColor:Color.fromARGB(255, 237, 238, 240),
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.add, color: Colors.red),
            onPressed: () async{
              indx=-1;
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  Voice_App_()),
              );
              if(result ==null){
                print("null");
              }else{
                wait=true;
                String a ="make the color red for 1 minutes then make the color blue for 30 seconds";
                socket.emit("data",{"indx":indx,"Orders":result});
                setState(() {

                });
              }

            },
          ),
          centerTitle: true,
          backgroundColor: Color.fromARGB(255, 10, 24, 46),
          title: Text(
            "AI Powered IOT Lighting",
            style: TextStyle(
                color: Colors.white
            ),
          ),
        ),
        body:(!wait)? Scrollbar(
            child:  ListView.builder(
              itemCount: MyApp.Data.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(

                    margin:  EdgeInsets.only(left: 10,right: 10,top: 7,bottom: 7),
                    padding:  EdgeInsets.all(7.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color:  (MyApp.Cur_state>index)? Color.fromARGB(255, 41, 204, 106):(MyApp.Cur_state==index)?Color.fromARGB(255, 35, 110, 255):Color.fromARGB(255, 208, 188, 8),
                          width: 1.5,
                        ),
                        borderRadius:  BorderRadius.all( Radius.circular(8)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.2),
                            spreadRadius: 3,
                            blurRadius: 5,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ]

                    ),
                    child: Row(
                      crossAxisAlignment: MyApp.Data[index].opened?CrossAxisAlignment.end:CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(child:Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SvgPicture.asset(
                                  (MyApp.Cur_state>index)? "assets/Comp.svg":(MyApp.Cur_state==index)?"assets/Process.svg":"assets/Fut.svg",
                                  width: (MyApp.Cur_state>index)?45:35,
                                  height:(MyApp.Cur_state>index)?45:35,
                                  color: (MyApp.Cur_state>index)? Color.fromARGB(255, 41, 204, 106):(MyApp.Cur_state==index)?Color.fromARGB(255, 35, 110, 255):Color.fromARGB(255, 208, 188, 8),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 25,
                                      child:    Text(
                                        (MyApp.Cur_state>index)?  "completed process":(MyApp.Cur_state==index)?"processing . . .":"Queue",

                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        SvgPicture.asset(
                                          "assets/Lamp.svg",
                                          width: 17,
                                          height: 17,
                                        ),
                                        SizedBox(
                                            width: 3
                                        ),
                                        Text(
                                          "${MyApp.Data[index].color} Lamp",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            ///////////////////////////////////////////////////////////////////////////////////////////
                            (MyApp.Data[index].opened)?
                            Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 20),
                                  child: Divider(
                                    color: Colors.grey,

                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 20,top: 5),
                                  child:  Column(
                                    children: [
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            (MyApp.Cur_state>index)? "assets/Time_DN.svg":"assets/Time_Pro.svg",
                                            width: 23,
                                            height: 23,
                                          ),
                                          Text(
                                            MyApp.Data[index].infin? "  Null":(//((MyApp.Cur_state==index)?"  Less Than ":"  ") +
                                            ((MyApp.Data[index].h==0)?"":"${MyApp.Data[index].h}h")+(",${MyApp.Data[index].min}min")+((MyApp.Data[index].sec==0 )?"":",${MyApp.Data[index].sec}sec")),                       //"  1h, 5 min and 5 sec"
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                              Icons.power_settings_new
                                          ),
                                          Text(
                                            "  Turned ",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13
                                            ),

                                          ),
                                          Text(
                                            (MyApp.Data[index].IsOn)? "ON":"OFF",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: (MyApp.Data[index].IsOn)?Colors.green:Colors.red,
                                                fontSize: 13
                                            ),

                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            "assets/motion.svg",
                                            width: 23,
                                            height: 23,
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                ((MyApp.Data[index].Wait)?"  ":"  Not ")+ "Waiting for Motion",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: (MyApp.Data[index].Wait)?Colors.green:Colors.red,
                                                    fontSize: 13
                                                ),
                                              ),
                                              (MyApp.Data[index].Wait)? Text(
                                                (MyApp.Data[index].IsDetected)?  "  detected":"  Not detected",
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey
                                                ),
                                              ):Container()
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 30,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ):
                            Container(),

                            ///////////////////////////////////////////////////////////////////////////////////////////
                          ],
                        ),
                        ),
                        (!(MyApp.Cur_state>index))?
                        SizedBox(
                          width: 33,
                          child: IconButton(onPressed: () async{
                            indx=index;
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>  Voice_App_()),
                            );
                            if(result ==null){
                              print("null");
                            }else{
                              wait=true;
                              String a ="make the color white for 30 seconds then make the color green for 1 minutes";
                              socket.emit("data",{"indx":indx,"Orders":result});
                              setState(() {

                              });
                            }

                          }, icon: SvgPicture.asset(
                            "assets/Add_DN.svg",
                            width: 25,
                            height: 25,
                          ),

                          ),
                        ):Container(),
                        (!(MyApp.Cur_state==index))?
                        SizedBox(
                          width: 33,
                          child:   IconButton(onPressed: (){
                            socket.emit("Update",{"state":0,"indx":index});

                          }, icon:  SvgPicture.asset(
                            "assets/Jump.svg",
                            width: 17,
                            height: 17,
                          ),
                          ),
                        ):Container(),

                        SizedBox(
                          width: 30,
                          child: IconButton(onPressed: (){
                            MyApp.Data[index].opened =!MyApp.Data[index].opened;
                            setState(() {

                            });

                          }, icon: SvgPicture.asset(
                            (MyApp.Data[index].opened)?"assets/UP.svg":"assets/DN.svg",
                            width: 9,
                            height: 9,
                          ),

                          ),
                        ),


                      ],
                    )
                );
              },
            )
        ):Center(
          child: CircularProgressIndicator(),
        )

    );
  }
}
