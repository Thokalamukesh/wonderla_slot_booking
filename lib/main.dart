import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const SlotBookingApp());

const navy = Color(0xFF123467);
const blue = Color(0xFF2463D8);
const green = Color(0xFF15965E);
const ink = Color(0xFF192D4B);
const muted = Color(0xFF78869A);
const canvas = Color(0xFFF6F8FC);

class SlotBookingApp extends StatelessWidget {
  const SlotBookingApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Wonderla Ride Slots',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: canvas,
          colorScheme: ColorScheme.fromSeed(seedColor: blue, primary: blue),
          fontFamily: 'Arial',
          textTheme: const TextTheme(
            headlineMedium: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: navy),
            titleLarge: TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: navy),
            bodyLarge: TextStyle(fontSize: 16, color: ink),
          ),
        ),
        home: const BookingPage(),
      );
}

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});
  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int step = 0;
  int selectedRide = 0;
  int? selectedSlot;
  int guests = 1;
  String phone = '';
  String token = '';
  final rides = const ['RECOIL', 'WONDER SPLASH', 'SPACE GUN'];
  final times = const ['12:30 – 13:00', '13:00 – 13:30', '13:30 – 14:00', '14:00 – 14:30', '14:30 – 15:00', '15:00 – 15:30', '15:30 – 16:00', '16:00 – 16:30', '16:30 – 17:00', '17:00 – 17:30', '17:30 – 18:00', '18:00 – 18:30'];
  final left = const [39, 68, 70, 68, 72, 72, 72, 72, 72, 72, 72, 72];

  void go(int value) => setState(() => step = value);
  void startOver() => setState(() { step = 0; selectedSlot = null; guests = 1; phone = ''; token = ''; });
  void confirm() {
    if (phone.length != 10 || selectedSlot == null) return;
    setState(() { token = 'RB${DateTime.now().millisecondsSinceEpoch.toString().substring(3)}'; step = 3; });
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 800;
    return Scaffold(
      body: SafeArea(child: Column(children: [
        _Header(step: step, onBack: step > 0 && step < 3 ? () => go(step - 1) : null),
        Expanded(child: Align(alignment: Alignment.topCenter, child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: AnimatedSwitcher(duration: const Duration(milliseconds: 220), child: _body(wide)),
        ))),
        if (step < 3) _bottomActions(wide),
      ])),
    );
  }

  Widget _body(bool wide) {
    if (step == 0) return _rideStep(wide);
    if (step == 1) return _slotStep(wide);
    if (step == 2) return _guestStep(wide);
    return _ticketStep(wide);
  }

  Widget _rideStep(bool wide) => SingleChildScrollView(
        key: const ValueKey('ride'), padding: EdgeInsets.fromLTRB(wide ? 24 : 18, 22, wide ? 24 : 18, 28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Pick your ride', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: navy)),
          const SizedBox(height: 7), const Text('Choose an attraction to reserve your entry window.', style: TextStyle(color: muted, fontSize: 16)),
          const SizedBox(height: 22),
          GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: rides.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: wide ? 3 : 1, mainAxisExtent: wide ? 250 : 190, crossAxisSpacing: 16, mainAxisSpacing: 16),
            itemBuilder: (context, i) => _RideCard(name: rides[i], selected: i == selectedRide, onTap: () => setState(() => selectedRide = i))),
        ]));

  Widget _slotStep(bool wide) => SingleChildScrollView(
        key: const ValueKey('slots'), padding: EdgeInsets.fromLTRB(wide ? 24 : 16, 18, wide ? 24 : 16, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(height: wide ? 210 : 166, width: double.infinity, decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), gradient: const LinearGradient(colors: [Color(0xFF174786), Color(0xFF4D88D9)], begin: Alignment.bottomLeft, end: Alignment.topRight)),
            child: Stack(children: [Positioned(right: -18, top: -16, child: Icon(Icons.attractions, size: wide ? 235 : 190, color: Colors.white.withValues(alpha: .14))), Positioned(left: 22, bottom: 20, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(rides[selectedRide], style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)), const SizedBox(height: 10), const Row(children: [Icon(Icons.timer_outlined, color: Colors.white, size: 19), SizedBox(width: 7), Text('30 mins', style: TextStyle(color: Colors.white, fontSize: 16)), SizedBox(width: 22), Icon(Icons.people_outline, color: Colors.white, size: 19), SizedBox(width: 7), Text('72 per slot', style: TextStyle(color: Colors.white, fontSize: 16))])]))])),
          const SizedBox(height: 28), const Text('Choose a time slot', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800, color: navy)),
          const SizedBox(height: 7), Text('Pick your entry window for ${rides[selectedRide]}. Full slots are disabled.', style: const TextStyle(color: muted, fontSize: 15)),
          const SizedBox(height: 17),
          GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: times.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: wide ? 3 : 2, mainAxisExtent: 132, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemBuilder: (context, i) => _SlotCard(time: times[i], remaining: left[i], selected: i == selectedSlot, onTap: () => setState(() => selectedSlot = i))),
        ]));

  Widget _guestStep(bool wide) => SingleChildScrollView(key: const ValueKey('guests'), padding: EdgeInsets.fromLTRB(wide ? 24 : 18, 28, wide ? 24 : 18, 32), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Guest details', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w800, color: navy)),
    const SizedBox(height: 8), const Text('Enter your mobile number. One active token per mobile per ride.', style: TextStyle(color: muted, fontSize: 16)),
    const SizedBox(height: 22),
    Card(color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22), side: const BorderSide(color: Color(0xFFE1E6ED))), child: Padding(padding: const EdgeInsets.all(20), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 600), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [Icon(Icons.phone_iphone, color: muted), SizedBox(width: 9), Text('Mobile number', style: TextStyle(color: muted, fontSize: 16, fontWeight: FontWeight.w700))]),
      const SizedBox(height: 12), TextField(readOnly: true, controller: TextEditingController(text: phone), decoration: InputDecoration(hintText: 'Enter 10-digit mobile number', hintStyle: const TextStyle(color: Color(0xFFAAB4C2)), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFD8DEE7))), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17))),
      const SizedBox(height: 14), GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 3, childAspectRatio: 1.8, mainAxisSpacing: 9, crossAxisSpacing: 9, children: ['1','2','3','4','5','6','7','8','9','Clear','0','⌫'].map((key) => _KeyButton(label: key, onTap: () => setState(() { if (key == 'Clear') { phone = ''; } else if (key == '⌫') { if (phone.isNotEmpty) phone = phone.substring(0, phone.length - 1); } else if (phone.length < 10) { phone += key; } }))).toList()),
    ])))),
    const SizedBox(height: 20), Card(color: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFFE1E6ED))), child: Padding(padding: const EdgeInsets.all(20), child: Row(children: [const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Number of guests', style: TextStyle(color: navy, fontSize: 18, fontWeight: FontWeight.w800)), SizedBox(height: 5), Text('Select everyone entering with this token', style: TextStyle(color: muted))])), IconButton(onPressed: guests > 1 ? () => setState(() => guests--) : null, icon: const Icon(Icons.remove_circle_outline, color: blue)), Text('$guests', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: navy)), IconButton(onPressed: guests < 6 ? () => setState(() => guests++) : null, icon: const Icon(Icons.add_circle_outline, color: blue))]))),
    if (phone.isNotEmpty && phone.length < 10) const Padding(padding: EdgeInsets.only(top: 10), child: Text('Enter all 10 digits to continue.', style: TextStyle(color: Color(0xFFB34A48)))),
  ]));

  Widget _ticketStep(bool wide) => SingleChildScrollView(key: const ValueKey('ticket'), padding: EdgeInsets.fromLTRB(wide ? 24 : 18, 20, wide ? 24 : 18, 30), child: Column(children: [
    Container(width: double.infinity, padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: const Color(0xFFE8F6EE), border: Border.all(color: const Color(0xFFC5E8D3)), borderRadius: BorderRadius.circular(14)), child: const Row(children: [Icon(Icons.check_circle_outline, color: green), SizedBox(width: 10), Expanded(child: Text('Token confirmed! Show this QR at the ride entrance.', style: TextStyle(color: Color(0xFF26794F), fontWeight: FontWeight.w700)))])),
    const SizedBox(height: 22), Card(color: Colors.white, elevation: 0, clipBehavior: Clip.antiAlias, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22), side: const BorderSide(color: Color(0xFFE1E6ED))), child: Column(children: [Container(width: double.infinity, color: blue, padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(rides[selectedRide], style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)), const SizedBox(height: 5), const Text('Queue Token Ticket', style: TextStyle(color: Color(0xFFDDE8FF), fontSize: 16))]),), Padding(padding: const EdgeInsets.all(22), child: wide ? Row(children: [_qr(), const SizedBox(width: 28), Expanded(child: _tokenInfo())]) : Column(children: [_qr(), const SizedBox(height: 18), _tokenInfo()])), const Divider(height: 1), Padding(padding: const EdgeInsets.symmetric(vertical: 19, horizontal: 14), child: Row(children: [Expanded(child: _ticketFact('ENTRY WINDOW', selectedSlot == null ? '' : times[selectedSlot!])), const SizedBox(height: 12, child: VerticalDivider()), Expanded(child: _ticketFact('GUESTS', '$guests ${guests == 1 ? 'guest' : 'guests'}'))])), const Divider(height: 1), Padding(padding: const EdgeInsets.all(15), child: Text('Mobile ${phone.length == 10 ? '******${phone.substring(6)}' : ''}  ·  Issued today  ·  Arrive 5 min before your slot', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF9AA6B5), fontSize: 13)))])),
    const SizedBox(height: 18), const Text('A copy can be sent to your mobile. Keep this QR ready at the entrance.', textAlign: TextAlign.center, style: TextStyle(color: muted)), const SizedBox(height: 16), OutlinedButton.icon(onPressed: () => _printTicket(), icon: const Icon(Icons.print_outlined), label: const Text('Print QR Ticket'), style: OutlinedButton.styleFrom(foregroundColor: navy, side: const BorderSide(color: Color(0xFFD9E0E8)), padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14), shape: const StadiumBorder())), const SizedBox(height: 22), SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: startOver, icon: const Icon(Icons.refresh), label: const Text('New booking'), style: FilledButton.styleFrom(backgroundColor: blue, padding: const EdgeInsets.symmetric(vertical: 17), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))))
  ]));

  Widget _qr() => Container(width: 184, height: 184, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE4E8ED))), child: CustomPaint(painter: _QrPattern(token.isEmpty ? 'DEMO-RIDE-QR' : token), child: const SizedBox.expand()));
  Widget _tokenInfo() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('YOUR TOKEN', style: TextStyle(color: Color(0xFF9AA6B5), fontWeight: FontWeight.w800, letterSpacing: 1)), const SizedBox(height: 7), SelectableText(token, style: const TextStyle(color: navy, fontSize: 24, fontWeight: FontWeight.w900)), const SizedBox(height: 8), const Row(children: [Icon(Icons.qr_code_2, color: muted, size: 19), SizedBox(width: 7), Text('Scan or show this at the entrance', style: TextStyle(color: muted))])]);
  Widget _ticketFact(String title, String value) => Column(children: [Text(title, style: const TextStyle(color: Color(0xFF9AA6B5), fontWeight: FontWeight.w700, fontSize: 12)), const SizedBox(height: 5), Text(value, textAlign: TextAlign.center, style: const TextStyle(color: navy, fontSize: 18, fontWeight: FontWeight.w800))]);
  void _printTicket() { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Print support will be connected for the web release.'))); }

  Widget _bottomActions(bool wide) => Container(padding: EdgeInsets.fromLTRB(wide ? 24 : 18, 12, wide ? 24 : 18, 14), decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE5E8ED)))), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1120), child: Row(children: [if (step > 0) Expanded(child: OutlinedButton.icon(onPressed: () => go(step - 1), icon: const Icon(Icons.arrow_back), label: const Text('Back'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), foregroundColor: navy, side: const BorderSide(color: Color(0xFFDDE3EB))))), if (step > 0) const SizedBox(width: 12), Expanded(flex: step == 0 ? 1 : 2, child: FilledButton.icon(onPressed: step == 0 ? () => go(1) : step == 1 ? (selectedSlot == null ? null : () => go(2)) : (phone.length == 10 ? confirm : null), icon: Icon(step == 2 ? Icons.arrow_forward : Icons.arrow_forward), label: Text(step == 2 ? 'Confirm token' : step == 1 ? 'Continue' : 'Choose a time slot'), style: FilledButton.styleFrom(backgroundColor: blue, disabledBackgroundColor: const Color(0xFF9BB9ED), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)))))])));
}

