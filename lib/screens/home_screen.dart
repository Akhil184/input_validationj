import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/date_input_utils.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'HomePage',
            style: TextStyle(color: Colors.white), // Set custom text color
          ),
        ),
        backgroundColor: Colors.blue, // Set AppBar background color if needed
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.1, // 10% of the screen width
            vertical: MediaQuery.of(context).size.height * 0.05, // 5% of the screen height
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [TextInputValidtion()],
                  decoration: InputDecoration(
                    labelText: 'Enter Date(DD-MM-YYYY)',
                    hintText:'Enter Date',
                    border: OutlineInputBorder(),
                  ),
                  validator: dateValidator,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02), // 2% of the screen height
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Date is valid!')),
                      );
                    }
                  },
                  child: Text('Submit',style:TextStyle(color:Colors.white),),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    backgroundColor: Colors.orangeAccent,
                    side: BorderSide(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}