// // ════════════════════════════════════════════
// // 1. SHARED PREFERENCES — session save/get
// // ════════════════════════════════════════════
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// final prefs = await SharedPreferences.getInstance();

// // Save
// await prefs.setString('key', value);
// await prefs.setInt('key', value);
// await prefs.setBool('key', value);

// // Get
// final value = prefs.getString('key') ?? '';
// final value = prefs.getInt('key') ?? 0;
// final value = prefs.getBool('key') ?? false;

// // Delete
// await prefs.remove('key');


// // ════════════════════════════════════════════
// // 2. HTTP API CALLS
// // ════════════════════════════════════════════
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// // GET
// final res = await http.get(Uri.parse('$baseUrl/endpoint'));

// // GET with path param
// final res = await http.get(Uri.parse('$baseUrl/endpoint/$id'));

// // GET with query param
// final res = await http.get(Uri.parse('$baseUrl/endpoint?name=$value'));

// // POST with JSON body
// final res = await http.post(
//   Uri.parse('$baseUrl/endpoint'),
//   headers: {'Content-Type': 'application/json'},
//   body: jsonEncode({'key': value}),
// );

// // PUT
// final res = await http.put(
//   Uri.parse('$baseUrl/endpoint/$id'),
//   headers: {'Content-Type': 'application/json'},
//   body: jsonEncode({'key': value}),
// );

// // DELETE
// final res = await http.delete(Uri.parse('$baseUrl/endpoint/$id'));

// // Response check
// if (res.statusCode == 200) return jsonDecode(res.body);
// if (res.statusCode == 201) return {'success': true};
// throw Exception(jsonDecode(res.body)['detail'] ?? 'Failed');


// // ════════════════════════════════════════════
// // 3. FUTURE BUILDER
// // ════════════════════════════════════════════
// FutureBuilder<List<dynamic>>(
//   future: _myFuture,
//   builder: (context, snapshot) {
//     if (snapshot.connectionState == ConnectionState.waiting) {
//       return const CircularProgressIndicator();
//     }
//     if (snapshot.hasError) {
//       return Text('Error: ${snapshot.error}');
//     }
//     if (!snapshot.hasData || snapshot.data!.isEmpty) {
//       return const Text('No data found');
//     }
//     final data = snapshot.data!;
//     return ListView.builder(...);
//   },
// ),

// // Map k liye
// FutureBuilder<Map<String, dynamic>>(
//   future: _myFuture,
//   builder: (context, snapshot) {
//     final data = snapshot.data!;
//     ...
//   },
// ),


// // ════════════════════════════════════════════
// // 4. NAVIGATOR
// // ════════════════════════════════════════════
// // Push — back button kaam karta hai
// Navigator.push(context,
//     MaterialPageRoute(builder: (_) => const MyScreen()));

// // Push with data
// Navigator.push(context,
//     MaterialPageRoute(builder: (_) => MyScreen(id: id)));

// // Push replacement — back nahi ja sakta
// Navigator.pushReplacement(context,
//     MaterialPageRoute(builder: (_) => const MyScreen()));

// // Push and remove all — login ke baad
// Navigator.pushAndRemoveUntil(
//   context,
//   MaterialPageRoute(builder: (_) => const MyScreen()),
//   (_) => false,
// );

// // Pop — wapas jana
// Navigator.pop(context);

// // Pop with value
// Navigator.pop(context, true);

// // Pop baad mein value receive karna
// final result = await Navigator.push(...);
// if (result == true) _refresh();


// // ════════════════════════════════════════════
// // 5. SNACKBAR
// // ════════════════════════════════════════════
// ScaffoldMessenger.of(context).showSnackBar(
//   SnackBar(
//     content: Text('message'),
//     backgroundColor: Colors.green, // ya Colors.red
//     duration: const Duration(seconds: 2),
//   ),
// );


