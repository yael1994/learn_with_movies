import 'package:flutter/material.dart';
import 'package:temp_project/database/lesson_db.dart';
import 'package:temp_project/database/question_db.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:temp_project/components/video_range_slider.dart';

class AnswerSegmentScreen extends StatefulWidget {
  static const String id = 'question_creator_screen';
  final QuestionDB question;
  final LessonDB videoData;

  AnswerSegmentScreen({Key key, @required this.question, @required this.videoData})
      : super(key: key);

  @override
  _AnswerSegmentScreenState createState() => _AnswerSegmentScreenState();
}

class _AnswerSegmentScreenState extends State<AnswerSegmentScreen> {
//  TextEditingController _startAtController = TextEditingController();
//  TextEditingController _endAtController = TextEditingController();
  TextEditingController _questionController = TextEditingController();
  TextEditingController _answerController = TextEditingController();
  String id = "https://www.youtube.com/embed/rna7NSJFVy8?&end=50";

  double _lowerValue = 0.0;
  double _upperValue = 100.0;
  Duration videoLengthOriginal = Duration(minutes: 1, seconds: 20);
  List<Duration> startAt = [Duration(seconds: 0)];
  List<Duration> endAt = [Duration(minutes: 1, seconds: 20)];

  YoutubePlayerController _controller;

  void _incrementCounter() {
    setState(() {
      print("Add question:" + _questionController.text);
      print("Add answer:" + _answerController.text);

      print(startAt[0].inSeconds.toString());
      print(endAt[0].inSeconds.toString());
    });
  }


  void saveQuestion() {
    if (_questionController.text != '' && _answerController.text != '') {
      QuestionDB temp = QuestionDB();
      temp.setAnsewerStartTime(startAt[0].inSeconds);
      temp.setAnswerEndTime(endAt[0].inSeconds);
      Navigator.pop(context, temp);
    }
    print("Add question:" + _questionController.text);
    print("Add answer:" + _answerController.text);

    print(startAt[0].inSeconds.toString());
    print(endAt[0].inSeconds.toString());
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    videoLengthOriginal = Duration(
        seconds: widget.videoData.getVideoEndPoint() -
            widget.videoData.getVideoStartPoint());

    if (widget.question == null) {
      startAt[0] = Duration(seconds: widget.videoData.getVideoStartPoint());
      endAt[0] = Duration(seconds: widget.videoData.getVideoEndPoint());
    } else {
      _answerController.text = widget.question.answer;
      _questionController.text = widget.question.question;
      startAt[0] = Duration(seconds: widget.question.getVideoStartTime());
      endAt[0] = Duration(seconds: widget.question.getVideoEndTime());
    }

    //TODO: update videoLengthOriginal, startAt, endAt, depending on received video data
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoData.getVideoID(),
      flags: YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        //forceHideAnnotation: true,
      ),
    );
    _controller.addListener(() {
      if (_controller.value.position < startAt[0]) {
        _controller.seekTo(startAt[0]);
        _controller.pause();
      } else if (_controller.value.position > endAt[0]) {
        _controller.seekTo(endAt[0]);
        _controller.pause();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Add Question"),
        actions: <Widget>[
          RawMaterialButton(
            child: Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: saveQuestion,
          )
        ],
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                onReady: () {
                  _controller.seekTo(startAt[0]);
                  print('Player is ready.');
                },
              ),
              SizedBox(
                height: 15.0,
              ),

              SizedBox(
                height: 10.0,
              ),
              Text(
                'Choose the range of the answer:',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
              SizedBox(
                height: 10.0,
              ),
              VideoRangeSlider(
                startAt: startAt,
                endAt: endAt,
                length: videoLengthOriginal,
              ),
            ],
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
