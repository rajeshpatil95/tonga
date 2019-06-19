import 'dart:async';
import 'dart:convert';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:data/data.dart';
import 'package:data/models/class_join.dart';
import 'package:data/models/serializers.dart';
import 'package:data/models/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:nearby/nearby.dart';
import 'package:permission_handler/permission_handler.dart';

enum Status { contestSession, contestStart, classSession, none }

class NearByStateContainer extends StatefulWidget {
  final Widget child;

  NearByStateContainer({this.child});

  static NearByContainerState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedAppStateContainer)
            as _InheritedAppStateContainer)
        ?.data;
  }

  @override
  NearByContainerState createState() => new NearByContainerState();
}

class NearByContainerState extends State<NearByStateContainer> {
  Nearby _nearBy = Nearby.instance;
  Status mode = Status.none;

  List<dynamic> connections = [];
  String jsonMessage;
  String classSessionId;
  int numberOfQuestions;

  List<dynamic> listOfConnectedStudents = [];
  Performance performance;
  List<Performance> performanceList = [];
  List<Performance> quizPerformances = [];
  List<Performance> endQuiz = [];
  List<Map<String, Performance>> quizParticipant = [];
  List<dynamic> studentsJoinedQuiz = [];

  //List to Store the Active Connetions
  var activeConnections = new Map();

  // State
  StreamSubscription _stateSubscription;
  String stateMessage = "unknown";

  // Discovering
  StreamSubscription _discoverySubscription;
  List<dynamic> advertisers = [];
  List<dynamic> removedAdvertisersInSession = [];
  bool isDiscovering = false;

  // Advertising
  StreamSubscription _advertisingSubscription;
  bool isAdvertising = false;

  // Connection
  StreamSubscription _endPointUnknownSubscription;
  StreamSubscription _endPointNotificationSubscription;
  StreamSubscription _connectionSubscription;
  bool isConnected = false;

