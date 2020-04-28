import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import '././models/message.dart';
import '././dialogs/send_message.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PageController _pageController;
  int _page = 0;

  String titleBar = 'MQTT';
  // String broker = '192.168.161.60';
  int port = 8000;
  String username = 'admin';
  String passwd = 'admin';
  String clientIdentifier = 'lamhx111qweaa';

  final client = MqttBrowserClient('ws://192.168.161.60', 'epqweqwe213123ch');
  MqttConnectionState connectionState;
  StreamSubscription subscription;

  TextEditingController brokerController = TextEditingController();
  TextEditingController portController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwdController = TextEditingController();
  TextEditingController identifierController = TextEditingController();

  TextEditingController topicController = TextEditingController();
  Set<String> topics = Set<String>();

  List<Message> messages = <Message>[];
  ScrollController messageController = ScrollController();

  @override
  Widget build(BuildContext context) {
    IconData connectionStateIcon;
    switch (client?.connectionStatus.state) {
      case MqttConnectionState.connected:
        connectionStateIcon = Icons.cloud_done;
        break;
      case MqttConnectionState.disconnected:
        connectionStateIcon = Icons.cloud_off;
        break;
      case MqttConnectionState.connecting:
        connectionStateIcon = Icons.cloud_upload;
        break;
      case MqttConnectionState.disconnecting:
        connectionStateIcon = Icons.cloud_download;
        break;
      case MqttConnectionState.faulted:
        connectionStateIcon = Icons.error;
        break;
      default:
        connectionStateIcon = Icons.cloud_off;
    }
    void navigationTapped(int page) {
      _pageController.animateToPage(page,
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }

    void onPageChanged(int page) {
      setState(() {
        this._page = page;
      });
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(titleBar),
              SizedBox(
                width: 8.0,
              ),
              Icon(connectionStateIcon),
            ],
          ),
        ),
        floatingActionButton: _page == 2
            ? Builder(builder: (BuildContext context) {
                return FloatingActionButton(
                  child: Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute<String>(
                          builder: (BuildContext context) =>
                              SendMessageDialog(client: client),
                          fullscreenDialog: true,
                        ));
                  },
                );
              })
            : null,
        bottomNavigationBar: BottomNavigationBar(
          onTap: navigationTapped,
          currentIndex: _page,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.cloud),
              title: Text('Broker'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.playlist_add),
              title: Text('Subscriptions'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              title: Text('Messages'),
            ),
          ],
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: onPageChanged,
          children: <Widget>[
            _buildBrokerPage(connectionStateIcon),
            _buildSubscriptionsPage(),
            _buildMessagesPage(),
          ],
        ),
      ),
    );
  }

  Column _buildBrokerPage(IconData connectionStateIcon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              //Input Broker
              width: 200.0,
              child: TextField(
                controller: brokerController,
                decoration: InputDecoration(hintText: 'Input broker'),
              ),
            ),
            SizedBox(
              //Input Port
              width: 200.0,
              child: TextField(
                controller: portController,
                decoration: InputDecoration(hintText: 'Port'),
              ),
            ),
            SizedBox(
              //Username
              width: 200.0,
              child: TextField(
                controller: usernameController,
                decoration: InputDecoration(hintText: 'Username'),
              ),
            ),
            SizedBox(
              //Passwd
              width: 200.0,
              child: TextField(
                controller: passwdController,
                decoration: InputDecoration(hintText: 'Passwd'),
              ),
            ),
            SizedBox(
              //Passwd
              width: 200.0,
              child: TextField(
                controller: identifierController,
                decoration: InputDecoration(hintText: 'Client Identifier'),
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              "192.168.161.60" + ':' + port.toString(),
              style: TextStyle(fontSize: 24.0),
            ),
            SizedBox(width: 8.0),
            Icon(connectionStateIcon),
          ],
        ),
        SizedBox(height: 8.0),
        RaisedButton(
          child: Text(client?.connectionState == MqttConnectionState.connected
              ? 'Disconnect'
              : 'Connect'),
          onPressed: () {
            // if(brokerController.value.text.isNotEmpty) {
            //   broker = brokerController.value.text;
            // }

            // port = int.tryParse(portController.value.text);
            // if (port == null) {
            //   port = 1883;
            // }
            // if(usernameController.value.text.isNotEmpty) {
            //   username = usernameController.value.text;
            // }
            // if(passwdController.value.text.isNotEmpty) {
            //   passwd = passwdController.value.text;
            // }

            _connect();

            // clientIdentifier = identifierController.value.text;
            // if (clientIdentifier.isEmpty) {
            //   var random = new Random();
            //   clientIdentifier = 'lamhx_' + random.nextInt(100).toString();
            // }

            // if (client.connectionStatus.state ==
            //     MqttConnectionState.connected) {
            //   print('EXAMPLE::Mosquitto client connected');
            // } else {
            //   /// Use status here rather than state if you also want the broker return code.
            //   print(
            //       'EXAMPLE::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
            //   _connect();
            // }
          },
        ),
      ],
    );
  }

  Column _buildMessagesPage() {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            controller: messageController,
            children: _buildMessageList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RaisedButton(
            child: Text('Clear'),
            onPressed: () {
              setState(() {
                messages.clear();
              });
            },
          ),
        )
      ],
    );
  }

  Column _buildSubscriptionsPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 200.0,
              child: TextField(
                controller: topicController,
                decoration: InputDecoration(hintText: 'Please enter a topic'),
              ),
            ),
            SizedBox(width: 8.0),
            RaisedButton(
              child: Text('add topic'),
              onPressed: () {
                _subscribeToTopic(topicController.value.text);
              },
            ),
          ],
        ),
        SizedBox(height: 16.0),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          alignment: WrapAlignment.start,
          children: _buildTopicList(),
        )
      ],
    );
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    _pageController = PageController();
    super.initState();
  }

  List<Widget> _buildMessageList() {
    return messages
        .map((Message message) => Card(
              color: Colors.white70,
              child: ListTile(
                trailing: CircleAvatar(
                    radius: 14.0,
                    backgroundColor: Theme.of(context).accentColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'QoS',
                          style: TextStyle(fontSize: 8.0),
                        ),
                        Text(
                          message.qos.index.toString(),
                          style: TextStyle(fontSize: 8.0),
                        ),
                      ],
                    )),
                title: Text(message.topic),
                subtitle: Text(message.message),
                dense: true,
              ),
            ))
        .toList()
        .reversed
        .toList();
  }

  List<Widget> _buildTopicList() {
    // Sort topics
    final List<String> sortedTopics = topics.toList()
      ..sort((String a, String b) {
        return compareNatural(a, b);
      });
    return sortedTopics
        .map((String topic) => Chip(
              label: Text(topic),
              onDeleted: () {
                _unsubscribeFromTopic(topic);
              },
            ))
        .toList();
  }

  void _connect() async {
    client.logging(on: false);

    client.keepAlivePeriod = 20;

    client.port = port;

    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    client.pongCallback = pong;

    final connMess = MqttConnectMessage()
        .withClientIdentifier('Mqtt_MyClientUniqueIdaa')
        .keepAliveFor(20) // Must agree with the keep alive set above or not set
        .withWillTopic(
            'AGV2SFS/1') // If you set this you must set a will message
        .withWillMessage('AGV2SFS/1')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    print('MQTT client connecting....');
    client.connectionMessage = connMess;

    try {
      await client.connect(username, passwd);
      // await client.connect();
      print(
          "-------------------------------------------connect ok ------------------------------");
    } catch (e) {
      print('EXAMPLE::client exception - $e');
      _disconnect();
    }

    /// Check if we are connected
    if (client.connectionStatus.state == MqttConnectionState.connected) {
      print('MQTT client connected');
      setState(() {
        connectionState = client.connectionStatus.state;
      });
    } else {
      print('ERROR: MQTT client connection failed - '
          'disconnecting, state is ${client.connectionStatus.state}');
      _disconnect();
    }

    print('EXAMPLE::Subscribing to the test/lol topic');
    const topic = 'AGV2SFS/1'; // Not a wildcard topic
    client.subscribe(topic, MqttQos.atMostOnce);

    /// The client has a change notifier object(see the Observable class) which we then listen to to get
    /// notifications of published updates to each subscribed topic.
    subscription = client.updates.listen(_onMessage);
  }

  void _disconnect() {
    client.disconnect();
    _onDisconnected();
  }

  void _onDisconnected() {
    setState(() {
      topics.clear();
      connectionState = client.connectionState;
      subscription.cancel();
      subscription = null;
    });
    print('MQTT client disconnected');
  }

  void _onMessage(List<MqttReceivedMessage> event) {
    print(event.length);
    final MqttPublishMessage recMess = event[0].payload as MqttPublishMessage;
    final String message =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    /// The above may seem a little convoluted for users only interested in the
    /// payload, some users however may be interested in the received publish message,
    /// lets not constrain ourselves yet until the package has been in the wild
    /// for a while.
    /// The payload is a byte buffer, this will be specific to the topic
    print('MQTT message: topic is <${event[0].topic}>, '
        'payload is <-- ${message} -->');
    print(client.connectionState);
    setState(() {
      messages.add(Message(
        topic: event[0].topic,
        message: message,
        qos: recMess.payload.header.qos,
      ));
      try {
        messageController.animateTo(
          0.0,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      } catch (_) {
        // ScrollController not attached to any scroll views.
      }
    });
  }

  void onDisconnected() {
    print('EXAMPLE::OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus.returnCode == MqttConnectReturnCode.solicited) {
      print('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    }
  }

  /// The successful connect callback
  void onConnected() {
    print(
        'EXAMPLE::OnConnected client callback - Client connection was sucessful');
  }

  /// Pong callback
  void pong() {
    print('EXAMPLE::Ping response client callback invoked');
  }

// /// The subscribed callback
  void onSubscribed(String topic) {
    print('EXAMPLE::Subscription confirmed for topic $topic');
  }

  void _subscribeToTopic(String topic) {
    if (connectionState == MqttConnectionState.connected) {
      setState(() {
        if (topics.add(topic.trim())) {
          print('Subscribing to ${topic.trim()}');
          client.subscribe(topic, MqttQos.exactlyOnce);
        }
      });
    }
  }

  void _unsubscribeFromTopic(String topic) {
    if (connectionState == MqttConnectionState.connected) {
      setState(() {
        if (topics.remove(topic.trim())) {
          print('Unsubscribing from ${topic.trim()}');
          client.unsubscribe(topic);
        }
      });
    }
  }
}
