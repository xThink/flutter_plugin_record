import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_plugin_record/response.dart';
import 'package:uuid/uuid.dart';

class FlutterPluginRecord {

  final  MethodChannel _channel = const MethodChannel('flutter_plugin_record')..setMethodCallHandler(_handler);


  static final _uuid = new Uuid();
  String id;
  static final alis = new Map<String, FlutterPluginRecord>();
  FlutterPluginRecord(){
    id = _uuid.v4();
    alis[id] = this;
  }

  ///Flutter 调用原生
  Future<dynamic> _invokeMethod(String method,
      [Map<String, dynamic> arguments = const {}]) {
    Map<String, dynamic> withId = Map.of(arguments);
    withId['id'] = id;
    return _channel.invokeMethod(method, withId);
  }

   ///初始化init的回调
   StreamController<bool> _responseInitController = new StreamController.broadcast();
   Stream<bool> get responseFromInit => _responseInitController.stream;

   ///开始录制 停止录制的回调监听
   StreamController<RecordResponse> _responseController = new StreamController.broadcast();
   Stream<RecordResponse> get response => _responseController.stream;


   ///音量高低的回调
   StreamController<RecordResponse> _responseAmplitudeController = new StreamController.broadcast();
   Stream<RecordResponse> get responseFromAmplitude => _responseAmplitudeController.stream;


   static Future<dynamic> _handler(MethodCall methodCall) {
     String id = (methodCall.arguments as Map)['id'];
     FlutterPluginRecord recordPlugin = alis[id];
     switch (methodCall.method) {
       case "onInit":
         bool flag=false;
         if("success"==methodCall.arguments["result"]){
           flag=true;
         }
         recordPlugin._responseInitController.add(flag);
         break;
       case "onStart":
         if("success"==methodCall.arguments["result"]){
           RecordResponse res = new RecordResponse(
             success: true,
             path: "",
             msg: "onStart",
             key: methodCall.arguments["key"].toString(),
           );
           recordPlugin._responseController.add(res);
         }

         break;
       case "onStop":
         if("success"==methodCall.arguments["result"]){
           RecordResponse res = new RecordResponse(
             success: true,
             path: methodCall.arguments["voicePath"].toString(),
             msg: "onStop",
             key: methodCall.arguments["key"].toString(),
           );
           recordPlugin._responseController.add(res);
         }

         break;
       case "onPlay":
         RecordResponse res = new RecordResponse(
           success: true,
           path: "",
           msg: "播放成功",
           key: methodCall.arguments["key"].toString(),
         );
         recordPlugin._responseController.add(res);
         break;
       case "onAmplitude":
         if("success"==methodCall.arguments["result"]){
           RecordResponse res = new RecordResponse(
             success: true,
             path: "",
             msg:  methodCall.arguments["amplitude"].toString(),
             key: methodCall.arguments["key"].toString(),
           );
           recordPlugin._responseAmplitudeController.add(res);
         }
         break;
       default:
         print("default");
         break;
     }
   }

   //初始化
   Future init() async {
     return await _invokeMethod('init', <String, String>{
       "init": "init",
     });
   }


   Future start() async {
     return await _invokeMethod('start', <String, String>{
       "start": "start",
     });
   }


   Future stop() async {
     return await _invokeMethod('stop', <String, String>{
       "stop": "stop",
     });
   }

   Future play() async {
     return await _invokeMethod('play', <String, String>{
       "play": "play",
     });
   }

}