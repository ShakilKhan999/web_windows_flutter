import 'package:flutter/material.dart';

class SpotlightWidget extends StatelessWidget {
  final VoidCallback onClose;

  const SpotlightWidget({Key? key, required this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      height: 60,
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ask anything...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
          _buildButton(Icons.format_align_left, 'Focus'),
          _buildButton(Icons.add, 'Attach'),
          SizedBox(width: 10),
          Switch(
            value: false,
            onChanged: (_) {},
            activeColor: Colors.green,
          ),
          SizedBox(width: 10),
          Text(
            'Pro',
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildButton(IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, color: Colors.grey),
        onPressed: () {},
      ),
    );
  }
}