import 'package:flutter/material.dart';

class InlineGenderSelector extends StatefulWidget {
  final String? selectedGender;
  final List<String> genders;
  final Function(String) onGenderSelected;
  final String title;
  final Color cardBackgroundColor;
  final Color itemBackgroundColor;
  final Color selectedItemBackgroundColor;
  final Color textColor;
  final Color selectedTextColor;
  final Color dividerColor;
  final Color internalDividerColor;
  final Color headerTextColor;

  const InlineGenderSelector({
    super.key,
    required this.selectedGender,
    required this.genders,
    required this.onGenderSelected,
    this.title = 'Género',
    this.cardBackgroundColor = const Color.fromRGBO(62, 65, 69, 1),
    this.itemBackgroundColor = const Color.fromRGBO(62, 65, 69, 1),
    this.selectedItemBackgroundColor =
        const Color.fromRGBO(217, 217, 217, 0.15),
    this.textColor = const Color.fromRGBO(159, 162, 169, 1),
    this.selectedTextColor = Colors.white,
    this.dividerColor = const Color.fromRGBO(255, 255, 255, 1),
    this.internalDividerColor = const Color.fromRGBO(168, 168, 168, 0.25),
    this.headerTextColor = const Color.fromRGBO(159, 162, 169, 1),
  });

  @override
  State<InlineGenderSelector> createState() => _InlineGenderSelectorState();
}

class _InlineGenderSelectorState extends State<InlineGenderSelector> {
  late String? _currentSelection;

  @override
  void initState() {
    super.initState();
    _currentSelection = widget.selectedGender;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: widget.cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            alignment: Alignment.center,
            child: Text(
              widget.title,
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'AvenirDemiBold',
                color: widget.headerTextColor,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Divider(color: widget.dividerColor, height: 1),
          ...widget.genders.map((gender) {
            final bool isSelected = _currentSelection == gender;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    setState(() => _currentSelection = gender);
                    Future.delayed(const Duration(milliseconds: 250), () {
                      if (mounted) widget.onGenderSelected(gender);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14.0, horizontal: 16.0),
                    alignment: Alignment.center,
                    color: isSelected
                        ? widget.selectedItemBackgroundColor
                        : widget.itemBackgroundColor,
                    child: Text(
                      gender,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily:
                            isSelected ? 'AvenirBold' : 'AvenirRegular',
                        color: isSelected
                            ? widget.selectedTextColor
                            : widget.textColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
                if (gender != widget.genders.last)
                  Divider(
                      color: widget.internalDividerColor,
                      height: 1,
                      indent: 0,
                      endIndent: 0),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class InlineDatePicker extends StatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime) onDateChanged;
  final String title;
  final int startYear;
  final int endYear;
  final Color cardBackgroundColor;
  final Color itemBackgroundColor;
  final Color selectedItemBackgroundColor;
  final Color textColor;
  final Color selectedTextColor;
  final Color dividerColor;
  final Color headerTextColor;

  InlineDatePicker({
    super.key,
    this.initialDate,
    required this.onDateChanged,
    this.title = 'Fecha de nacimiento',
    this.startYear = 1900,
    int? endYear,
    this.cardBackgroundColor = const Color.fromRGBO(62, 65, 69, 1),
    this.itemBackgroundColor = Colors.transparent,
    this.selectedItemBackgroundColor =
        const Color.fromRGBO(217, 217, 217, 0.15),
    this.textColor = const Color.fromRGBO(159, 162, 169, 1),
    this.selectedTextColor = Colors.white,
    this.dividerColor = const Color.fromRGBO(255, 255, 255, 1),
    this.headerTextColor = const Color.fromRGBO(159, 162, 169, 1),
  }) : endYear = endYear ?? DateTime.now().year;

  @override
  State<InlineDatePicker> createState() => _InlineDatePickerState();
}

class _InlineDatePickerState extends State<InlineDatePicker> {
  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _yearController;

  late int _selectedDay;
  late int _selectedMonth;
  late int _selectedYear;

  List<int> _days = [];
  final List<String> _months = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];
  List<int> _years = [];

  final double _horizontalCarouselPadding = 10.0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = widget.initialDate?.day ?? now.day;
    _selectedMonth = widget.initialDate?.month ?? now.month;
    _selectedYear = widget.initialDate?.year ?? now.year;

    _years = List<int>.generate(
        widget.endYear - widget.startYear + 1, (i) => widget.startYear + i);

    if (_selectedYear < widget.startYear) _selectedYear = widget.startYear;
    if (_selectedYear > widget.endYear) _selectedYear = widget.endYear;

    _updateDaysInMonth();

    _dayController = FixedExtentScrollController(
        initialItem:
            _days.isNotEmpty ? _days.indexOf(_selectedDay).clamp(0, _days.length - 1) : 0);
    _monthController =
        FixedExtentScrollController(initialItem: _selectedMonth - 1);
    _yearController = FixedExtentScrollController(
        initialItem:
            _years.isNotEmpty ? _years.indexOf(_selectedYear).clamp(0, _years.length - 1) : 0);
  }

  void _updateDaysInMonth() {
    final daysInMonth =
        DateUtils.getDaysInMonth(_selectedYear, _selectedMonth);
    _days = List<int>.generate(daysInMonth, (i) => i + 1);

    if (_selectedDay > daysInMonth) {
      _selectedDay = daysInMonth;
      if (_dayController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_dayController.hasClients && _days.isNotEmpty) {
            final targetIndex = _days.indexOf(_selectedDay);
            if (targetIndex != -1) _dayController.jumpToItem(targetIndex);
          }
        });
      }
    }
  }

