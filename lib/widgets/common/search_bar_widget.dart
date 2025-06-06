import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String) onSearchChanged;
  const SearchBarWidget({super.key, required this.onSearchChanged});
  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      widget.onSearchChanged(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white), // Màu chữ khi nhập
        decoration: const InputDecoration(
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.white54),
          hintText: 'Find your drink ...',
          hintStyle: TextStyle(color: Color.fromARGB(143, 255, 255, 255)),
        ),
      ),
    );
  }
}
