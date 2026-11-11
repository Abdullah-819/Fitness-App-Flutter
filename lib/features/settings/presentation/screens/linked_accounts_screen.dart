import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/app_toast.dart';
import '../../../auth/presentation/widgets/social_logos.dart';

class LinkedAccountsScreen extends StatefulWidget {
  const LinkedAccountsScreen({super.key});

  @override
  State<LinkedAccountsScreen> createState() => _LinkedAccountsScreenState();
}

class _LinkedAccountsScreenState extends State<LinkedAccountsScreen> {
  final Set<String> _connectedAccounts = {'Google'};

  static final _accounts = [
    (name: 'Google', logo: const GoogleLogo(size: 26)),
    (name: 'Apple', logo: const AppleLogo(size: 26)),
    (name: 'Facebook', logo: const FacebookLogo(size: 26)),
    (name: 'Twitter', logo: const TwitterLogo(size: 26)),
  ];

  Future<void> _toggleAccount(String account) async {
    final isConnected = _connectedAccounts.contains(account);
    if (isConnected) {
      final shouldDisconnect = await showDialog<bool>(
        context: context,
        builder: (context) {
          final p = AppPalette.of(context);
          return AlertDialog(
            backgroundColor: p.card,
            title: Text(
              'Disconnect $account?',
              style: TextStyle(color: p.textPrimary),
            ),
            content: Text(
              'You can connect this account again at any time.',
              style: TextStyle(color: p.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Disconnect', style: TextStyle(color: p.danger)),
              ),
            ],
          );
        },
      );
      if (shouldDisconnect != true || !mounted) return;
      setState(() => _connectedAccounts.remove(account));
      AppToast.info('$account disconnected');
      return;
    }

    setState(() => _connectedAccounts.add(account));
    AppToast.success('$account connected');
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: p.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Linked Accounts',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: p.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text(
            'Connect your accounts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: p.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use a linked account to sign in quickly and keep your TrackFit account secure.',
            style: TextStyle(fontSize: 14, color: p.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(16),
              border: p.isDark ? Border.all(color: p.divider) : null,
            ),
            child: Column(
              children: [
                for (var i = 0; i < _accounts.length; i++) ...[
                  _LinkedAccountRow(
                    name: _accounts[i].name,
                    logo: _accounts[i].logo,
                    connected: _connectedAccounts.contains(_accounts[i].name),
                    onPressed: () => _toggleAccount(_accounts[i].name),
                  ),
                  if (i < _accounts.length - 1)
                    Divider(height: 1, color: p.divider),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkedAccountRow extends StatelessWidget {
  final String name;
  final Widget logo;
  final bool connected;
  final VoidCallback onPressed;

  const _LinkedAccountRow({
    required this.name,
    required this.logo,
    required this.connected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          logo,
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: p.textPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: onPressed,
            child: Text(
              connected ? 'Connected' : 'Connect',
              style: TextStyle(
                color: connected ? p.textSecondary : AppColors.primaryPurple,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
