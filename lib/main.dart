import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BravIA Descriptions',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DescriptionPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DescriptionPage extends StatefulWidget {
  @override
  _DescriptionPageState createState() => _DescriptionPageState();
}

class _DescriptionPageState extends State<DescriptionPage> {
  static const platform = MethodChannel('com.example.bravia/descriptions');

  String internshipTitle = "Charging...";
  String internshipCompany = "Charging...";
  String internshipLocation = "Charging...";
  String internshipDescription = "Charging description...";
  List<String> requirements = [];
  List<String> activities = [];
  List<String> benefits = [];
  double salary = 0.0;
  String duration = "";
  String modality = "";
  String schedule = "";

  @override
  void initState() {
    super.initState();
    _setupMethodChannel();
    _requestInternshipData();
  }

  void _setupMethodChannel() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'updateInternshipData':
          _updateInternshipData(call.arguments);
          break;
        default:
          throw PlatformException(
            code: 'Unimplemented',
            details: 'Method ${call.method} not implemented',
          );
      }
    });
  }

  void _updateInternshipData(dynamic data) {
    if (data is Map) {
      setState(() {
        internshipTitle = data['title'] ?? 'Sin título';
        internshipCompany = data['company'] ?? 'Sin empresa';
        internshipLocation = data['location'] ?? 'Sin ubicación';
        internshipDescription = data['description'] ?? 'Sin descripción';
        requirements = List<String>.from(data['requirements'] ?? []);
        activities = List<String>.from(data['activities'] ?? []);
        benefits = List<String>.from(data['benefits'] ?? []);
        salary = (data['salary'] ?? 0.0).toDouble();
        duration = data['duration'] ?? '';
        modality = data['modality'] ?? '';
        schedule = data['schedule'] ?? '';
      });
    }
  }

  void _requestInternshipData() async {
    try {
      await platform.invokeMethod('requestInternshipData');
    } catch (e) {
      print('Error requesting data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con información de la empresa
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[600]!, Colors.blue[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    internshipTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    internshipCompany,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    internshipLocation,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Información básica
            _buildInfoSection(),

            SizedBox(height: 20),

            // Descripción
            _buildSection(
              "📋 Internship description",
              internshipDescription,
              Colors.green,
            ),

            SizedBox(height: 20),

            // Requisitos
            if (requirements.isNotEmpty)
              _buildListSection(
                "✅ Requirements",
                requirements,
                Colors.orange,
              ),

            SizedBox(height: 20),

            // Actividades
            if (activities.isNotEmpty)
              _buildListSection(
                "🎯 Activities",
                activities,
                Colors.purple,
              ),

            SizedBox(height: 20),

            // Beneficios
            _buildListSection(
              "🎁 Benefits",
              benefits.isEmpty ? ["Information not available"] : benefits,
              Colors.teal,
            ),

            SizedBox(height: 30),

            // Botón de acción
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onApplyPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  "Apply Now",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ℹ️ General Information",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[600],
            ),
          ),
          SizedBox(height: 12),
          if (duration.isNotEmpty) _buildInfoRow("Duration", duration),
          if (modality.isNotEmpty) _buildInfoRow("Modality", modality),
          if (schedule.isNotEmpty) _buildInfoRow("Schedule", schedule),
          if (salary > 0) _buildInfoRow("Salary", "\$${salary.toStringAsFixed(0)}"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, Color color) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: color,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(String title, List<String> items, Color color) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: color,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 6, right: 8),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  void _onApplyPressed() async {
    try {
      await platform.invokeMethod('onApplyPressed');
    } catch (e) {
      print('Error applying: $e');
    }
  }
}
