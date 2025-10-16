Map<String, String> wedldingDefectsClassMap = {
  "": "정상",
  "crack":"균열",                       // 균열       - RTST, RTAL
  "porosity": "기공",                   // 기공
  "lack of fusion": "융합불량",          // 융합불량
  "incomplete penetration": "용입부족",  // 용입부족    - VTST
  "slag inclusion": "슬래그 혼입",       // 슬래그 혼입 - RTST, RTAL
  "undercut": "언더컷"                  // 언더컷
};

String entokrTrans(String className) =>
  wedldingDefectsClassMap[className]??"존재하지 않는 클래스";

String conclusionReturn(List results){
  if (results.isEmpty) return "탐지된 용접 결함이 없습니다.";

  final buffer = StringBuffer("다음은 감지된 용접 결함 ${results.length}개의 요약:\n\n");

  for (int i=0; i<results.length;i++){
    String defectKRname = entokrTrans(results[i]["class_name"]);
    double confidence = results[i]["confidence"]*100;
    buffer.writeln(
      "- 결함 종류: $defectKRname (${results[i]["class_name"]}), 신뢰도: ${confidence.toStringAsFixed(3)}%"
      );
  }

  buffer.writeln("\n이 결함들에 대한 즉각 조치가 필요합니다");
  return buffer.toString();
}
  