  final standardSerializers =
      (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  initialize() async {
    // Initialize Handlers
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([
      PermissionGroup.location,
      PermissionGroup.photos,
      PermissionGroup.camera,
      PermissionGroup.storage
    ]);

    _nearBy.initializeMessageHandlers((Map<dynamic, dynamic> message) async {
      onReceiveMessage(message);
    });

    // Immediately get the State of Nearby
    _nearBy.state.then((s) {
      setState(() {
        stateMessage = s;
        _log(stateMessage);
      });
    });

    // Subscribe to State Changes
    _stateSubscription = _nearBy.onStateChanged().listen((s) {
      setState(() {
        stateMessage = s;
        _log("onStateChanged:" + stateMessage);
      });
    });

    // Show Pop Up to ask user to go back to Discovery Screen
    _endPointUnknownSubscription = _nearBy.onEndPointUnknown().listen((s) {
      _log('onEndPointUnknown: ${s}');
    });
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _stateSubscription = null;
    _discoverySubscription?.cancel();
    _discoverySubscription = null;
    _connectionSubscription?.cancel();
    _connectionSubscription = null;
    _endPointNotificationSubscription?.cancel();
    _endPointNotificationSubscription = null;
    super.dispose();
  }

  onEndPointNotification(Function callBack) async {
    _endPointNotificationSubscription =
        _nearBy.onEndPointNotification().listen((s) {
      print('onEndPointNotification: ${s}');
      if (s != null && s['onEndpointDisconnected'] != null) {
        onEndpointDisconnected(s);
      } else if (s != null && s['onEndpointConnected'] != null) {
        onEndpointConnected(s, callBack);
      }
    });
  }

  onEndpointConnected(s, callBack) async {
    print('onEndpointConnected: ${s}');
    callBack(s);
  }

  onEndpointDisconnected(s) async {
    await getConnections();
    setState(() {
      print('onEndpointDisconnected ${s} clearing messages and advertisers');
      var disconnectedEndPointId = s['onEndpointDisconnected']['endPointId'];
      print('disconnectedEndPointId $disconnectedEndPointId');
      removedAdvertisersInSession.add(s);
      advertisers.removeWhere(
          (i) => i['endPointId'] == s['onEndpointDisconnected']['endPointId']);
      //identify which student got disconnected by using endPointId and remove him/her from listOfConnectedStudents
      if(activeConnections.containsKey(disconnectedEndPointId)){
        var studentId = activeConnections[disconnectedEndPointId];
        activeConnections.remove(disconnectedEndPointId);
        listOfConnectedStudents.remove(studentId);
      }
    });
  }

  updateMode(Status status) {
    setState(() {
      mode = status;
    });
  }

  startDiscovery() async {
    advertisers = [];
    _discoverySubscription = _nearBy
        .startDiscovery(
      timeout: const Duration(seconds: 300),
    )
        .listen((discoveryResult) {
      _log('discoveryResult: ${discoveryResult}');
      setState(() {
        // Duplicate Discovery result
        advertisers.removeWhere(
            (i) => i['endPointId'] == discoveryResult['endPointId']);
        if (removedAdvertisersInSession.contains(
            (i) => i['endPointName'] == discoveryResult['endPointName'])) {
          print(
              'rejected as advertiser who stopped advertising ${discoveryResult}');
        } else {
          advertisers.add(discoveryResult);
          print('adding to list ${discoveryResult}');
        }
      });
    }, onDone: stopDiscovery);

    setState(() {
      isDiscovering = true;
    });
  }

  stopDiscovery() {
    _discoverySubscription?.cancel();
    _discoverySubscription = null;
    _nearBy.stopDiscovery();
    setState(() {
      isDiscovering = false;
    });
  }

  startAdvertising(Map<String, String> options) {
    if (!isAdvertising) {
      _advertisingSubscription = _nearBy
          .startAdvertising(
            options,
            timeout: const Duration(seconds: 6000),
          )
          .listen((result) {}, onDone: stopAdvertising);

      setState(() {
        isAdvertising = true;
      });
    }
  }

  stopAdvertising() {
    _advertisingSubscription?.cancel();
    _advertisingSubscription = null;
    _nearBy.stopAdvertise();
    setState(() {
      isAdvertising = false;
    });
  }

  disconnectFromDevice(String endPointId) async {
    final Map<String, String> connectionInfo = <String, String>{
      'endPointId': endPointId
    };

    // await _nearBy.disconnectFromDevice(connectionInfo);
    final modifiedConnections = await _nearBy.connections;
    setState(() {
      connections = modifiedConnections;
    });
  }

  connectTo(Map<dynamic, dynamic> connectionInfo) async {
    //Connect to Device
    _connectionSubscription =
        _nearBy.connectTo(connectionInfo).listen((result) async {
      stopDiscovery();
      setState(() {
        isConnected = result;
        _log('Connection Result: ${isConnected}');
      });
    }, onDone: stopConnection);
  }

  disconnect() async {
    stopConnection();
    _log('Disconnect ...');
    setState(() {
      if (advertisers.length > 0) {
        _log('Remove all advertisers ...');
        advertisers.removeRange(0, advertisers.length - 1);
        advertisers = [];
      }
    });
    await _nearBy.disconnect();
  }

  stopConnection() {
    try {
      _connectionSubscription?.cancel();
      _connectionSubscription = null;
      setState(() {
        isConnected = false;
        _log('stopConnection ... ${isConnected}');
      });
    } catch (e) {
      setState(() {
        _connectionSubscription = null;
        isConnected = false;
        _log('stopConnection ... ${isConnected}');
      });
    }
  }

  startQuizSession(BuildContext context) {
    setState(() {
      updateMode(Status.contestSession);
    });
    QuizSession quizSession = QuizSession(
      (c) => c
        ..sessionId = '1'
        ..gameId = 'FindWordGame'
        ..level = 3
        ..gameData.add(
          MultiData(
            (d) => d
              ..gameId = 'FindWordGame'
              ..choices.addAll(['a', 'b'])
              ..specials.add('value')
              ..answers.addAll(['a']),
          ),
        )
        ..gameData.add(
          MultiData(
            (d) => d
              ..gameId = 'FindWordGame'
              ..choices.addAll(['x', 'y', 'z'])
              ..specials.add('value')
              ..answers.addAll(['x']),
          ),
        )
        ..gameData.add(
          MultiData(
            (d) => d
              ..gameId = 'FindWordGame'
              ..choices.addAll(['a', 'b', 'c'])
              ..specials.add('value')
              ..answers.addAll(['b']),
          ),
        )
        ..gameData.add(
          MultiData(
            (d) => d
              ..gameId = 'FindWordGame'
              ..choices.addAll(['a', 'b'])
              ..specials.add('value')
              ..answers.addAll(['a']),
          ),
        )
        ..gameData.add(
          MultiData(
            (d) => d
              ..gameId = 'FindWordGame'
              ..choices.addAll(['a', 'b'])
              ..specials.add('value')
              ..answers.addAll(['a']),
          ),
        )
        ..gameData.add(
          MultiData(
            (d) => d
              ..gameId = 'FindWordGame'
              ..choices.addAll(['a', 'b'])
              ..specials.add('value')
              ..answers.addAll(['a']),
          ),
        )
        ..gameData.add(
          MultiData(
            (d) => d
              ..gameId = 'FindWordGame'
              ..choices.addAll(['a', 'b'])
              ..specials.add('value')
              ..answers.addAll(['a']),
          ),
        )
        ..gameData.add(
          MultiData(
            (d) => d
              ..gameId = 'FindWordGame'
              ..choices.addAll(['a', 'b'])
              ..specials.add('value')
              ..answers.addAll(['a']),
          ),
        )
        ..gameData.add(
          MultiData(
            (d) => d
              ..gameId = 'FindWordGame'
              ..choices.addAll(['a', 'b', 'c'])
              ..answers.addAll(['b']),
          ),
        )
        ..gameData.add(
          MultiData(
            (d) => d
              ..gameId = 'FindWordGame'
              ..choices.addAll(['a', 'b', 'c', 'd'])
              ..answers.addAll(['d']),
          ),
        ),
    );

    numberOfQuestions = quizSession.gameData.length;
    final quizSessionJson = standardSerializers.serialize(quizSession);
    final quizSessionJsonString = jsonEncode(quizSessionJson);
    sendMessage("$quizSessionJsonString");
  }

  startQuiz(BuildContext context) {
    setState(() {
      updateMode(Status.contestStart);
    });
    QuizUpdate quizStart = QuizUpdate((c) => c
      ..sessionId = '1'
      ..status = StatusEnum.start);

    final quizStartJson = standardSerializers.serialize(quizStart);
    final quizStartJsonString = jsonEncode(quizStartJson);
    sendMessage("$quizStartJsonString");
  }

// QuizUpdate allPerformances;
  stopQuiz() {
    setState(() {
      updateMode(Status.classSession);
    });
    QuizUpdate quizEnd = QuizUpdate((q) {
      for (int i = 0; i < quizPerformances.length; i++) {
        q
          ..sessionId = '1'
          ..performances.add(quizPerformances[i])
          ..status = StatusEnum.end;
      }
    });
    final quizEndJson = standardSerializers.serialize(quizEnd);
    final quizEndJsonString = jsonEncode(quizEndJson);
    sendMessage("$quizEndJsonString");
  }

  quizInProgress(Performance performance) {
    if (quizPerformances.isEmpty) {
      quizPerformances.add(performance);
    } else {
      quizPerformances
          .removeWhere((test) => test.studentId == performance.studentId);
      quizPerformances.add(performance);
      // quizPerformances.forEach(
      //   (q) {
      //     if (q.studentId != performance.studentId) {
      //       quizPerformances.add(performance);
      //     } else {
      //       endQuiz.add(performance);
      //     }
      //   },
      // );
    }

    QuizUpdate quizUpdate = QuizUpdate((q) {
      for (int i = 0; i < quizPerformances.length; i++) {
        q
          ..sessionId = '1'
          ..performances.add(quizPerformances[i])
          ..status = StatusEnum.progress;
      }
    });
    // allPerformances=quizUpdate;
    final quizUpdateJson = standardSerializers.serialize(quizUpdate);
    final quizUpdateJsonString = jsonEncode(quizUpdateJson);
    sendMessage("$quizUpdateJsonString");
  }

  sendMessageTo(String endPointId, String textMessage) async {
    final Map<String, String> textMessageMap = <String, String>{
      'endPointId': endPointId,
      'message': textMessage
    };

    var sentSuccessfully = await _nearBy.sendMessageTo(textMessageMap);
    _log('Message ${textMessage} Sent: ${sentSuccessfully} ...!!');
  }

  sendMessage(String textMessage) async {
    final Map<String, String> textMessageMap = <String, String>{
      'message': textMessage
    };

    var sentSuccessfully = await _nearBy.sendMessage(textMessageMap);
    _log('Message ${textMessage} Sent: ${sentSuccessfully} to all...!!');
  }

  updateClassSessionId(String advertiserId) {
    classSessionId = advertiserId;
  }

  sendUserProfile(String endPointId, String sessionId) {
    UserProfile userProfile = UserProfile((c) {
      c
        ..name = 'Rajesh Patil'
        ..currentTheme = 'Random'
        ..gameStatuses = BuiltMap<String, GameStatus>({
          'status': GameStatus((b) => b
            ..currentLevel = 0
            ..highestLevel = 20
            ..maxScore = 10
            ..open = false)
        })
        ..items = BuiltMap<String, int>({'items': 10})
        ..accessories = BuiltMap<String, String>({'accessories': 'Gold'});
    });

    final userProfileJson = standardSerializers.serialize(userProfile);

    final userProfileJsonString = jsonEncode(userProfileJson);

    if (classSessionId == sessionId && mode == Status.classSession) {
      sendMessageTo(endPointId, userProfileJsonString);
    }
  }

  void onReceiveMessage(Map<dynamic, dynamic> message) async {
    print('Message Received: ${message}');
    jsonMessage = message['textMessages']['message'];
    var endPointId = message['textMessages']['endPointId'];

    final newJson = jsonDecode(jsonMessage);
    final jsonType = newJson[String.fromCharCode(036)];
    final sessionId = newJson['sessionId'];



    switch (jsonType) {
      case 'ClassJoin':
        if (classSessionId == sessionId) {
          ClassJoin s = standardSerializers.deserialize(newJson);
          activeConnections[endPointId] = s.studentId;
          listOfConnectedStudents.add(s.studentId);
          sendUserProfile(endPointId, sessionId);
          studentsJoinedQuiz.add(s.studentId);
        }
        break;
      case 'QuizJoin':
        QuizJoin quizJoin = standardSerializers.deserialize(newJson);
        // studentsJoinedQuiz.add(contestJoin.studentId);
        break;

      case 'Performance':
        Performance p = standardSerializers.deserialize(newJson);
        performanceList.add(p);
        if (mode == Status.contestStart) quizInProgress(p);
        break;

      default:
    }
  }

  Future<void> getConnections() async {
    List<dynamic> connections = await _nearBy.connections;
    setState(() => this.connections = connections);
    print('Got Connections : $connections');
  }

  void _log(String message) {
    print("TeacherApp Message:" + message);
  }

  @override
  Widget build(BuildContext context) {
    return new _InheritedAppStateContainer(
      data: this,
      child: widget.child,
    );
  }
}

class _InheritedAppStateContainer extends InheritedWidget {
  final NearByContainerState data;

  _InheritedAppStateContainer(
      {Key key, @required this.data, @required Widget child})
      : super(key: key, child: child);

  bool updateShouldNotify(_InheritedAppStateContainer old) => true;
}
