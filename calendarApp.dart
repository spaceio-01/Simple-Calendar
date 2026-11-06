import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:table_calendar/table_calendar.dart';

/// ГЛАВНОЕ ПРИЛОЖЕНИЕ
class CalendarApp extends StatefulWidget {
  const CalendarApp({super.key});

  @override
  State<CalendarApp> createState() => _CalendarAppState();
}

class _CalendarAppState extends State<CalendarApp> {
  Locale _locale = const Locale('ru');

  void _toggleLanguage() {
    setState(() {
      _locale = _locale.languageCode == 'ru' ? const Locale('en') : const Locale('ru');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      supportedLocales: const [
        Locale('ru'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      title: 'Calendar Homework',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: CalendarPage(onToggleLanguage: _toggleLanguage),
    );
  }
}

/// ЭКРАН КАЛЕНДАРЯ
class CalendarPage extends StatefulWidget {
  final VoidCallback onToggleLanguage;
  const CalendarPage({super.key, required this.onToggleLanguage});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  final Map<DateTime, List<String>> _events = {};

  List<String> _getEventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _events[key] ?? [];
  }

  String _formatNumber(int number) {
    return number.toString().padLeft(2, '0');
  }

  void _addEvent() {
    final controller = TextEditingController();
    final isRu = Localizations.localeOf(context).languageCode == 'ru';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isRu ? 'Новое событие' : 'New Event'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: isRu ? 'Название события' : 'Event Title',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isRu ? 'Отмена' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final key = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
                setState(() {
                  _events.putIfAbsent(key, () => []);
                  _events[key]!.add(controller.text.trim());
                });
              }
              Navigator.pop(context);
            },
            child: Text(isRu ? 'Добавить' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _editEvent(int index, String currentText) {
    final controller = TextEditingController(text: currentText);
    final isRu = Localizations.localeOf(context).languageCode == 'ru';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isRu ? 'Редактировать событие' : 'Edit Event'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: isRu ? 'Название события' : 'Event Title',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isRu ? 'Отмена' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final key = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
                setState(() {
                  _events[key]?[index] = controller.text.trim();
                });
              }
              Navigator.pop(context);
            },
            child: Text(isRu ? 'Сохранить' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _deleteEvent(int index) {
    final key = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    setState(() {
      _events[key]?.removeAt(index);
      if (_events[key]?.isEmpty ?? false) {
        _events.remove(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final events = _getEventsForDay(_selectedDay);
    final isRu = Localizations.localeOf(context).languageCode == 'ru';

    return Scaffold(
      appBar: AppBar(
        title: Text(isRu ? 'Календарь' : 'Calendar'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: widget.onToggleLanguage,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEvent,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: Localizations.localeOf(context).languageCode,
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2030),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getEventsForDay,
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isRu
                ? 'Выбранная дата: ${_formatNumber(_selectedDay.day)}.${_formatNumber(_selectedDay.month)}.${_selectedDay.year}'
                : 'Selected date: ${_formatNumber(_selectedDay.month)}/${_formatNumber(_formatNumber(_selectedDay.day).runtimeType == String ? _selectedDay.day : 1)}/${_selectedDay.year}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: events.isEmpty
                ? Center(
                    child: Text(
                      isRu ? 'На эту дату событий нет' : 'No events for this date',
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: events.length,
                    itemBuilder: (_, index) {
                      final eventText = events[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.event, color: Colors.blue),
                          title: Text(eventText),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.orange),
                                onPressed: () => _editEvent(index, eventText),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteEvent(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}