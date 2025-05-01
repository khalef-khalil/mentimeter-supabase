import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: '.env');
  });

  test('Supabase connection test', () async {
    // Just a simple verification test to see if environment variables are set
    expect(dotenv.env['SUPABASE_URL'], isNotNull);
    expect(dotenv.env['SUPABASE_ANON_KEY'], isNotNull);
    
    // Print values for debugging
    print('SUPABASE_URL: ${dotenv.env['SUPABASE_URL']}');
    print('SUPABASE_ANON_KEY: ${dotenv.env['SUPABASE_ANON_KEY']?.substring(0, 10)}...');
  });
} 