// // ════════════════════════════════════════════
// // 6. WILLPOPSCOPE — back button handle
// // ════════════════════════════════════════════
// WillPopScope(
//   onWillPop: () async {
//     // kuch karo pehle
//     await ApiService.unlock();
//     return true; // true = pop hoga, false = nahi hoga
//   },
//   child: Scaffold(...),
// ),


// // ════════════════════════════════════════════
// // 7. DROPDOWN BUTTON
// // ════════════════════════════════════════════
// String? _selectedValue;

// DropdownButtonHideUnderline(
//   child: DropdownButton<String>(
//     value: _selectedValue,
//     isExpanded: true,
//     hint: const Text('Select...'),
//     items: myList
//         .map((item) => DropdownMenuItem<String>(
//               value: item['id'].toString(),
//               child: Text(item['name'] ?? ''),
//             ))
//         .toList(),
//     onChanged: (val) => setState(() => _selectedValue = val),
//   ),
// ),


// // ════════════════════════════════════════════
// // 8. TEXT CONTROLLER + DISPOSE
// // ════════════════════════════════════════════
// final _ctrl = TextEditingController();

// // initState mein prefill
// _ctrl.text = existingValue ?? '';

// // dispose mein
// @override
// void dispose() {
//   _ctrl.dispose();
//   super.dispose();
// }


// // ════════════════════════════════════════════
// // 9. FORM VALIDATION
// // ════════════════════════════════════════════
// final _formKey = GlobalKey<FormState>();

// Form(
//   key: _formKey,
//   child: Column(children: [
//     TextFormField(
//       validator: (v) => v == null || v.isEmpty ? 'Required' : null,
//     ),
//   ]),
// ),

// // Submit karte waqt
// if (!_formKey.currentState!.validate()) return;


// // ════════════════════════════════════════════
// // 10. LOADING STATE PATTERN
// // ════════════════════════════════════════════
// bool _loading = false;

// Future<void> _submit() async {
//   setState(() => _loading = true);
//   try {
//     // API call
//   } catch (e) {
//     // error handle
//   } finally {
//     if (mounted) setState(() => _loading = false);
//   }
// }

// // Button mein
// ElevatedButton(
//   onPressed: _loading ? null : _submit,
//   child: _loading
//       ? const CircularProgressIndicator(color: Colors.white)
//       : const Text('Submit'),
// ),


// // ════════════════════════════════════════════
// // 11. MOUNTED CHECK
// // ════════════════════════════════════════════
// if (!mounted) return;

// // Async ke baad hamesha check karo
// await ApiService.someCall();
// if (!mounted) return;
// Navigator.pop(context);


// // ════════════════════════════════════════════
// // 12. REFRESH INDICATOR
// // ════════════════════════════════════════════
// RefreshIndicator(
//   onRefresh: () async => _loadData(),
//   child: ListView.builder(...),
// ),


// // ════════════════════════════════════════════
// // 13. NULL SAFETY PATTERNS
// // ════════════════════════════════════════════
// // Null check
// final value = json['key'] ?? 'default';

// // int parse safely
// final id = json['id'] is int
//     ? json['id']
//     : int.tryParse(json['id'].toString()) ?? 0;

// // double parse safely
// final amount = json['amount']?.toDouble() ?? 0.0;

// // String to int
// final num = int.tryParse(str) ?? 0;

// // Nullable int to String
// final str = myInt?.toString() ?? 'N/A';


// // ════════════════════════════════════════════
// // 14. DATE FORMATTING
// // ════════════════════════════════════════════
// import 'package:intl/intl.dart';

// // Format karo
// final formatted = DateFormat('dd MMM yyyy').format(myDate);
// final formatted = DateFormat('yyyy-MM-dd').format(myDate);
// final formatted = DateFormat('hh:mm a').format(myDate);

// // Parse karo
// final date = DateTime.parse('2026-05-14');
// final date = DateFormat('yyyy-MM-dd hh:mm a').parse('2026-05-14 10:45 AM');


