import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_store_app/models/Store.dart';
import 'package:mobile_store_app/screens/welcome_screen.dart';
import 'package:mobile_store_app/service/user_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, dimensions) {
        final width = dimensions.maxWidth / 1.5;
        final height = dimensions.maxHeight / 3;
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300], // Couleur de fond si l'image charge mal
                    borderRadius: BorderRadius.circular(12), // Bords arrondis, // Optionnel : bordure,
                ),
                  child: Center(
                    child: Text("Mobile Store.dart", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold), ),

                  )
                ),
                SizedBox(width: width, height: height, child: LoginPage()),
              ],
            ),
          ),
        );
      },
    );
  }
}

class LoginPage extends StatelessWidget {
  Key _key = new GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _key,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: "Username"),
            controller: usernameController,
          ),
          TextFormField(
            decoration: InputDecoration(labelText: "Password"),
            controller: passwordController,
            obscureText: true,
          ),
          ElevatedButton(
            onPressed: () async {
              UserService userService = UserService();
              String username = usernameController.text.trim();
              String password  = passwordController.text.trim();
              bool response = await Future.value(userService.login(username: username, password: password));
              if(response == true){
                List<Store> stores= await Future.value(userService.getStoresByUser());
                Navigator.push(context, MaterialPageRoute(builder: (context) => WelcomeScreen(stores: stores)));
              }

            },
            child: Text("Login"),
          ),
        ],
      ),
    );
  }
}
