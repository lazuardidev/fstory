import 'package:flutter/material.dart';
import 'package:fstory/common/styles.dart';
import 'package:fstory/presentation/provider/auth_provider.dart';
import 'package:fstory/presentation/widget/btn_primary.dart';
import 'package:fstory/presentation/widget/loading.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  final Function() isSuccessfulyRegistered;

  const RegisterPage({
    super.key,
    required this.isSuccessfulyRegistered,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? _email = "";
  String? _password = "";
  String? _name = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: ListView(
        children: [
          Center(
            child: Image.asset(
              'assets/logo/logo.png',
              height: 150,
              width: 150,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            "Name",
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.bodyLarge!,
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.fromLTRB(26, 14, 4, 14),
              hintText: 'Enter your name...',
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
            onChanged: (inputName) {
              setState(() {
                _name = inputName;
              });
            },
          ),
          const SizedBox(height: 16),
          Text(
            "Email",
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.bodyLarge!,
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.fromLTRB(26, 14, 4, 14),
              hintText: 'Enter your valid email...',
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
              hintText: 'Enter password with minimum 8 char...',
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
          context.watch<AuthProvider>().registerLoading
              ? const Loading()
              : BtnPrimary(
                  title: 'Register',
                  onClick: () {
                    _registerNewAccount();
                  },
                ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already have account?",
                style: Theme.of(context).textTheme.bodyLarge!,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    widget.isSuccessfulyRegistered();
                  });
                },
                child: Text(
                  " Login Now",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: Colors.blue),
                ),
              )
            ],
          )
        ],
      ),
    ));
  }

  void _registerNewAccount() async {
    final ScaffoldMessengerState scaffoldMessengerState =
        ScaffoldMessenger.of(context);
    final authProvider = context.read<AuthProvider>();

    if (_name == "" || _email == "") {
      scaffoldMessengerState.showSnackBar(
        const SnackBar(content: Text("Please fill the form correctly!")),
      );
      return;
    }
    if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(_email!)) {
      scaffoldMessengerState.showSnackBar(
        const SnackBar(content: Text("Please enter valid email address!")),
      );
      return;
    }
    if (_password!.length < 8) {
      scaffoldMessengerState.showSnackBar(
        const SnackBar(
            content: Text("Password must contain minimal 8 character")),
      );
      return;
    }
    await authProvider.register(_name!, _email!, _password!);

    Provider.of<AuthProvider>(context, listen: false).errorMsg == null
        ? {
            scaffoldMessengerState.showSnackBar(
              SnackBar(
                  content:
                      Text(authProvider.responseMsg ?? "Register Success")),
            ),
            widget.isSuccessfulyRegistered()
          }
        : scaffoldMessengerState.showSnackBar(
            SnackBar(content: Text(authProvider.errorMsg ?? "Register Failed")),
          );
  }
}
