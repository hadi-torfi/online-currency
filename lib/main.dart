// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'Currency.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fa'),
      ],
      theme: ThemeData(
        fontFamily: 'Yekan',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black),
          displayMedium: TextStyle(fontSize: 16, color: Colors.white),
          bodyLarge: TextStyle(
            color: Colors.green,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          bodySmall: TextStyle(
            color: Colors.red,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Currency> currency = [];

  Future getResponse() async {
    var url = "http://sasansafari.com/flutter/api.php?access_key=flutter123456";
    var response = await http.get(Uri.parse(url));
    if (currency.isEmpty) {
      if (response.statusCode == 200) {
        List jsonResponse = convert.jsonDecode(response.body);

        if (jsonResponse.isNotEmpty) {
          for (var i = 0; i < jsonResponse.length; i++) {
            setState(() {
              currency.add(Currency(
                  id: jsonResponse[i]['id'],
                  title: jsonResponse[i]['title'],
                  price: jsonResponse[i]['price'],
                  changes: jsonResponse[i]['changes'],
                  status: jsonResponse[i]['status']));
            });
          }
        }
        _getTime();
        _showSnackBar(context, 'اطلاعات با موفقیت به روز شد.');
      }
    }
    return response;
  }

  @override
  void initState() {
    super.initState();
    getResponse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 4, 0),
          child: Text(
            'قیمت به روز سکه و ارز',
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
            child: Icon(Icons.menu),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Column(children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/fav.png',
                  width: 40,
                  height: 40,
                ),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  'مشاهده لحظه ای ارز های مختلف',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
              child: Text(
                  'مشاهده نرخ کلیه ارزها در بازار آزاد شامل قیمت دلار، قیمت یورو، قیمت پوند، قیمت درهم، قیمت لیر، قیمت کرون، قیمت دینار و سایر ارزها و اطلاع از تغییرات لحظه‌ای'),
            ),
            //List Header
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height / 16,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1000),
                  color: Colors.blueGrey,
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'نام ارز',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      Text(
                        'قیمت',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      Text(
                        'تغییر',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ]),
              ),
            ),
            //ListView
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height / 2,
              child: listFutureBuilder(context),
            ),
            //Update Box
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height / 16,
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 232, 232, 232),
                    borderRadius: BorderRadius.circular(1000)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //btn Update
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 16,
                      child: TextButton.icon(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  const Color.fromARGB(255, 202, 193, 255))),
                          onPressed: () {
                            currency.clear();
                            listFutureBuilder(context);
                          },
                          icon: const Icon(CupertinoIcons.refresh_bold),
                          label: Text(
                            'به روز رسانی',
                            style: Theme.of(context).textTheme.displayLarge,
                          )),
                    ),
                    //txt Update
                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 0, 0, 0),
                      child: Text('آخرین به روز رسانی ${_getTime()}'),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  FutureBuilder<dynamic> listFutureBuilder(BuildContext context) {
    return FutureBuilder(
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: currency.length,
                itemBuilder: (BuildContext context, int position) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                    child: MyListItem(position, currency),
                  );
                })
            : const Center(
                child: CircularProgressIndicator(),
              );
      },
      future: getResponse(),
    );
  }

  String _getTime() {
    return currency.isNotEmpty
        ? DateFormat('kk:mm:ss').format(DateTime.now())
        : '--:--:--';
  }
}

@immutable
class MyListItem extends StatelessWidget {
  final int position;
  final List<Currency> currency;
  const MyListItem(this.position, this.currency, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 16,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1000),
        color: Colors.white,
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Colors.grey,
            blurRadius: 1,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            currency[position].title!,
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Text(
            currency[position].price!,
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Text(
            currency[position].changes!,
            style: currency[position].status == 'n'
                ? Theme.of(context).textTheme.bodySmall
                : Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

_showSnackBar(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.green,
      content: Center(
        child: Text(
          msg,
        ),
      )));
}
