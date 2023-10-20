import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class StoryScreen extends StatefulWidget
{
  final String Path;
  final DateTime TimeTaken;
  final String StoryPath;

  final bool hasDescrip;

  const StoryScreen({
    super.key, 
    required this.Path, 
    this.hasDescrip = true,
    required this.TimeTaken, 
    required this.StoryPath
    });

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
              width: screenWidth - 150,
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
          ClipRRect(
            borderRadius: BorderRadius.circular(16.0), // border radius for a FAB
            child: FloatingActionButton(
              onPressed: () {},
              elevation: 0,
              tooltip: "",
              child: Image.asset("assets/StoryImages/${widget.StoryPath}"),
            ),
          )
          ],
        )
      ),

    );
  }
}