class _Header extends StatelessWidget {
  const _Header({required this.step, this.onBack});
  final int step; final VoidCallback? onBack;
  @override
  Widget build(BuildContext context) => Container(color: Colors.white, padding: const EdgeInsets.fromLTRB(18, 10, 18, 13), child: Column(children: [Row(children: [if (onBack != null) IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_ios_new, size: 19, color: muted)) else const SizedBox(width: 48), const Spacer(), Column(children: [const Text('WONDERLA', style: TextStyle(color: Color(0xFFE5B928), fontSize: 20, fontWeight: FontWeight.w900, shadows: [Shadow(color: navy, blurRadius: 1)])), Text('PARKS AND RESORTS', style: TextStyle(color: navy, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 1.1))]), const Spacer(), Text(TimeOfDay.now().format(context), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: navy)), const SizedBox(width: 8)]), const SizedBox(height: 16), Row(children: List.generate(4, (i) { final done = i < step; final active = i == step; final color = done ? green : active ? blue : const Color(0xFFE8ECF2); final labels = ['Ride', 'Slot', 'Guests', 'Done']; return Expanded(child: Padding(padding: EdgeInsets.only(right: i == 3 ? 0 : 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(height: 7, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(9))), const SizedBox(height: 7), Text(labels[i], style: TextStyle(color: done ? green : active ? blue : const Color(0xFF9AA6B5), fontSize: 14, fontWeight: FontWeight.w800))]))); }))]));
}

