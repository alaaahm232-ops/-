import 'package:flutter/material.dart';

void main() => runApp(const WasalniApp());

const green = Color(0xFF07864B);
const dark = Color(0xFF11191D);

class TripStore extends ChangeNotifier {
  TripStore._();
  static final TripStore instance = TripStore._();
  String pickup = 'موقعي الحالي';
  String destination = '';
  String status = 'لا توجد رحلة نشطة';
  double fare = 22.50;
  int rating = 0;
  String note = '';
  bool get hasTrip => destination.trim().isNotEmpty && status != 'لا توجد رحلة نشطة';
  void create(String from, String to) {
    pickup = from.trim().isEmpty ? 'موقعي الحالي' : from.trim();
    destination = to.trim(); status = 'بانتظار قبول السائق'; rating = 0; note = ''; notifyListeners();
  }
  void updateStatus(String next) { status = next; notifyListeners(); }
  void setRating(int value, String comment) { rating = value; note = comment; status = 'مكتملة'; notifyListeners(); }
}

class WasalniApp extends StatelessWidget {
  const WasalniApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false, title: 'وصلني | WASALNI',
    theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: green), scaffoldBackgroundColor: const Color(0xFFF4F7F5), appBarTheme: const AppBarTheme(centerTitle: true)),
    home: const RolePage(),
  );
}

class RolePage extends StatelessWidget {
  const RolePage({super.key});
  @override Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    const SizedBox(height: 26), const Icon(Icons.directions_car_filled, color: green, size: 76),
    const Text('وصلني', textAlign: TextAlign.center, style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: green)),
    const Text('WASALNI  •  رحلتك أسهل، وصولك أسرع', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.black54)),
    const SizedBox(height: 34),
    _RoleCard(icon: Icons.person_rounded, title: 'وصلني للعميل', subtitle: 'إنشاء طلب ومتابعة حالة الرحلة', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerPage()))),
    _RoleCard(icon: Icons.directions_car_rounded, title: 'وصلني للسائق', subtitle: 'عرض الطلبات وقبول الرحلة وإنهاؤها', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverPage()))),
    _RoleCard(icon: Icons.admin_panel_settings_rounded, title: 'لوحة الإدارة', subtitle: 'متابعة الرحلة الحالية والإحصائيات التجريبية', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPage()))),
    const Spacer(), const Text('نسخة محلية تجريبية: حالة الرحلة مشتركة بين الشاشات على هذا الجهاز فقط.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black45, fontSize: 12)),
  ]))));
}

