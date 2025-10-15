import 'package:flutter/material.dart';
import 'package:ictproject/index/standard.dart';

Map<String, dynamic> _chatSet(
  String target, String modelVersion, 
  String asset, {String information = 'ChatGPT Model'}
  ){
  return {
    'target':target,
    'modelVersion':modelVersion,
    'image':Image.asset(
      asset,
      width:radiusChatImage*1.4,
      height: radiusChatImage*1.4,
      fit:BoxFit.cover
      ),
    'information':information,
  };
}

//Chat 모드 설정
List chatMode = [
  _chatSet(
    'initGPT', 'gpt-4o',
    'assets/images/logo.png',
    information: '기본 모델'
  ),
  _chatSet(
    'reasonGPT', 'o1',
    'assets/images/o1logo.png',
    information: 'Model for Reasoning')
];

//추출 함수
String findChatVersion(String target){
  return findChatMode(target)['modelVersion'];
}

Image findChatImage(String target) {
  return findChatMode(target)['image'];
}

Map<String, dynamic> findChatMode(String target){
  return chatMode.firstWhere(
    (chat) => chat['target'] == target,
    orElse: () => null,
  );
}