import 'package:flutter/material.dart';
import 'package:fstory/common/styles.dart';
import 'package:fstory/presentation/widgets/btn_primary.dart';
import 'package:fstory/presentation/widgets/loading.dart';
import 'package:provider/provider.dart';
import '../providers/auth_notifier.dart';

class LoginPage extends StatefulWidget {
  final Function() isLoggedIn;
  final Function() isRegisterClicked;

  const LoginPage(
      {super.key, required this.isLoggedIn, required this.isRegisterClicked});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _email = "";
  String _password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Padding(
        padding: const EdgeInsets.only(left: 32, right: 32, top: 128),
        child: ListView(children: [
          Center(
            child: Image.asset(
              'assets/logo/logo.png',
              height: 150,
              width: 150,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            "Email",
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.bodyLarge!,
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.fromLTRB(26, 14, 4, 14),
              hintText: 'Enter your email...',
              hintStyle: Theme.of(context).textTheme.bodyLarge,
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: primaryGray, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: primaryColor, width: 1),
              ),
            ),
            onChanged: (inputEmail) {
              setState(() {
                _email = inputEmail;
              });
            },
          ),
          const SizedBox(height: 16),
          Text(
            "Password",
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.bodyLarge!,
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.fromLTRB(26, 14, 4, 14),
              hintText: 'Enter your password...',
              hintStyle: Theme.of(context).textTheme.bodyLarge,
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: primaryGray, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: primaryColor, width: 1),
              ),
            ),
            onChanged: (inputPassword) {
              setState(() {
                _password = inputPassword;
              });
            },
            obscureText: true,
          ),
          const SizedBox(height: 48),
          context.watch<AuthNotifier>().loginLoading
              ? const Loading()
              : BtnPrimary(
                  title: 'Login',
                  onClick: () {
                    _loginUser();
                  },
                ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Doesn't have account?",
                style: Theme.of(context).textTheme.bodyLarge!,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    widget.isRegisterClicked();
                  });
                },
                child: Text(
                  " Register Now",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: Colors.blue),
                ),
              )
            ],
          )
        ]),
      )),
    );
  }

  void _loginUser() async {
    final ScaffoldMessengerState scaffoldMessengerState =
        ScaffoldMessenger.of(context);
    final authNotifier = context.read<AuthNotifier>();
    if (_email == "" || _password == "") {
      scaffoldMessengerState.showSnackBar(
        const SnackBar(content: Text("Please insert email and password!")),
      );
      return;
    }
    if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(_email)) {
      scaffoldMessengerState.showSnackBar(
        const SnackBar(content: Text("Please enter valid email address!")),
      );
      return;
    }
    if (_password.length < 8) {
      scaffoldMessengerState.showSnackBar(
        const SnackBar(
            content: Text("Password must contain minimal 8 character")),
      );
      return;
    }
    await authNotifier.login(_email, _password);

    // ignore: use_build_context_synchronously
    Provider.of<AuthNotifier>(context, listen: false).errorMsg == null
        ? {
            scaffoldMessengerState.showSnackBar(
              SnackBar(
                  content: Text("Welcome ${authNotifier.loginEntity?.name}!")),
            ),
            widget.isLoggedIn()
          }
        : scaffoldMessengerState.showSnackBar(
            SnackBar(content: Text(authNotifier.errorMsg ?? "Login Failed")),
          );
  }
}