class _RoleCard extends StatelessWidget {
  final IconData icon; final String title, subtitle; final VoidCallback onTap;
  const _RoleCard({required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 13), child: ListTile(contentPadding: const EdgeInsets.all(15), leading: CircleAvatar(backgroundColor: green.withOpacity(.12), child: Icon(icon, color: green)), title: Text(title, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(subtitle, textAlign: TextAlign.right), trailing: const Icon(Icons.chevron_left), onTap: onTap));
}

class CustomerPage extends StatefulWidget { const CustomerPage({super.key}); @override State<CustomerPage> createState() => _CustomerPageState(); }
class _CustomerPageState extends State<CustomerPage> {
  final from = TextEditingController(text: 'موقعي الحالي'); final to = TextEditingController(); final comment = TextEditingController();
  @override void dispose() { from.dispose(); to.dispose(); comment.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => AnimatedBuilder(animation: TripStore.instance, builder: (context, _) {
    final trip = TripStore.instance;
    return Scaffold(appBar: AppBar(title: const Text('وصلني للعميل')), body: ListView(padding: const EdgeInsets.all(18), children: [
      Container(height: 145, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFDCEFE4), Color(0xFFF1F7F3)]), borderRadius: BorderRadius.circular(20)), child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.map_outlined, size: 52, color: green), SizedBox(height: 8), Text('معاينة مكان الخريطة', style: TextStyle(fontWeight: FontWeight.bold)), Text('سيتم ربط الخرائط الحقيقية لاحقًا', style: TextStyle(color: Colors.black54))])),
      const SizedBox(height: 18), TextField(controller: from, textAlign: TextAlign.right, decoration: const InputDecoration(labelText: 'نقطة الانطلاق', prefixIcon: Icon(Icons.my_location), border: OutlineInputBorder())),
      const SizedBox(height: 12), TextField(controller: to, textAlign: TextAlign.right, decoration: const InputDecoration(labelText: 'الوجهة', prefixIcon: Icon(Icons.location_on_outlined), border: OutlineInputBorder())),
      const SizedBox(height: 14), Card(child: ListTile(leading: const Icon(Icons.payments_outlined, color: green), title: const Text('السعر التقديري'), subtitle: const Text('سعر توضيحي قابل للتعديل'), trailing: Text('${trip.fare.toStringAsFixed(2)} ر.س', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)))),
      const SizedBox(height: 12), FilledButton.icon(onPressed: () { if (to.text.trim().isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل الوجهة أولًا'))); return; } trip.create(from.text, to.text); FocusScope.of(context).unfocus(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إنشاء طلب تجريبي، افتح شاشة السائق لقبوله'))); }, icon: const Icon(Icons.local_taxi), label: const Text('طلب سيارة')),
      const SizedBox(height: 18), _StatusCard(status: trip.status, pickup: trip.pickup, destination: trip.destination),
      if (trip.status == 'مكتملة') ...[
        const SizedBox(height: 12), Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const Text('قيّم رحلتك', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), const SizedBox(height: 8), Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => IconButton(onPressed: () => setState(() => trip.rating = i + 1), icon: Icon(Icons.star, color: i < trip.rating ? Colors.amber : Colors.grey, size: 30)))), TextField(controller: comment, textAlign: TextAlign.right, decoration: const InputDecoration(hintText: 'ملاحظة اختيارية', border: OutlineInputBorder())), const SizedBox(height: 10), FilledButton(onPressed: () { trip.setRating(trip.rating == 0 ? 5 : trip.rating, comment.text); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ التقييم على هذا الجهاز'))); }, child: const Text('حفظ التقييم'))]))),
      ],
    ]));
  });
}

class DriverPage extends StatelessWidget { const DriverPage({super.key}); @override Widget build(BuildContext context) => AnimatedBuilder(animation: TripStore.instance, builder: (context, _) {
  final trip = TripStore.instance;
  final has = trip.destination.isNotEmpty && trip.status != 'مكتملة';
  return Scaffold(appBar: AppBar(title: const Text('وصلني للسائق')), body: ListView(padding: const EdgeInsets.all(18), children: [
    Container(height: 120, decoration: BoxDecoration(color: dark, borderRadius: BorderRadius.circular(18)), child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.route, color: Color(0xFF55D98B), size: 42), SizedBox(height: 6), Text('طلبات الرحلات', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), Text('تجربة تفاعلية على جهاز واحد', style: TextStyle(color: Colors.white70))])),
    const SizedBox(height: 16), if (trip.destination.isEmpty) const Card(child: ListTile(leading: Icon(Icons.inbox_outlined), title: Text('لا توجد طلبات حاليًا'), subtitle: Text('ارجع إلى شاشة العميل وأنشئ طلب رحلة تجريبيًا.')))
    else Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Text('حالة الطلب: ${trip.status}', textAlign: TextAlign.right, style: const TextStyle(color: green, fontWeight: FontWeight.bold)), const Divider(), _InfoLine(label: 'نقطة الانطلاق', value: trip.pickup), _InfoLine(label: 'الوجهة', value: trip.destination), _InfoLine(label: 'السعر التقديري', value: '${trip.fare.toStringAsFixed(2)} ر.س'), const SizedBox(height: 14),
      if (trip.status == 'بانتظار قبول السائق') FilledButton(onPressed: () => trip.updateStatus('تم قبول الرحلة') , child: const Text('قبول الرحلة')),
      if (trip.status == 'تم قبول الرحلة') FilledButton(onPressed: () => trip.updateStatus('السائق في الطريق إلى العميل'), child: const Text('بدء التوجه للعميل')),
      if (trip.status == 'السائق في الطريق إلى العميل') FilledButton(onPressed: () => trip.updateStatus('وصل السائق إلى العميل'), child: const Text('تأكيد الوصول إلى العميل')),
      if (trip.status == 'وصل السائق إلى العميل') FilledButton(onPressed: () => trip.updateStatus('الرحلة جارية'), child: const Text('بدء الرحلة')),
      if (trip.status == 'الرحلة جارية') FilledButton(onPressed: () => trip.updateStatus('مكتملة'), child: const Text('إنهاء الرحلة')),
      if (trip.status == 'مكتملة') const Text('تم إنهاء الرحلة. يمكن للعميل إضافة تقييم.', textAlign: TextAlign.center),
      if (trip.status != 'مكتملة') TextButton(onPressed: () => trip.updateStatus('ملغاة'), child: const Text('إلغاء الطلب التجريبي')),
      if (trip.status == 'ملغاة') const Text('أُلغي الطلب التجريبي. أنشئ طلبًا جديدًا من شاشة العميل.', textAlign: TextAlign.center),
    ]))),
  ]));
}); }

