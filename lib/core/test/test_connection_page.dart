import 'package:flutter/material.dart';
import 'package:spotly/config/supabase/supabase_config.dart';

class TestConnectionPage extends StatefulWidget {
  const TestConnectionPage({super.key});

  @override
  State<TestConnectionPage> createState() => _TestConnectionPageState();
}

class _TestConnectionPageState extends State<TestConnectionPage> {
  String message = 'Probando conexión...';

  @override
  void initState() {
    super.initState();
    testConnection();
  }

  Future<void> testConnection() async {
    try {
      final response = await SupabaseConfig.client
        .from('lugares') // 👈 CAMBIAR ESTO
        .select()
        .limit(1);

      setState(() {
        message = '✅ Conexión exitosa: ${response.length} registros encontrados';
      });
    } catch (e) {
      setState(() {
        message = '❌ Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Supabase')),
      body: Center(
        child: Text(
          message,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}