import 'package:flutter/material.dart';

class Daycard extends StatelessWidget {
  final String day;
  final String data;
  final VoidCallback onTap;

  const Daycard({
    super.key,
    required this.day,
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("$day",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text("20",
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          Text("/", style: TextStyle(fontSize: 24)),
                          Text("5", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Row(
                        children: [
                          Column(
                            children: [
                              Text('humidity', style: TextStyle(fontSize: 14, color: Colors.grey,)),
                              SizedBox(height: 4),
                              Text("80", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(width: 24),
                          Column(
                            children: [
                              Text("rain", style: TextStyle(fontSize: 14, color: Colors.grey)),
                              SizedBox(height: 4),
                              Text("15%", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ), 
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.cloud, size: 50, color: Colors.blue),
                      Text('weather description', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color.fromRGBO(255, 172, 51, 1))),
                    ],
                  ),
                ],
              ),
            ],
          )
        )
      )
    );
  }
}