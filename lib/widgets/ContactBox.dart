import 'package:flutter/material.dart';
import '../Voice_Functions.dart';
import '../widgets/UserImg.dart';

class ContactWidget extends StatefulWidget {
  final String name;
  final String? image; // Make image property nullable

  final void Function() onTap;

  const ContactWidget({
    Key? key,
    required this.name,
    required this.onTap,
    this.image,
  }) : super(key: key);

  @override
  _ContactWidgetState createState() => _ContactWidgetState();
}

class _ContactWidgetState extends State<ContactWidget> {
  bool isPressed = false;
  bool incorrectImagePath = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        setState(() {
          isPressed = true;
        });
        voice(widget.name);
      },
      onLongPressEnd: (_) {
        setState(() {
          isPressed = false;
        });
      },
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isPressed ? Colors.grey.withOpacity(0.2) : Colors.blue[50],
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            children: [
              UserImg(image: widget.image,),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }



}
