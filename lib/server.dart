import 'dart:convert';
import 'package:mysql_client/mysql_client.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';
import 'constant.dart';


Future<void> server() async {

  final router = Router();

  // Handle POST request for login
  router.post('/api/login', (Request request) async {
      final payload = await request.readAsString();
      final Map<String, dynamic> data = jsonDecode(payload);

      final username = data['username'];
      final password = data['password'];

      var result = await conn.execute("SELECT * FROM pcpn.user_accounts WHERE username=\"$username\" AND password=\"$password\"");
      var checkuser = result.rows.length;

      // Basic authentication logic
      if (checkuser > 0) {
        var user = {};
        for (var element in result.rows) {
          user = {
            "id": int.parse(element.assoc()['id']!), 
            "name": element.assoc()['name']!, 
            "username": element.assoc()['username']!,
            "password": element.assoc()['password']!,
          };
        }

        return Response.ok(jsonEncode({'response': user}), headers: {
          'Content-Type': 'application/json',
        });
      } else {
        print('failed');
        return Response.forbidden(jsonEncode({'response': 'Invalid credentials'}), headers: {
          'Content-Type': 'application/json',
        });
      }
  });

  router.get('/api/masterlist', (Request request) async {
    var data = [];
    var result = await conn.execute("SELECT * FROM pcpn.masterlist");
    for (var element in result.rows) {
      data.add({
        'id': int.parse(element.assoc()['ID']!),
        'pin': element.assoc()['PIN'],
        'tid': element.assoc()['TRANSACTION_ID'],
        'lname': element.assoc()['LNAME'],
        'fname': element.assoc()['FNAME'],
        'mname': (element.assoc()['MNAME'] == null)? "" : element.assoc()['MNAME'],
        'ext': (element.assoc()['EXT'] == null)? "" : element.assoc()['EXT'],
        'dob': (element.assoc()['DOB'] == null)? "" : element.assoc()['DOB'],
        'type': element.assoc()['CLIENT_TYPE'],
        'doe': (element.assoc()['DOE'] == null)? "" : element.assoc()['DOE'],
        'effyear': element.assoc()['EFF_YEAR'],
        'net': double.parse(element.assoc()['NET_TOTAL']),
        'bal': double.parse(element.assoc()['BALANCE']),
      });
    }

    return Response.ok(jsonEncode({'response': data}), headers: {
      'Content-Type': 'application/json',
    });
  });

  router.get('/api/consultation', (Request request) async {
    var data = [];
    var result = await conn.execute("SELECT * FROM pcpn.consultation;");
    if (result.rows.length > 0) {
      for (var element in result.rows) {
        data.add({
          'id': int.parse(element.assoc()['ID']!),
          'memid': element.assoc()['MEM_ID']!,
          'tid': element.assoc()['TRANSACTION_ID']!,
          'pin': element.assoc()['PIN']!,
          'lname': element.assoc()['LNAME']!,
          'fname': element.assoc()['FNAME']!,
          'mname': element.assoc()['MNAME']!,
          'ext': element.assoc()['EXTNAME']!,
          'dob': element.assoc()['DOB']!,
          'clienttype': element.assoc()['CLIENT_TYPE']!,
          'effyear': element.assoc()['EFF_YEAR']!,
          'condate': element.assoc()['CONSULTATION_DATE']!,
          'firstencounter': element.assoc()['FIRST_ENCOUNTER']!,
          'epress': element.assoc()['EPRESS']!,
          'ekas': element.assoc()['EKAS']!,
          'paid': element.assoc()['PAID_BY_PHIC']!,
          'facility': element.assoc()['FACILITY']!,
          'diagnosis': element.assoc()['DIAGNOSIS']!,
        });
      }
    } else {
      data = [];
    }
    return Response.ok(jsonEncode({'response': data}), headers: {
      'Content-Type': 'application/json',
    });
  });

  router.get('/api/laboratory', (Request request) async {
    var data = [];
    var result = await conn.execute("select pcpn.laboratory.ID, pcpn.laboratory.CONSULT_ID, pcpn.consultation.PIN, pcpn.consultation.LNAME, pcpn.consultation.FNAME, pcpn.consultation.MNAME, pcpn.consultation.EXTNAME, pcpn.consultation.CLIENT_TYPE, pcpn.consultation.CONSULTATION_DATE, pcpn.laboratory.LAB_REQUEST, pcpn.laboratory.HOSPITAL, pcpn.laboratory.AMOUNT from pcpn.consultation join pcpn.laboratory where pcpn.consultation.TRANSACTION_ID = pcpn.laboratory.CONSULT_ID");
    if (result.rows.length > 0) {
      for (var element in result.rows) {
        data.add({
          'id': int.parse(element.assoc()['ID']!),
          'consultID': element.assoc()['CONSULT_ID']!,
          'pin': element.assoc()['PIN']!,
          'lname': element.assoc()['LNAME']!,
          'fname': element.assoc()['FNAME']!,
          'mname': element.assoc()['MNAME']!,
          'ext': element.assoc()['EXTNAME']!,
          'clienttype': element.assoc()['CLIENT_TYPE']!,
          'condate': element.assoc()['CONSULTATION_DATE']!,
          'labRequest': element.assoc()['LAB_REQUEST']!,
          'hospital': element.assoc()['HOSPITAL']!,
          'amount': element.assoc()['AMOUNT']!,
        });
      }
    } else {
      data = [];
    }
    return Response.ok(jsonEncode({'response': data}), headers: {
      'Content-Type': 'application/json',
    });
  });

  router.get('/api/medicine', (Request request) async {
    var data = [];
    var result = await conn.execute("select pcpn.medicine.ID, pcpn.medicine.CONSULT_ID, pcpn.consultation.PIN, pcpn.consultation.LNAME, pcpn.consultation.FNAME, pcpn.consultation.MNAME, pcpn.consultation.EXTNAME, pcpn.consultation.CONSULTATION_DATE, pcpn.medicine.MEDICINE, pcpn.medicine.WEIGHT, pcpn.medicine.QTY, pcpn.medicine.AMOUNT, pcpn.medicine.TOTAL from pcpn.consultation join pcpn.medicine where pcpn.consultation.TRANSACTION_ID = pcpn.medicine.CONSULT_ID");
    if (result.rows.length > 0) {
      for (var element in result.rows) {
        data.add({
          'id': int.parse(element.assoc()['ID']!),
          'consultID': element.assoc()['CONSULT_ID']!,
          'pin': element.assoc()['PIN']!,
          'lname': element.assoc()['LNAME']!,
          'fname': element.assoc()['FNAME']!,
          'mname': element.assoc()['MNAME']!,
          'ext': element.assoc()['EXTNAME']!,
          'condate': element.assoc()['CONSULTATION_DATE']!,
          'medicine': element.assoc()['MEDICINE']!,
          'weight': element.assoc()['WEIGHT']!,
          'qty': element.assoc()['QTY']!,
          'amount': element.assoc()['AMOUNT']!,
          'total': element.assoc()['TOTAL']!,
        });
      }
    } else {
      data = [];
    }
    return Response.ok(jsonEncode({'response': data}), headers: {
      'Content-Type': 'application/json',
    });
  });

  router.post('/api/new-data', (Request request) async {
    final payload = await request.readAsString();
    final Map<String, dynamic> data = jsonDecode(payload);

    final pin = data['pin'];
    final lname = data['lname'];
    final fname = data['fname'];
    final mname = data['mname'];
    final ext = data['ext'];
    final dob = data['dob'];
    final doe = data['doe'];
    final clienttype = data['client_type'];
    final effyear = data['effyear'];
    double net = 900;
    double balance = 900;

    var x = await conn.execute("SELECT TRANSACTION_ID FROM pcpn.masterlist order by ID desc limit 1");
    var lastid = 1;
    if (x.rows.length > 0) {
      for (var element in x.rows) {
        String z = element.assoc()['TRANSACTION_ID']!;
        String s = z.replaceAll(RegExp(r'TID'), '');
        lastid = int.parse(s) - 1000;
      }
    }
    var tid = "TID${1000 + lastid + 1}";

    String first = "INSERT INTO `pcpn`.`masterlist` (`TRANSACTION_ID`, `PIN`, `LNAME`, `FNAME`, `MNAME`, `EXTNAME`, `DOB`, `CLIENT_TYPE`, `DOE`, `EFF_YEAR`, `NET_TOTAL`, `BALANCE`) ";
    String second = "VALUES ('$tid', '$pin', '$lname', '$fname', '$mname', '$ext', '$dob', '$clienttype', '$doe', '$effyear', '$net', '$balance')";
    String third = first + second;
    await conn.execute(third);

    var d = [];
    var result = await conn.execute("SELECT * FROM pcpn.masterlist");
    for (var element in result.rows) {
      d.add({
        'id': int.parse(element.assoc()['ID']!),
        'pin': element.assoc()['PIN'],
        'tid': element.assoc()['TRANSACTION_ID'],
        'lname': element.assoc()['LNAME'],
        'fname': element.assoc()['FNAME'],
        'mname': (element.assoc()['MNAME'] == null)? "" : element.assoc()['MNAME'],
        'ext': (element.assoc()['EXT'] == null)? "" : element.assoc()['EXT'],
        'dob': (element.assoc()['DOB'] == null)? "" : element.assoc()['DOB'],
        'type': element.assoc()['CLIENT_TYPE'],
        'doe': (element.assoc()['DOE'] == null)? "" : element.assoc()['DOE'],
        'effyear': element.assoc()['EFF_YEAR'],
        'net': double.parse(element.assoc()['NET_TOTAL']),
        'bal': double.parse(element.assoc()['BALANCE']),
      });
    }
    
    return Response.ok(jsonEncode({'response': d}), headers: {
      'Content-Type': 'application/json',
    });
  });

  router.post('/api/new-data-consultation', (Request request) async {
    final payload = await request.readAsString();
    final Map<String, dynamic> data = jsonDecode(payload);

    final mid = data['mid'];
    final tid = data['tid'];
    final pin = data['pin'];
    final lname = data['lname'];
    final fname = data['fname'];
    final mname = data['mname'];
    final ext = data['ext'];
    final dob = data['dob'];
    final clienttype = data['clienttype'];
    final effyear = data['effyear'];
    final condate = data['condate'];
    final firstencounter = data['firstencounter'];
    final epress = data['epress'];
    final ekas = data['ekas'];
    final paid = data['paid'];
    final facility = data['facility'];
    final diagnosis = data['diagnosis'];
    final labExist = data['lab_exist'];
    final medExist = data['med_exist'];

    String first = "INSERT INTO `pcpn`.`consultation` (`MEM_ID`, `TRANSACTION_ID`, `PIN`, `LNAME`, `FNAME`, `MNAME`, `EXTNAME`, `DOB`, `CLIENT_TYPE`, `EFF_YEAR`, `CONSULTATION_DATE`, `FIRST_ENCOUNTER`, `EPRESS`, `EKAS`, `PAID_BY_PHIC`, `FACILITY`, `DIAGNOSIS`) ";
    String second = "VALUES ('$mid','$tid','$pin','$lname','$fname','$mname','$ext','$dob','$clienttype','$effyear','$condate','$firstencounter','$epress','$ekas','$paid','$facility','$diagnosis')";
    String third = first + second;
    await conn.execute(third);

    if (labExist == "yes") {
      final labConsultID = data['lab_consultID'];
      final labHospital = data['lab_hospital'];
      final labRequest = data['lab_request'];
      final labAmount = data['lab_amount'];
      String first = "INSERT INTO `pcpn`.`laboratory` (`CONSULT_ID`, `HOSPITAL`, `LAB_REQUEST`, `AMOUNT`) ";
      String second = "VALUES ('$labConsultID', '$labHospital', '$labRequest', '$labAmount');";
      String third = first + second;
      await conn.execute(third);
    }
    
    if (medExist == "yes"){
      var x = data['meds'].toString().split('/');
      for (var element in x) {
        var k = element.split(",");
        if(k.length != 1) {
          String first = "INSERT INTO `pcpn`.`medicine` (`CONSULT_ID`, `MEDICINE`, `WEIGHT`, `QTY`, `AMOUNT`, `TOTAL`) ";
          String second = "VALUES ('${k[0]}', '${k[1]}', '${k[2]}', '${k[3]}', '${k[4]}', '${k[5]}');";
          String third = first + second;
          await conn.execute(third);
        }
      }
    }

    var con = [];
    var lab = [];
    var med = [];
    
    return Response.ok(jsonEncode({'consultation': con, 'laboratory': lab, 'medicine': med}), headers: {
      'Content-Type': 'application/json',
    });
  });

  //server configuration
  print("start server");
  try{
    var staticHandler = createStaticHandler(webpageLocation, defaultDocument: 'index.html');

    final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler((Request request) {
        if (request.url.path.startsWith('api/')) {
          return router(request);
        }
        return staticHandler(request);
      });
    
    serverDart = await io.serve(handler, serverIpAdd, int.parse(serverPort));
    print("Server Running: http://$serverIpAdd:$serverPort");
  } catch(e) {
    errorServer = 'SERVER: Unabled to launch server: Running: http://$serverIpAdd:$serverPort';
    print(errorServer);
    print(e);
  }
}

Future<void> mySqlConenction() async {
  conn = await MySQLConnection.createConnection(
    host: "172.17.254.40", 
    port: 3306, 
    userName: "Admin", 
    password: "admin",
    databaseName: "pcpn",
  );

  await conn.connect();
  print('Connected to MySql database');
  var result = await conn.execute("select pcpn.medicine.ID, pcpn.medicine.CONSULT_ID, pcpn.consultation.PIN, pcpn.consultation.LNAME, pcpn.consultation.FNAME, pcpn.consultation.MNAME, pcpn.consultation.EXTNAME, pcpn.consultation.CONSULTATION_DATE, pcpn.medicine.MEDICINE, pcpn.medicine.WEIGHT, pcpn.medicine.QTY, pcpn.medicine.AMOUNT, pcpn.medicine.TOTAL from pcpn.consultation join pcpn.medicine where pcpn.consultation.TRANSACTION_ID = pcpn.medicine.CONSULT_ID");
  print(result.rows.length);
}