// // ════════════════════════════════════════════
// // 15. DATE PICKER
// // ════════════════════════════════════════════
// final DateTime? picked = await showDatePicker(
//   context: context,
//   initialDate: DateTime.now(),
//   firstDate: DateTime(1900),
//   lastDate: DateTime.now(),
// );
// if (picked != null) {
//   final formatted = DateFormat('yyyy-MM-dd').format(picked);
// }


// // ════════════════════════════════════════════
// // 16. BOTTOM SHEET
// // ════════════════════════════════════════════
// showModalBottomSheet(
//   context: context,
//   shape: const RoundedRectangleBorder(
//     borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//   ),
//   builder: (_) => StatefulBuilder(
//     builder: (context, setSheetState) => Padding(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [...],
//       ),
//     ),
//   ),
// );


// // ════════════════════════════════════════════
// // 17. DIALOG
// // ════════════════════════════════════════════
// // Loading dialog
// showDialog(
//   context: context,
//   barrierDismissible: false,
//   builder: (_) => const Center(child: CircularProgressIndicator()),
// );
// Navigator.pop(context); // dismiss

// // Confirm dialog
// final confirm = await showDialog<bool>(
//   context: context,
//   builder: (_) => AlertDialog(
//     title: const Text('Confirm'),
//     content: const Text('Are you sure?'),
//     actions: [
//       TextButton(
//         onPressed: () => Navigator.pop(context, false),
//         child: const Text('Cancel'),
//       ),
//       TextButton(
//         onPressed: () => Navigator.pop(context, true),
//         child: const Text('Yes'),
//       ),
//     ],
//   ),
// );
// if (confirm != true) return;


// // ════════════════════════════════════════════
// // 18. LIST MAP FILTER
// // ════════════════════════════════════════════
// // Filter
// final filtered = myList
//     .where((item) => item['name'].toLowerCase().contains(query))
//     .toList();

// // Map to widget
// ...myList.map((item) => MyWidget(data: item)).toList(),

// // Map to DropdownMenuItem
// myList.map((item) => DropdownMenuItem(
//   value: item['id'],
//   child: Text(item['name']),
// )).toList(),


// // ════════════════════════════════════════════
// // 19. STATEFUL WIDGET PATTERN
// // ════════════════════════════════════════════
// class MyScreen extends StatefulWidget {
//   final int id; // required data
//   const MyScreen({super.key, required this.id});

//   @override
//   State<MyScreen> createState() => _MyScreenState();
// }

// class _MyScreenState extends State<MyScreen> {
//   // widget.id se access karo

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     // API call
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(...);
//   }
// }


// // ════════════════════════════════════════════
// // 20. MODEL FROMJSON PATTERN
// // ════════════════════════════════════════════
// class MyModel {
//   final int id;
//   final String name;
//   final String? optional;

//   MyModel({
//     required this.id,
//     required this.name,
//     this.optional,
//   });

//   factory MyModel.fromJson(Map<String, dynamic> json) => MyModel(
//         id: json['id'] is int
//             ? json['id']
//             : int.tryParse(json['id'].toString()) ?? 0,
//         name: json['name'] ?? '',
//         optional: json['optional'],
//       );
// }
// ════════════════════════════════════════════
// DATA EK SCREEN SE DUSRI SCREEN MEIN BHEJNA
// ════════════════════════════════════════════


// // ── 1. SIMPLE VALUE PASS KARO ───────────────
// // Screen A mein:
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (_) => ScreenB(id: 5, name: "Ahmed"),
//   ),
// );

// // Screen B mein receive karo:
// class ScreenB extends StatelessWidget {
//   final int id;
//   final String name;
//   const ScreenB({super.key, required this.id, required this.name});

//   @override
//   Widget build(BuildContext context) {
//     return Text('$name - $id');
//   }
// }


// // ── 2. MAP/OBJECT PASS KARO ─────────────────
// // Screen A mein:
// final patient = {'name': 'Ahmed', 'mpi': 23, 'gender': 'Male'};
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (_) => ScreenB(patient: patient),
//   ),
// );

