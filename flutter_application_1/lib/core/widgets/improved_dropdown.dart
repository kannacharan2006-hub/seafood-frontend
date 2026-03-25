import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

class ImprovedDropdownSearch<T> extends StatelessWidget {
  final T? selectedItem;
  final List<T> items;
  final String hintText;
  final IconData? prefixIcon;
  final ValueChanged<T?>? onChanged;
  final String Function(T)? itemAsString;
  final bool showSearchBox;
  final bool enabled;
  final String? label;
  final bool isRequired;
  final Widget? suffixIcon;

  const ImprovedDropdownSearch({
    super.key,
    this.selectedItem,
    required this.items,
    this.hintText = 'Search and select',
    this.prefixIcon,
    this.onChanged,
    this.itemAsString,
    this.showSearchBox = true,
    this.enabled = true,
    this.label,
    this.isRequired = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text(
                  label!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF3C3C43),
                  ),
                ),
                if (isRequired)
                  const Text(
                    ' *',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownSearch<T>(
            selectedItem: selectedItem,
            items: items,
            itemAsString: itemAsString,
            enabled: enabled,
            compareFn: (item1, item2) {
              if (itemAsString != null) {
                return itemAsString!(item1) == itemAsString!(item2);
              }
              return item1 == item2;
            },
            popupProps: PopupProps.menu(
              showSearchBox: showSearchBox,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              menuProps: MenuProps(
                borderRadius: BorderRadius.circular(16),
                elevation: 8,
              ),
            ),
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                prefixIcon: prefixIcon != null
                    ? Icon(
                        prefixIcon,
                        color: const Color(0xFF2563EB),
                      )
                    : null,
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 15,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF2563EB),
                    width: 2,
                  ),
                ),
              ),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class ImprovedDropdownButton<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String label;
  final String hintText;
  final IconData? prefixIcon;
  final ValueChanged<T?>? onChanged;
  final String Function(T)? itemAsString;
  final bool enabled;
  final bool isRequired;
  final String? errorText;

  const ImprovedDropdownButton({
    super.key,
    this.value,
    required this.items,
    required this.label,
    this.hintText = 'Select',
    this.prefixIcon,
    this.onChanged,
    this.itemAsString,
    this.enabled = true,
    this.isRequired = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF3C3C43),
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null
                  ? Colors.red
                  : const Color(0xFFE8E8E8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                hint: Row(
                  children: [
                    if (prefixIcon != null) ...[
                      Icon(
                        prefixIcon,
                        size: 18,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      hintText,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                underline: const SizedBox(),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF2563EB),
                ),
                borderRadius: BorderRadius.circular(12),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                items: items.map((T item) {
                  return DropdownMenuItem<T>(
                    value: item,
                    child: Row(
                      children: [
                        if (prefixIcon != null) ...[
                          Icon(
                            prefixIcon,
                            size: 18,
                            color: const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            itemAsString?.call(item) ?? item.toString(),
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: enabled ? onChanged : null,
                dropdownColor: Colors.white,
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
