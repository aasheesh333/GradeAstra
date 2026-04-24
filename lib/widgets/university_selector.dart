import 'package:flutter/material.dart';
import '../models/university_model.dart';

class UniversitySelector extends StatefulWidget {
  final List<UniversityModel> universities;
  final UniversityModel selectedUniversity;
  final ValueChanged<UniversityModel> onChanged;

  const UniversitySelector({
    Key? key,
    required this.universities,
    required this.selectedUniversity,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<UniversitySelector> createState() => _UniversitySelectorState();
}

class _UniversitySelectorState extends State<UniversitySelector> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<UniversityModel>(
            value: widget.selectedUniversity,
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down),
            onChanged: (UniversityModel? newValue) {
              if (newValue != null) {
                widget.onChanged(newValue);
              }
            },
            items: widget.universities.map<DropdownMenuItem<UniversityModel>>((UniversityModel u) {
              return DropdownMenuItem<UniversityModel>(
                value: u,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      u.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${u.shortName} • ${u.state}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
