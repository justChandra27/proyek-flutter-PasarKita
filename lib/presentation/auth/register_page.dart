import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {

  const RegisterPage({super.key});

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

                "Create Account",

                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(

                "Daftar untuk mulai berbelanja",

                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 50),

              // NAME
              TextField(

                decoration: InputDecoration(

                  hintText: "Nama Lengkap",

                  prefixIcon: const Icon(Icons.person),

                  filled: true,

                  fillColor: const Color(0xFF1A1A1A),

                  border: OutlineInputBorder(

                    borderRadius: BorderRadius.circular(16),

                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

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

                    Navigator.pop(context);
                  },

                  child: const Text(

                    "Register",

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}