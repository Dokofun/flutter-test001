class Location {
  final String name;
  List<Weather> timeline;
  Location(this.name,this.timeline);


}
class Weather {
  String startTime ='';
  String endTime ='';
  String? maxT;
  String? minT;
  Weather();
  Weather.fromJson(Map<String, dynamic> json)
      : startTime = json['startTime'],
        endTime = json['endTime'];
}