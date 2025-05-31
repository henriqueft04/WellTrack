import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:welltrack/pages/home_page.dart';
import 'journal_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // Dia que está atualmente focado no calendário
  DateTime _focusedDay = DateTime.now();

  // Dia que o utilizador selecionou
  DateTime? _selectedDay;

  // Formato default
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Esta função diz se um dia é clicável ou não
  // Só permite clicar nos dias até ao dia de hoje (inclusive)
  bool _isDayEnabled(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day); // dia atual sem hora
    final d = DateTime(
      day.year,
      day.month,
      day.day,
    ); // dia a verificar sem hora
    return d.isBefore(today) || d.isAtSameMomentAs(today);
  }

  // Esta função é chamada quando o utilizador escolhe um dia no calendário
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (_isDayEnabled(selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      // Vai para a página do Journal
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const JournalPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Cabeçalho da página com botão para voltar atrás
      appBar: AppBar(
        title: const Text(
          'Calendar',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          // Botão de voltar para trás volta sempre para a HomePage
          // pode ser mudado. O problema é que também se pode ir para
          // Calendar desde o menú lateral
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
              (route) => false,
            );
          },
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TableCalendar(
          // Primeiro e último dia possíveis no calendário
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,

          // Esta função é chamada quando o utilizador muda o formato
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },

          // Verifica se um dia é o mesmo que foi selecionado
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

          onDaySelected: _onDaySelected,

          // Define que dias estão ativos (clicáveis)
          enabledDayPredicate: _isDayEnabled,

          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.lightBlue,
              shape: BoxShape.circle,
            ),
            disabledTextStyle: const TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
