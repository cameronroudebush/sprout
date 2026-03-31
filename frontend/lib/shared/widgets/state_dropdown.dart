import 'package:flutter/material.dart';

/// A standardized US State selection dropdown
class UsStateDropdownField extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  final String label;
  final bool isRequired;

  const UsStateDropdownField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = "State",
    this.isRequired = true,
  });

  static const List<String> _states = [
    'AL',
    'AK',
    'AZ',
    'AR',
    'CA',
    'CO',
    'CT',
    'DE',
    'FL',
    'GA',
    'HI',
    'ID',
    'IL',
    'IN',
    'IA',
    'KS',
    'KY',
    'LA',
    'ME',
    'MD',
    'MA',
    'MI',
    'MN',
    'MS',
    'MO',
    'MT',
    'NE',
    'NV',
    'NH',
    'NJ',
    'NM',
    'NY',
    'NC',
    'ND',
    'OH',
    'OK',
    'OR',
    'PA',
    'RI',
    'SC',
    'SD',
    'TN',
    'TX',
    'UT',
    'VT',
    'VA',
    'WA',
    'WV',
    'WI',
    'WY'
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      menuMaxHeight: 364,
      value: value,
      hint: Text(label),
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      items: _states.map((state) {
        return DropdownMenuItem<String>(
          value: state,
          child: Text(state, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: onChanged,
      validator: isRequired ? (v) => v == null ? "Required" : null : null,
    );
  }
}
