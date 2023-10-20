import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';


class StoryScreen extends StatefulWidget
{
  final String Path;
  final DateTime TimeTaken;

  final bool hasDescrip;

  const StoryScreen({super.key, required this.Path, this.hasDescrip = true, required this.TimeTaken});

  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  @override
  void initState()
  {
    super.initState();
  }

  String description = "lorem ipsum";

  @override
  Widget build(BuildContext context)
  {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
      ),
      body:
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Gap(10),
            Text(
              DateFormat("yyyy-MM-dd HH:mm").format(widget.TimeTaken),
              style: TextStyle(
                color: Theme.of(context).colorScheme.scrim,
                fontSize: 26,
                fontWeight: FontWeight.normal,
              ),
            ),
            SizedBox(
              width: screenWidth - 50,
                child: Image.file(
                  File(widget.Path),
                  fit: BoxFit.cover,
              ),
            ),
            //Gap(10),
            if (widget.hasDescrip) Text(description),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          children: [
           Expanded(
             child:
              Row(
               children: [
                 IconButton(
                   icon: const Icon(Icons.delete_outline),
                   tooltip: "Delete Story",
                   onPressed: () {},
                 ),
                 IconButton(
                   icon: const Icon(Icons.share_outlined),
                   tooltip: "Share Story",
                   onPressed: () {},
                 ),
                 IconButton(
                   icon: const Icon(Icons.settings_outlined),
                   tooltip: "More settings",
                   onPressed: () {},
                 ),
               ],
             ),
           ),
          FloatingActionButton(
            onPressed: () {},
            elevation: 0,
            tooltip: "",
            child: Image.asset("assets/StoryImages/day63-school-bag.png"),
            )
          ],
        )
      ),

    );
  }
}
