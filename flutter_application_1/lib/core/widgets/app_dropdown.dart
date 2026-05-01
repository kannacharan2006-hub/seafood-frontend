import 'package:flutter/material.dart';

class AppDropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final ValueChanged<String?>? onChanged;
  final bool isRequired;
  final bool enabled;
  final Widget Function(BuildContext, String, bool)? itemAsString;

  const AppDropdown({
    super.key,
    this.value,
    required this.items,
    required this.label,
    this.hint = 'Select an option',
    this.prefixIcon,
    this.onChanged,
    this.isRequired = false,
    this.enabled = true,
    this.itemAsString,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: textColor,
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
              color: Colors.grey[300]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.03 * 255).round()),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                hint: Text(
                  hint,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 15,
                  ),
                ),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: colorScheme.primary,
                ),
                underline: const SizedBox(),
                borderRadius: BorderRadius.circular(12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Row(
                      children: [
                        if (prefixIcon != null) ...[
                          Icon(
                            prefixIcon,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 15,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: enabled ? onChanged : null,
                dropdownColor: Colors.white,
                focusColor: colorScheme.primary.withAlpha((0.1 * 255).round()),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AppDropdownWithSearch<T> extends StatelessWidget {
  final T? selectedItem;
  final List<T> items;
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final ValueChanged<T?>? onChanged;
  final bool isRequired;
  final bool enabled;
  final String Function(T)? itemAsString;
  final bool showSearchBox;
  final int maxHeight;

  const AppDropdownWithSearch({
    super.key,
    this.selectedItem,
    required this.items,
    required this.label,
    this.hint = 'Search and select',
    this.prefixIcon,
    this.onChanged,
    this.isRequired = false,
    this.enabled = true,
    this.itemAsString,
    this.showSearchBox = true,
    this.maxHeight = 300,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: textColor,
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.05 * 255).round()),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonFormField<T>(
            initialValue: selectedItem,
            isExpanded: true,
            isDense: false,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: colorScheme.primary, size: 20)
                  : null,
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.white,
            ),
            hint: Text(
              hint,
              style: TextStyle(color: Colors.grey[400]),
            ),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: colorScheme.primary,
            ),
            items: items.map((T item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(
                  itemAsString?.call(item) ?? item.toString(),
                  style: TextStyle(
                    fontSize: 15,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: enabled ? onChanged : null,
            dropdownColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

class OptimizedDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String label;
  final ValueChanged<T?>? onChanged;
  final String Function(T) itemLabel;
  final bool isLoading;
  final String? errorText;
  final IconData? leadingIcon;

  const OptimizedDropdown({
    super.key,
    this.value,
    required this.items,
    required this.label,
    required this.itemLabel,
    this.onChanged,
    this.isLoading = false,
    this.errorText,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null ? Colors.red : Colors.grey[300]!,
            ),
          ),
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton<T>(
                      value: value,
                      isExpanded: true,
                      underline: const SizedBox(),
                      icon: Icon(
                        Icons.arrow_drop_down_circle_outlined,
                        color: colorScheme.primary,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      items: items.map((T item) {
                        return DropdownMenuItem<T>(
                          value: item,
                          child: Row(
                            children: [
                              if (leadingIcon != null) ...[
                                Icon(
                                  leadingIcon,
                                  size: 18,
                                  color: colorScheme.secondary,
                                ),
                                const SizedBox(width: 8),
                              ],
                              Expanded(
                                child: Text(
                                  itemLabel(item),
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: textColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: onChanged,
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