  void _notifyDateChanged() {
    widget.onDateChanged(DateTime(_selectedYear, _selectedMonth, _selectedDay));
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  double _getItemExtent() => 40.0;

  TextStyle _getSelectedItemStyle() => TextStyle(
        fontSize: 18,
        fontFamily: 'AvenirBold',
        color: widget.selectedTextColor,
        letterSpacing: -0.5,
      );

  TextStyle _getItemStyle() => TextStyle(
        fontSize: 16,
        fontFamily: 'AvenirRegular',
        color: widget.textColor,
        letterSpacing: -0.5,
      );

  Widget _buildPickerColumn({
    required FixedExtentScrollController controller,
    required List<dynamic> items,
    required Function(int) onSelectedItemChanged,
    bool isMonth = false,
    bool isDay = false,
  }) {
    if (items.isEmpty) return Expanded(child: Container());
    return Expanded(
      child: SizedBox(
        height: 150,
        child: ListWheelScrollView.useDelegate(
          controller: controller,
          itemExtent: _getItemExtent(),
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: onSelectedItemChanged,
          childDelegate: ListWheelChildLoopingListDelegate(
            children: items.asMap().entries.map<Widget>((entry) {
              final int index = entry.key;
              final dynamic item = entry.value;
              final displayValue = isMonth
                  ? item as String
                  : (item as int).toString().padLeft(2, '0');
              bool isSelected;
              if (isMonth) {
                isSelected = (_months.indexOf(item as String) + 1) == _selectedMonth;
              } else if (isDay) {
                isSelected = (item as int) == _selectedDay;
              } else {
                isSelected = (item as int) == _selectedYear;
              }
              return GestureDetector(
                onTap: () => controller.animateToItem(
                  index,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                ),
                child: Container(
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: Text(
                    displayValue,
                    style: isSelected ? _getSelectedItemStyle() : _getItemStyle(),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: widget.cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            alignment: Alignment.center,
            child: Text(
              widget.title,
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'AvenirDemiBold',
                color: widget.headerTextColor,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Divider(color: widget.dividerColor, height: 1),
          Container(
            color: widget.itemBackgroundColor,
            height: 150,
            padding:
                EdgeInsets.symmetric(horizontal: _horizontalCarouselPadding),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 15.0,
                  right: 15.0,
                  top: (150 - _getItemExtent()) / 2,
                  height: _getItemExtent(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.selectedItemBackgroundColor,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                Row(
                  children: [
                    _buildPickerColumn(
                      controller: _dayController,
                      items: _days,
                      isDay: true,
                      onSelectedItemChanged: (index) {
                        if (_days.isEmpty) return;
                        setState(() {
                          _selectedDay = _days[index % _days.length];
                          _notifyDateChanged();
                        });
                      },
                    ),
                    _buildPickerColumn(
                      controller: _monthController,
                      items: _months,
                      isMonth: true,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedMonth = index % _months.length + 1;
                          _updateDaysInMonth();
                          _notifyDateChanged();
                        });
                      },
                    ),
                    _buildPickerColumn(
                      controller: _yearController,
                      items: _years,
                      onSelectedItemChanged: (index) {
                        if (_years.isEmpty) return;
                        setState(() {
                          _selectedYear = _years[index % _years.length];
                          _updateDaysInMonth();
                          _notifyDateChanged();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