class _RideCard extends StatelessWidget {
  const _RideCard({required this.name, required this.selected, required this.onTap});
  final String name; final bool selected; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20), child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: selected ? blue : const Color(0xFFE0E6EF), width: selected ? 2 : 1)), child: Stack(children: [Positioned.fill(child: ClipRRect(borderRadius: BorderRadius.circular(19), child: DecoratedBox(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF2859A4), Color(0xFF80A9E8)], begin: Alignment.bottomLeft, end: Alignment.topRight)), child: Align(alignment: Alignment.topRight, child: Icon(Icons.attractions, size: 155, color: Colors.white.withValues(alpha: .22))))),), Positioned(left: 18, bottom: 17, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)), const SizedBox(height: 5), const Text('30 min ride  ·  72 guests per slot', style: TextStyle(color: Colors.white, fontSize: 13))])), if (selected) const Positioned(right: 14, top: 14, child: Icon(Icons.check_circle, color: Colors.white))])));
}

class _SlotCard extends StatelessWidget {
  const _SlotCard({required this.time, required this.remaining, required this.selected, required this.onTap});
  final String time; final int remaining; final bool selected; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(onTap: remaining == 0 ? null : onTap, borderRadius: BorderRadius.circular(17), child: Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: selected ? blue : const Color(0xFFE0E6ED), width: selected ? 2 : 1)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(time, style: const TextStyle(color: navy, fontWeight: FontWeight.w800, fontSize: 14)), const SizedBox(height: 7), Text(remaining == 0 ? 'Full' : 'On Time', style: TextStyle(color: remaining == 0 ? muted : const Color(0xFF58A56B), fontWeight: FontWeight.w700, fontSize: 13)), const SizedBox(height: 7), ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: remaining / 72, minHeight: 6, backgroundColor: const Color(0xFFEFF1F5), color: green)), const SizedBox(height: 6), Text('$remaining tokens left', style: const TextStyle(color: green, fontWeight: FontWeight.w700, fontSize: 12))])));
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({required this.label, required this.onTap}); final String label; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(color: const Color(0xFFF2F4F8), borderRadius: BorderRadius.circular(13), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(13), child: Center(child: label == '⌫' ? const Icon(Icons.backspace_outlined, color: navy) : Text(label, style: const TextStyle(color: navy, fontWeight: FontWeight.w800, fontSize: 19)))));
}