// // Screen B mein:
// class ScreenB extends StatelessWidget {
//   final Map<String, dynamic> patient;
//   const ScreenB({super.key, required this.patient});

//   @override
//   Widget build(BuildContext context) {
//     return Text(patient['name']);
//   }
// }


// // ── 3. MODEL OBJECT PASS KARO ───────────────
// // Screen A mein:
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (_) => ScreenB(visitNote: myNote),
//   ),
// );

// // Screen B mein:
// class ScreenB extends StatelessWidget {
//   final VisitNote visitNote;
//   const ScreenB({super.key, required this.visitNote});

//   @override
//   Widget build(BuildContext context) {
//     return Text(visitNote.noteTitle ?? '');
//   }
// }


// // ── 4. DATA WAPAS BHEJNA (pop ke saath) ─────
// // Screen B mein — wapas bhejna:
// Navigator.pop(context, true);        // bool
// Navigator.pop(context, 'success');   // String
// Navigator.pop(context, myObject);    // object

// // Screen A mein — receive karna:
// final result = await Navigator.push(
//   context,
//   MaterialPageRoute(builder: (_) => const ScreenB()),
// );
// if (result == true) {
//   _refresh(); // kuch karo
// }


// // ── 5. SESSION SE DATA LENA ─────────────────
// // Login ke waqt save karo:
// final prefs = await SharedPreferences.getInstance();
// await prefs.setInt('userId', 5);
// await prefs.setString('hospitalId', 'EHR-1');
// await prefs.setString('doctorName', 'Dr. Ahmed');

// // Kisi bhi screen mein uthao:
// final prefs = await SharedPreferences.getInstance();
// final userId = prefs.getInt('userId') ?? 0;
// final hospitalId = prefs.getString('hospitalId') ?? '';


