import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bravia Flutter Module',
      // IMPORTANTE: No definir initialRoute aquí, se maneja desde Android
      onGenerateRoute: (RouteSettings settings) {
        // DEBUG: Imprimir la ruta que se está intentando cargar
        print('🐛 Flutter Route: ${settings.name}');
        print('🐛 Flutter Arguments: ${settings.arguments}');

        // Parsear la ruta y sus parámetros
        final uri = Uri.parse(settings.name ?? '/');
        final path = uri.path;
        final queryParams = uri.queryParameters;

        print('🐛 Path: $path');
        print('🐛 Query Params: $queryParams');

        switch (path) {
          case '/demo':
            return MaterialPageRoute(builder: (_) => const DemoPage());

          case '/chat':
            final internshipsJson = queryParams['internships'] ?? '[]';
            print('🐛 Internships JSON: $internshipsJson');
            return MaterialPageRoute(
              builder: (_) => ChatMainPage(initialInternshipsJson: internshipsJson),
            );

          case '/':
          default:
          // Página por defecto con información de debug
            return MaterialPageRoute(
              builder: (_) => DebugHomePage(
                routeName: settings.name,
                arguments: settings.arguments,
              ),
            );
        }
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
    );
  }
}

// Página de debug para ver qué está pasando
class DebugHomePage extends StatelessWidget {
  final String? routeName;
  final Object? arguments;

  const DebugHomePage({
    super.key,
    this.routeName,
    this.arguments,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Debug'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🐛 INFORMACIÓN DE DEBUG',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text('Ruta recibida: ${routeName ?? "null"}'),
            const SizedBox(height: 10),
            Text('Argumentos: ${arguments?.toString() ?? "null"}'),
            const SizedBox(height: 20),
            const Text(
              'Si ves esta página, significa que Flutter no está recibiendo la ruta correcta desde Android.',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Intentar ir manualmente a demo
                Navigator.pushReplacementNamed(context, '/demo');
              },
              child: const Text('Ir a Demo'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Intentar ir manualmente a chat
                Navigator.pushReplacementNamed(context, '/chat');
              },
              child: const Text('Ir a Chat'),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== DEMO PAGE ==========
class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  static const platform = MethodChannel('com.example.bravia/demo');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎯 Demo Flutter'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => platform.invokeMethod('close'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.flutter_dash,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              '¡Esta es la DEMO de Flutter!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Esta página solo se debe mostrar cuando presiones el botón "Ver demo Flutter".',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('¡Demo funcionando!')),
                );
              },
              child: const Text('Probar Demo'),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== CHAT MODULE ==========
class ChatMainPage extends StatefulWidget {
  final String initialInternshipsJson;

  const ChatMainPage({super.key, required this.initialInternshipsJson});

  @override
  State<ChatMainPage> createState() => _ChatMainPageState();
}

class Internship {
  final int id;
  final String title;
  final String company;

  Internship({required this.id, required this.title, required this.company});

  factory Internship.fromJson(Map<String, dynamic> json) {
    return Internship(
      id: json['id']?.toInt() ?? 0,
      title: json['title'] ?? 'Sin título',
      company: json['company'] ?? 'Sin empresa',
    );
  }
}

class _ChatMainPageState extends State<ChatMainPage> {
  static const platform = MethodChannel('com.example.bravia/chat');
  List<Internship> internships = [];
  int _selectedIndex = 0;
  String? _conversationId;
  Internship? _selectedInternship;

  @override
  void initState() {
    super.initState();
    print('🐛 ChatMainPage initState - JSON: ${widget.initialInternshipsJson}');
    _loadInitialInternships();
  }

  void _loadInitialInternships() {
    try {
      final List<dynamic> jsonList = json.decode(widget.initialInternshipsJson);
      setState(() {
        internships = jsonList.map((json) => Internship.fromJson(json)).toList();
      });
      print('🐛 Internships loaded: ${internships.length}');
    } catch (e) {
      print("🐛 Error decoding internships: $e");
    }
  }

