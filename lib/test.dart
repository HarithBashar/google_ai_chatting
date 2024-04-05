import 'package:flutter/material.dart';

void main() {
  runApp(
    const HomeWork(),
  );
}

class HomeWork extends StatelessWidget {
  const HomeWork({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Flutter Mini Task",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Center(
            child: Wrap(
              children: [
                for (int i = 1; i <= 20; i++)
                  Container(
                    height: 40,
                    width: 70,
                    margin: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: i.isOdd ? Colors.purple : Colors.blue,
                    ),
                    alignment: Alignment.center,
                    child: Text("Item $i"),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, i) {
                return ListTile(
                  title: Text("Item ${i + 1}",
                      style: const TextStyle(color: Colors.black)),
                  subtitle: Text("Description of Item ${i + 1}",
                      style: const TextStyle(color: Colors.black)),
                );
              },
              separatorBuilder: (context, index) {
                return const Divider(height: 0);
              },
              itemCount: 9,
            ),
          )
        ],
      ),
    );
  }
}
