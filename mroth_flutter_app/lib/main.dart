import 'package:flutter/material.dart';
import 'package:mroth_flutter_app/editors/appt_edit.dart';
import 'package:mroth_flutter_app/models/appointment.dart';
import 'package:mroth_flutter_app/models/user.dart';
import 'package:mroth_flutter_app/editors/user_edit.dart';
import 'package:mroth_flutter_app/singletons/cloud_sync.dart';
import 'package:mroth_flutter_app/utils/code_gen.dart';
import 'package:mroth_flutter_app/utils/date_format.dart';
import 'package:mroth_flutter_app/utils/size_config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roth Technical Specialties Scheduler',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'RothTech Scheduler'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<User> _users = [];
  User? _currentUser;

  List<Appointment> _appts = [];

  init() async {
    var userResult = await CloudSync().getAllUsers();
    if (userResult.success && userResult.data != null) {
      _users = List<User>.from(
          userResult.data!['items'].map((x) => User.fromJson(x)));
      if (_users.isNotEmpty) {
        _currentUser = _users[0];
        await _getUserAppts();
      }
    }
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    init(); // async call, not waiting, rebuilds upon completion
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 4),
        ),
      ),
      body: Column(children: [
        _getUserChooser(),
        Expanded(
          child: ListView(
            children: _getApptWidgets(),
          ),
        )
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAppt,
        tooltip: 'Add an Appointment',
        child: const Icon(Icons.add),
      ),
    );
  }

  _getUserChooser() {
    return Center(
      child: Column(
        children: [
          Card(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // const Text('Choose a User: '),
                DropdownButton<User>(
                  value: _currentUser,
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  hint: Text(
                    "Choose a user",
                    style:
                        TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 4),
                  ),
                  style: TextStyle(
                      color: Colors.deepPurple,
                      fontSize: SizeConfig.blockSizeHorizontal * 3),
                  underline: Container(
                    height: 2,
                    color: Colors.green,
                  ),
                  onChanged: (User? newValue) async {
                    _currentUser = newValue;
                    await _getUserAppts();
                    setState(() {});
                  },
                  items: _getUserDropDownMenuItems(
                    _users,
                  ),
                ),
                // const Spacer(),
                Row(
                  children: [
                    Text(
                      'Add user',
                      style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal * 3),
                    ),
                    IconButton(
                      onPressed: _addUser,
                      icon: Center(
                        child: Icon(
                          Icons.add,
                          size: SizeConfig.blockSizeHorizontal * 3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getUserAppts() async {
    var apptResult = await CloudSync().getAllUserAppts(_currentUser!.email);
    _appts.clear();
    if (apptResult.success) {
      _appts = List<Appointment>.from(
          apptResult.data!['items'].map((x) => Appointment.fromJson(x)));
    }
    setState(() {});
  }

  _getUserDropDownMenuItems(List<User> users) {
    return users.map<DropdownMenuItem<User>>((User user) {
      return DropdownMenuItem<User>(
        value: user,
        child: Text(
          user.name,
          textAlign: TextAlign.center,
        ),
      );
    }).toList();
  }

  List<Widget> _getApptWidgets() {
    List<Widget> tiles = [];

    for (var appt in _appts) {
      var dt = formatIsoDateTime(
          appt.dateTimeField.datetime, appt.dateTimeField.aMpM);
      var loc = appt.location;
      var guests = Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: appt.guests.isNotEmpty
              ? appt.guests
                  .map((e) => Text(
                        e,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: SizeConfig.blockSizeHorizontal * 3),
                      ))
                  .toList()
              : [
                  Text(
                    "No Guests",
                    style:
                        TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 3),
                  )
                ],
        ),
      );

      var tile = Dismissible(
        key: ValueKey(appt.primaryKey),
        confirmDismiss: (direction) async {
          final bool res = await showDialog(
            context: context,
            builder: (BuildContext localContext) {
              return AlertDialog(
                title: Text(
                  "Confirm",
                  style:
                      TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 3),
                ),
                content: Text(
                  "Are you sure you wish to delete this appointment?",
                  style:
                      TextStyle(fontSize: SizeConfig.blockSizeHorizontal * 3),
                ),
                actions: <Widget>[
                  TextButton(
                      onPressed: () => {
                            CloudSync().deleteAppt(appt).then((result) {
                              if (result.success) {
                                _showDeleteSuccessSnackBar(appt);
                                Navigator.of(context).pop(true);
                              } else {
                                _showDeleteFailureSnackBar(result.status);
                                Navigator.of(context).pop(false);
                              }
                            })
                          },
                      child: Text(
                        "DELETE",
                        style: TextStyle(
                            fontSize: SizeConfig.blockSizeHorizontal * 3),
                      )),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      "CANCEL",
                      style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal * 3),
                    ),
                  ),
                ],
              );
            },
          );
          return res;
        },
        onDismissed: (direction) async {
          _appts.remove(appt);
          setState(() {});
        },
        // Show a red background as the item is swiped away.
        background: Container(color: Colors.red),
        child: GestureDetector(
          onTap: () => _editAppt(appt),
          child: Padding(
            padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal),
            child: Card(
                child: Padding(
              padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      appt.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: SizeConfig.blockSizeHorizontal * 3),
                    ),
                  ),
                  Expanded(
                      flex: 6,
                      child: Column(
                        children: [
                          Text(
                            dt,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal * 3),
                          ),
                          Text(
                            loc,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal * 3),
                          )
                        ],
                      )),
                  Expanded(flex: 4, child: guests),
                ],
              ),
            )),
          ),
        ),
      );
      tiles.add(tile);
    }
    return tiles;
  }

  _showDeleteSuccessSnackBar(
    Appointment appt,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("${appt.name}, ${appt.dateTimeField.datetime} deleted")));
  }

  _showDeleteFailureSnackBar(
    String status,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(status)));
  }

  _addUser() async {
    User newUser = User.empty();

    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditUserRoute(user: newUser)),
    );

    if (result != null && result.email.isNotEmpty && result.name.isNotEmpty) {
      var cloudResult = await CloudSync().createOrUpdateUser(newUser);
      if (cloudResult.success) {
        _users.add(newUser);
        _currentUser = newUser;
        await _getUserAppts();
        setState(() {});
      }
    }
  }

  _addAppt() async {
    if (_currentUser == null) return;
    Appointment newAppt = Appointment.empty();
    newAppt.userId = _currentUser!.email;
    newAppt.primaryKey = CodeGenerator.createCryptoRandomString();

    List<String> possibleGuests = _users.map((e) => e.name).toList();
    possibleGuests.remove(_currentUser!.name);

    var result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditAppointmentRoute(
                appt: newAppt,
                usersWhoCanBeGuests: possibleGuests,
              )),
    );

    if (result != null &&
        result.name.isNotEmpty &&
        result.dateTimeField.datetime.isNotEmpty) {
      var cloudResult = await CloudSync().createOrUpdateAppt(newAppt);
      if (cloudResult.success) {
        setState(() {
          _appts.add(newAppt);
        });
      }
    }
  }

  _editAppt(Appointment appt) async {
    List<String> possibleGuests = _users.map((e) => e.name).toList();
    possibleGuests.remove(_currentUser!.name);

    var result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditAppointmentRoute(
                appt: appt,
                usersWhoCanBeGuests: possibleGuests,
              )),
    );

    if (result != null &&
        result.dateTimeField.datetime.isNotEmpty &&
        result.name.isNotEmpty) {
      var cloudResult = await CloudSync().createOrUpdateAppt(result!);
      if (cloudResult.success) {
        setState(() {});
      }
    }
  }
}