  void _startInterview(Internship internship) async {
    try {
      final conversationId = await platform.invokeMethod(
        'startInterview',
        internship.id.toString(),
      );
      setState(() {
        _conversationId = conversationId;
        _selectedInternship = internship;
        _selectedIndex = 1;
      });
      print('🐛 Interview started: $conversationId');
    } on PlatformException catch (e) {
      print("🐛 Error starting interview: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? '🎯 Chat IA - Seleccionar' : '🎯 Chat IA - Entrevista'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => platform.invokeMethod('close'),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _buildPage(_selectedIndex),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Simulador de Entrevistas',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Seleccionar Internship'),
            selected: _selectedIndex == 0,
            onTap: () {
              setState(() => _selectedIndex = 0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Chat IA'),
            selected: _selectedIndex == 1,
            enabled: _conversationId != null,
            onTap: _conversationId != null ? () {
              setState(() => _selectedIndex = 1);
              Navigator.pop(context);
            } : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return _buildInternshipsList();
      case 1:
        return _conversationId != null && _selectedInternship != null
            ? ChatScreen(
          conversationId: _conversationId!,
          internship: _selectedInternship!,
        )
            : const Center(child: Text('Selecciona un internship para comenzar'));
      default:
        return Container();
    }
  }

  Widget _buildInternshipsList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selecciona un internship para practicar la entrevista:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text('Debug: ${internships.length} internships cargados'),
          const SizedBox(height: 10),
          Expanded(
            child: internships.isEmpty
                ? const Center(child: Text('No hay internships disponibles'))
                : ListView.builder(
              itemCount: internships.length,
              itemBuilder: (context, index) {
                final internship = internships[index];
                return Card(
                  child: ListTile(
                    title: Text(internship.title),
                    subtitle: Text(internship.company),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () => _startInterview(internship),
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

// ChatScreen igual que antes pero con más debug
class ChatScreen extends StatefulWidget {
  final String conversationId;
  final Internship internship;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.internship,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  static const platform = MethodChannel('com.example.bravia/chat');
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print('🐛 ChatScreen initState for: ${widget.internship.title}');
    _addSystemMessage(
        "Bienvenido a la simulación de entrevista para el puesto de ${widget.internship.title} en ${widget.internship.company}. "
            "Actuaré como entrevistador. ¿Estás listo para comenzar?"
    );
  }

  void _addSystemMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: false, isSystem: true));
    });
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(ChatMessage(text: message, isUser: true));
      _isLoading = true;
    });

    _messageController.clear();

    try {
      final response = await platform.invokeMethod('sendMessage', {
        'conversationId': widget.conversationId,
        'message': message,
      });

      setState(() {
        _messages.add(ChatMessage(text: response, isUser: false));
        _isLoading = false;
      });
      print('🐛 Message sent and response received');
    } on PlatformException catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: "Error: ${e.message}",
          isUser: false,
          isError: true,
        ));
        _isLoading = false;
      });
      print('🐛 Error sending message: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ESTE HEADER NO SE MOSTRARÁ si quieres que se vea el navbar de la app
        // Lo comentamos para debug
        /*
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.internship.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                widget.internship.company,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        */

        // Lista de mensajes
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: _messages.length + (_isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _messages.length && _isLoading) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      CircularProgressIndicator(strokeWidth: 2),
                      SizedBox(width: 12),
                      Text('IA está escribiendo...'),
                    ],
                  ),
                );
              }

              final message = _messages[index];
              return Align(
                alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  padding: const EdgeInsets.all(12.0),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.8,
                  ),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? Theme.of(context).colorScheme.primary
                        : message.isSystem
                        ? Colors.orange[100]
                        : message.isError
                        ? Colors.red[100]
                        : Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser
                          ? Theme.of(context).colorScheme.onPrimary
                          : message.isError
                          ? Colors.red[800]
                          : Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Input de mensaje
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    hintText: 'Escribe tu respuesta...',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                  maxLines: null,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _isLoading ? null : _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isSystem;
  final bool isError;

  ChatMessage({
    required this.text,
    this.isUser = false,
    this.isSystem = false,
    this.isError = false,
  });
}