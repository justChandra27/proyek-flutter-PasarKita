import 'package:flutter/material.dart';

import 'register_page.dart';
import '../navigation/navigation_page.dart';

class LoginPage extends StatelessWidget {

  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(24),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 40),

              // TITLE
              const Text(

                "Welcome Back",

                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(

                "Login untuk melanjutkan belanja",

                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 50),

              // EMAIL
              TextField(

                decoration: InputDecoration(

                  hintText: "Email",

                  prefixIcon: const Icon(Icons.email),

                  filled: true,

                  fillColor: const Color(0xFF1A1A1A),

                  border: OutlineInputBorder(

                    borderRadius: BorderRadius.circular(16),

                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // PASSWORD
              TextField(

                obscureText: true,

                decoration: InputDecoration(

                  hintText: "Password",

                  prefixIcon: const Icon(Icons.lock),

                  filled: true,

                  fillColor: const Color(0xFF1A1A1A),

                  border: OutlineInputBorder(

                    borderRadius: BorderRadius.circular(16),

                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // BUTTON
              SizedBox(

                width: double.infinity,
                height: 55,

                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(

                    backgroundColor: const Color(0xFFD4AF37),

                    foregroundColor: Colors.black,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),

                  onPressed: () {

  Navigator.pushReplacement(

    context,

    MaterialPageRoute(
      builder: (_) => const NavigationPage(),
    ),
  );
},

                  child: const Text(

                    "Login",

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // REGISTER
              Row(

                mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  const Text(
                    "Belum punya akun?",
                  ),

                  TextButton(

                    onPressed: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(
                          builder: (_) => const RegisterPage(),
                        ),
                      );
                    },

                    child: const Text(

                      "Register",

                      style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}