class AdminPage extends StatelessWidget { const AdminPage({super.key}); @override Widget build(BuildContext context) => AnimatedBuilder(animation: TripStore.instance, builder: (context, _) { final t = TripStore.instance; return Scaffold(appBar: AppBar(title: const Text('لوحة تحكم الإدارة')), body: ListView(padding: const EdgeInsets.all(18), children: [const Text('لوحة متابعة وصلني', textAlign: TextAlign.right, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 12), Row(children: [Expanded(child: _Stat(title: 'الرحلات المسجلة محليًا', value: t.destination.isEmpty ? '0' : '1')), const SizedBox(width: 10), Expanded(child: _Stat(title: 'السعر التقديري', value: t.destination.isEmpty ? '—' : '${t.fare.toStringAsFixed(2)} ر.س'))]), const SizedBox(height: 10), Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const Text('الرحلة الحالية', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), const Divider(), _InfoLine(label: 'الحالة', value: t.status), _InfoLine(label: 'من', value: t.pickup), _InfoLine(label: 'إلى', value: t.destination.isEmpty ? 'لا توجد وجهة' : t.destination), if (t.rating > 0) _InfoLine(label: 'تقييم العميل', value: '${t.rating}/5'), const SizedBox(height: 8), const Text('الأرقام المعروضة هنا تجريبية وليست بيانات تشغيل فعلية.', textAlign: TextAlign.right, style: TextStyle(color: Colors.black54))])))])); }); }

class _StatusCard extends StatelessWidget { final String status, pickup, destination; const _StatusCard({required this.status, required this.pickup, required this.destination}); @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [const Text('متابعة الرحلة', textAlign: TextAlign.right, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Row(children: [const Icon(Icons.circle, color: green, size: 12), const SizedBox(width: 8), Expanded(child: Text(status, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, color: green)))]), const Divider(), _InfoLine(label: 'من', value: pickup), _InfoLine(label: 'إلى', value: destination.isEmpty ? 'لم تحدد بعد' : destination)]))); }
class _InfoLine extends StatelessWidget { final String label, value; const _InfoLine({required this.label, required this.value}); @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w600))), const SizedBox(width: 10), Text(label, style: const TextStyle(color: Colors.black54))])); }
class _Stat extends StatelessWidget { final String title, value; const _Stat({required this.title, required this.value}); @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)), const SizedBox(height: 8), FittedBox(child: Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: green)))]))); }