class _QrPattern extends CustomPainter {
  _QrPattern(this.value); final String value;
  @override
  void paint(Canvas canvas, Size size) {
    const n = 29; final cell = size.width / n; final p = Paint()..color = const Color(0xFF111820);
    final seed = value.codeUnits.fold<int>(7, (a, b) => (a * 31 + b) & 0x7fffffff);
    bool finder(int x, int y) { for (final o in [(0,0),(n-7,0),(0,n-7)]) { final dx=x-o.$1, dy=y-o.$2; if (dx>=0&&dx<7&&dy>=0&&dy<7) return dx==0||dx==6||dy==0||dy==6||(dx>=2&&dx<=4&&dy>=2&&dy<=4); } return false; }
    var state = seed;
    for (var y=0; y<n; y++) { for (var x=0; x<n; x++) { if (finder(x,y)) { canvas.drawRect(Rect.fromLTWH(x*cell,y*cell,cell+.15,cell+.15),p); continue; } state = (state * 1103515245 + 12345) & 0x7fffffff; final reserved = (x < 8 && y < 8)||(x > n-9 && y < 8)||(x < 8 && y > n-9); if (!reserved && (state % 100) < 48) canvas.drawRect(Rect.fromLTWH(x*cell,y*cell,cell+.15,cell+.15),p); } }
  }
  @override bool shouldRepaint(covariant _QrPattern oldDelegate) => oldDelegate.value != value;
}
