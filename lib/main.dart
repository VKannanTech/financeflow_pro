import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_selector/file_selector.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'models/user.dart';
import 'services/auth_service.dart';
import 'utils/theme.dart';

// Provider to manage file-picking state
class FilePickerProvider with ChangeNotifier {
  List<XFile> _selectedFiles = [];

  List<XFile> get selectedFiles => _selectedFiles;

  Future<void> pickFiles(BuildContext context) async {
    // Request storage permission for Android
    if (Theme.of(context).platform == TargetPlatform.android) {
      var status = await Permission.storage.request();
      if (status.isDenied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission denied')),
          );
        }
        return;
      }
    }

    // Define file types for financial documents
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'Financial Documents',
      extensions: ['pdf', 'csv', 'xlsx', 'doc', 'docx'],
    );

    // Pick multiple files
    final List<XFile> files = await openFiles(acceptedTypeGroups: [typeGroup]);
    if (files.isNotEmpty) {
      _selectedFiles = files;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Picked ${files.length} file(s)')),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No files selected')),
        );
      }
    }
    notifyListeners();
  }
}

void main() {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const BankingApp());
}

class BankingApp extends StatelessWidget {
  const BankingApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap MaterialApp with MultiProvider for state management
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FilePickerProvider()),
        // Add AuthService provider if needed
        Provider<AuthService>(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'FinanceFlow Pro',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
      ),
    );
  }
}

// Sample HomeScreen implementation with file picking
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinanceFlow Pro'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to FinanceFlow Pro',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Trigger file picking
                Provider.of<FilePickerProvider>(context, listen: false)
                    .pickFiles(context);
              },
              child: const Text('Upload Financial Document'),
            ),
            const SizedBox(height: 20),
            Consumer<FilePickerProvider>(
              builder: (context, provider, child) {
                return provider.selectedFiles.isNotEmpty
                    ? Text(
                  'Selected: ${provider.selectedFiles.length} file(s)',
                  style: const TextStyle(fontSize: 16),
                )
                    : const Text(
                  'No files selected',
                  style: TextStyle(fontSize: 16),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}