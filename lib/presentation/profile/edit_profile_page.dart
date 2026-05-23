import 'package:flutter/material.dart';

class EditProfilePage extends StatelessWidget {

  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(

              decoration: InputDecoration(

                hintText: "Nama",

                filled: true,

                fillColor: const Color(0xFF1A1A1A),

                border: OutlineInputBorder(

                  borderRadius: BorderRadius.circular(16),

                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(

              decoration: InputDecoration(

                hintText: "Email",

                filled: true,

                fillColor: const Color(0xFF1A1A1A),

                border: OutlineInputBorder(

                  borderRadius: BorderRadius.circular(16),

                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(

              width: double.infinity,
              height: 55,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(

                  backgroundColor: const Color(0xFFD4AF37),

                  foregroundColor: Colors.black,
                ),

                onPressed: () {

                  Navigator.pop(context);
                },

                child: const Text(

                  "Simpan",

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
    );
  }
}