import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class ModToolsScreen extends StatelessWidget {
  final String name;
  const ModToolsScreen({super.key, required this.name});
  void navigateToModTools(BuildContext context) {
    Routemaster.of(context).push("/edit-community/$name");
  }

  void navigateToAddMods(BuildContext context) {
    Routemaster.of(context).push("/add-mods/$name");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Mod Tools"),
      ),
      body: Column(
        children: [
          ListTile(
            leading: Icon(Icons.add_moderator_rounded),
            title: Text("Add Modarators"),
            onTap: () => navigateToAddMods(context),
          ),
          ListTile(
            leading: Icon(Icons.edit_attributes_outlined),
            title: Text("Edit Modarators"),
            onTap: () => navigateToModTools(context),
          ),
        ],
      ),
    );
  }
}