// // ── 6. MULTIPLE VALUES PASS KARO ────────────
// // Screen A:
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (_) => ScreenB(
//       mpi: patient.mpi,
//       doctorId: widget.doctorId,
//       patientName: patient.name,
//     ),
//   ),
// );

// // Screen B:
// class ScreenB extends StatefulWidget {
//   final int mpi;
//   final int doctorId;
//   final String patientName;

//   const ScreenB({
//     super.key,
//     required this.mpi,
//     required this.doctorId,
//     required this.patientName,
//   });

//   @override
//   State<ScreenB> createState() => _ScreenBState();
// }

// class _ScreenBState extends State<ScreenB> {
//   @override
//   void initState() {
//     super.initState();
//     // widget.mpi, widget.doctorId, widget.patientName se access karo
//     print(widget.mpi);
//   }
// }


// // ── 7. NESTED SCREENS MEIN DATA ─────────────
// // A → B → C mein same data chahiye:

// // Option 1: Har screen mein pass karo
// // A → B
// Navigator.push(context,
//     MaterialPageRoute(builder: (_) => ScreenB(userId: userId)));
// // B → C
// Navigator.push(context,
//     MaterialPageRoute(builder: (_) => ScreenC(userId: widget.userId)));

// // Option 2: SharedPreferences use karo (better)
// // Login pe save karo → har screen mein seedha uthao
// final userId = prefs.getInt('userId') ?? 0;


// // ── 8. REAL EXAMPLE — HAMARE PROJECT SE ─────

// // HomeScreen → ViewPatientScreen
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (_) => ViewPatientScreen(
//       patient: p,        // PatientModel object
//       doctorId: widget.doctorId, // int
//     ),
//   ),
// );

// // ViewPatientScreen → VisitNoteDetailScreen
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (_) => VisitNoteDetailScreen(
//       note: visitNote, // VisitNote object
//     ),
//   ),
// );

// // LabPatientDetails — lock/unlock ke liye
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (_) => LabPatientDetailsScreen(
//       mpi: widget.mpi,  // String
//       vid: widget.vid,  // String
//     ),
//   ),
// );
//-------------------------------------------------------------------
// ```dart
// // ════════════════════════════════════════════
// // 1. SIMPLE DROPDOWN
// // ════════════════════════════════════════════
// String? _selected;

// DropdownButtonFormField<String>(
//   value: _selected,
//   hint: const Text('Select option'),
//   decoration: InputDecoration(
//     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//     contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//   ),
//   items: ['Option 1', 'Option 2', 'Option 3']
//       .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//       .toList(),
//   onChanged: (val) => setState(() => _selected = val),
// ),


// // ════════════════════════════════════════════
// // 2. DROPDOWN FROM API LIST
// // ════════════════════════════════════════════
// String? _selectedId;
// List<dynamic> _items = []; // API se aaya data

// DropdownButtonHideUnderline(
//   child: DropdownButton<String>(
//     value: _selectedId,
//     isExpanded: true,
//     hint: const Text('Select'),
//     items: _items
//         .map((item) => DropdownMenuItem<String>(
//               value: item['id'].toString(),
//               child: Text(item['name'] ?? ''),
//             ))
//         .toList(),
//     onChanged: (val) => setState(() => _selectedId = val),
//   ),
// ),


// // ════════════════════════════════════════════
// // 3. DROPDOWN INSIDE CONTAINER (styled)
// // ════════════════════════════════════════════
// String? _selected;

// Container(
//   decoration: BoxDecoration(
//     color: Colors.white,
//     borderRadius: BorderRadius.circular(12),
//     border: Border.all(color: const Color(0xFFE0E0E0)),
//   ),
//   padding: const EdgeInsets.symmetric(horizontal: 16),
//   child: DropdownButtonHideUnderline(
//     child: DropdownButton<String>(
//       value: _selected,
//       isExpanded: true,
//       hint: const Text('Select',
//           style: TextStyle(color: Color(0xFFAAAAAA))),
//       items: ['Male', 'Female', 'Other']
//           .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//           .toList(),
//       onChanged: (val) => setState(() => _selected = val),
//     ),
//   ),
// ),


// // ════════════════════════════════════════════
// // 4. DROPDOWN ANDAR DROPDOWN (nested)
// // ════════════════════════════════════════════
// String? _selectedCategory;
// String? _selectedSubItem;

// // Category ke hisaab se sub items change honge
// final Map<String, List<String>> _data = {
//   'Hospital': ['Shifa', 'PIMS', 'Holy Family'],
//   'Lab': ['IDC', 'MIR', 'Chughtai'],
//   'Insurance': ['Jubilee', 'State Life'],
// };

// // Category Dropdown
// DropdownButtonFormField<String>(
//   value: _selectedCategory,
//   hint: const Text('Select Category'),
//   decoration: InputDecoration(
//     border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//     contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//   ),
//   items: _data.keys
//       .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//       .toList(),
//   onChanged: (val) => setState(() {
//     _selectedCategory = val;
//     _selectedSubItem = null; // reset sub dropdown
//   }),
// ),

// const SizedBox(height: 16),

// // Sub Item Dropdown — category select hone ke baad
// if (_selectedCategory != null)
//   DropdownButtonFormField<String>(
//     value: _selectedSubItem,
//     hint: const Text('Select Sub Item'),
//     decoration: InputDecoration(
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//     ),
//     items: (_data[_selectedCategory!] ?? [])
//         .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//         .toList(),
//     onChanged: (val) => setState(() => _selectedSubItem = val),
//   ),


// // ════════════════════════════════════════════
// // 5. RADIO BUTTONS
// // ════════════════════════════════════════════
// String _selectedGender = 'Male';

// // Option 1 — Row mein
// Row(
//   children: ['Male', 'Female', 'Other'].map((g) => Row(
//     mainAxisSize: MainAxisSize.min,
//     children: [
//       Radio<String>(
//         value: g,
//         groupValue: _selectedGender,
//         activeColor: const Color(0xFF1A3B5D),
//         onChanged: (val) => setState(() => _selectedGender = val!),
//       ),
//       Text(g),
//       const SizedBox(width: 8),
//     ],
//   )).toList(),
// ),

// // Option 2 — RadioListTile (full width)
// Column(
//   children: ['Male', 'Female', 'Other'].map((g) =>
//     RadioListTile<String>(
//       value: g,
//       groupValue: _selectedGender,
//       activeColor: const Color(0xFF1A3B5D),
//       title: Text(g),
//       onChanged: (val) => setState(() => _selectedGender = val!),
//     ),
//   ).toList(),
// ),


// // ════════════════════════════════════════════
// // 6. CHECKBOX — single
// // ════════════════════════════════════════════
// bool _isChecked = false;

// Row(
//   children: [
//     Checkbox(
//       value: _isChecked,
//       activeColor: const Color(0xFF1A3B5D),
//       onChanged: (val) => setState(() => _isChecked = val ?? false),
//     ),
//     const Text('Hold Data'),
//   ],
// ),

// // CheckboxListTile (full width)
// CheckboxListTile(
//   value: _isChecked,
//   activeColor: const Color(0xFF1A3B5D),
//   title: const Text('Hold Data'),
//   onChanged: (val) => setState(() => _isChecked = val ?? false),
// ),


// // ════════════════════════════════════════════
// // 7. CHECKBOX — multiple (list se)
// // ════════════════════════════════════════════
// final List<String> _options = ['Service', 'Tests', 'Lab'];
// final List<String> _selectedOptions = [];

// Column(
//   children: _options.map((option) =>
//     CheckboxListTile(
//       value: _selectedOptions.contains(option),
//       activeColor: const Color(0xFF1A3B5D),
//       title: Text(option),
//       onChanged: (val) {
//         setState(() {
//           if (val == true) {
//             _selectedOptions.add(option);
//           } else {
//             _selectedOptions.remove(option);
//           }
//         });
//       },
//     ),
//   ).toList(),
// ),


// // ════════════════════════════════════════════
// // 8. SWITCH (toggle)
// // ════════════════════════════════════════════
// bool _isEnabled = false;

// Row(
//   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   children: [
//     const Text('Enable Feature'),
//     Switch(
//       value: _isEnabled,
//       activeColor: const Color(0xFF1A3B5D),
//       onChanged: (val) => setState(() => _isEnabled = val),
//     ),
//   ],
// ),


// // ════════════════════════════════════════════
// // 9. CHOICE CHIP (select one)
// // ════════════════════════════════════════════
// String _selectedLab = 'IDC';

// Wrap(
//   spacing: 8,
//   children: ['IDC', 'MIR', 'Chughtai'].map((lab) =>
//     ChoiceChip(
//       label: Text(lab),
//       selected: _selectedLab == lab,
//       selectedColor: const Color(0xFF1A3B5D),
//       labelStyle: TextStyle(
//         color: _selectedLab == lab ? Colors.white : Colors.black,
//       ),
//       onSelected: (_) => setState(() => _selectedLab = lab),
//     ),
//   ).toList(),
// ),


// // ════════════════════════════════════════════
// // 10. FILTER CHIP (select multiple)
// // ════════════════════════════════════════════
// final List<String> _allTags = ['Urgent', 'Pending', 'Done', 'Review'];
// final List<String> _selectedTags = [];

// Wrap(
//   spacing: 8,
//   children: _allTags.map((tag) =>
//     FilterChip(
//       label: Text(tag),
//       selected: _selectedTags.contains(tag),
//       selectedColor: const Color(0xFF1A3B5D).withOpacity(0.2),
//       checkmarkColor: const Color(0xFF1A3B5D),
//       onSelected: (val) {
//         setState(() {
//           if (val) {
//             _selectedTags.add(tag);
//           } else {
//             _selectedTags.remove(tag);
//           }
//         });
//       },
//     ),
//   ).toList(),
// ),
// ```