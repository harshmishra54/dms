import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:flutter/material.dart';

class MultiSelectDropdownWithSearch extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final String label;
  final Function(List<Map<String, dynamic>>) onSelectionChanged;

  const MultiSelectDropdownWithSearch({
    super.key,
    required this.items,
    required this.label,
    required this.onSelectionChanged,
  });

  @override
  State<MultiSelectDropdownWithSearch> createState() =>
      _MultiSelectDropdownWithSearchState();
}

class _MultiSelectDropdownWithSearchState
    extends State<MultiSelectDropdownWithSearch> {
  late List<Map<String, dynamic>> _items;
  final TextEditingController _searchController = TextEditingController();
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    _items = widget.items.map((e) => {...e, "selected": e["selected"] ?? false}).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            List<Map<String, dynamic>> filtered = _items
                .where((d) => d["name"]
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
                .toList();

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔍 Search bar
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: "Search...",
                      prefixIcon: Icon(Icons.search, size: 20),
                    ),
                    onChanged: (_) => setSheetState(() {}),
                  ),
                  const SizedBox(height: 8),

                  // ✅ Select All
                  CheckboxListTile(
                    title: const AutoTranslateText("Select All"),
                    value: _selectAll,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (val) {
                      setSheetState(() {
                        _selectAll = val ?? false;
                        for (var d in _items) {
                          d["selected"] = _selectAll;
                        }
                      });
                      setState(() {}); // update parent
                      widget.onSelectionChanged(
                          _items.where((d) => d["selected"]).toList());
                    },
                  ),

                  // ✅ List of items
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return CheckboxListTile(
                          title: Text(item["name"]),
                          value: item["selected"],
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (val) {
                            setSheetState(() {
                              item["selected"] = val ?? false;
                              _selectAll = _items.every((d) => d["selected"]);
                            });
                            setState(() {}); // refresh parent instantly
                            widget.onSelectionChanged(
                                _items.where((d) => d["selected"]).toList());
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> selectedItems =
    _items.where((d) => d["selected"]).toList();

    return InkWell(
      onTap: _openBottomSheet,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.label,
          border: const OutlineInputBorder(),
        ),
        child: selectedItems.isNotEmpty
            ? Wrap(
          spacing: 6,
          children: selectedItems
              .map((d) => Chip(
            label: Text(d["name"]),
            onDeleted: () {
              setState(() {
                d["selected"] = false;
                _selectAll = false;
              });
              widget.onSelectionChanged(
                  _items.where((d) => d["selected"]).toList());
            },
          ))
              .toList(),
        )
            : Text("Select ${widget.label}",
            style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ),
    );
  }
}
