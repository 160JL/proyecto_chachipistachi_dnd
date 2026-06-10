import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:proyecto_chachipistachi_dnd/l10n/app_localizations.dart';
import 'package:proyecto_chachipistachi_dnd/models/changelog.dart';
import 'package:proyecto_chachipistachi_dnd/service/auth_service.dart';
import 'package:proyecto_chachipistachi_dnd/service/ad_service.dart';
import 'package:proyecto_chachipistachi_dnd/service/monster_ability_registry_service.dart';
import 'package:proyecto_chachipistachi_dnd/service/monster_storage_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final String _version = appChangelogES.isNotEmpty ? appChangelogES.first.version : "";
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isUpdatingRegistry = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAndLoadAd();
    _checkRegistryConsistency();
  }

  /// Verifica si el registro de habilidades coincide con el usuario actual.
  /// Si no coincide, actualiza las habilidades locales en segundo plano.
  Future<void> _checkRegistryConsistency() async {
    if (_isUpdatingRegistry) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final registryService = MonsterAbilityRegistryService();

    // Solo verificamos si el registro base ya existe
    if (await registryService.isRegistryBuilt()) {
      final isConsistent = await registryService.isRegistryConsistentWithUser(
        authService.currentUser?.uid
      );

      if (!isConsistent) {
        setState(() => _isUpdatingRegistry = true);
        try {
          final localMonsters = await MonsterStorageService().getMonsters();
          await registryService.updateLocalEntriesOnly(localMonsters);
        } catch (e) {
          debugPrint("Error actualizando registro para el nuevo usuario: $e");
        } finally {
          if (mounted) setState(() => _isUpdatingRegistry = false);
        }
      }
    }
  }

  /// Verifica el estado VIP y carga o libera el anuncio según corresponda.
  void _checkAndLoadAd() {
    final authService = Provider.of<AuthService>(context);
    if (!authService.isVip) {
      if (_bannerAd == null) {
        _loadBannerAd();
      }
    } else {
      _disposeAd();
    }
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('Error al cargar banner: ${err.message}');
          ad.dispose();
          _bannerAd = null;
          setState(() {
            _isAdLoaded = false;
          });
        },
      ),
    )..load();
  }

  void _disposeAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    if (_isAdLoaded) {
      setState(() {
        _isAdLoaded = false;
      });
    }
  }

  @override
  void dispose() {
    _disposeAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle, style: const TextStyle(letterSpacing: 2)),
        actions: [
          // Botón para simular cambio VIP (útil para pruebas de anuncios)
          /**IconButton(
            icon: Icon(authService.isVip ? Icons.star : Icons.star_border),
            onPressed: () => authService.toggleVip(),
            tooltip: "Toggle VIP",
          ),**/
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          border: Border.symmetric(
            vertical: BorderSide(color: primaryColor.withAlpha(30), width: 10),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isUpdatingRegistry)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 15,
                                      height: 15,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Sincronizando habilidades...",
                                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                                    ),
                                  ],
                                ),
                              ),
                            Icon(Icons.menu_book, size: 60, color: primaryColor),
                            const SizedBox(height: 10),
                            Text(
                              l10n.mainMenu,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                letterSpacing: 4,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const SizedBox(height: 30),
                            _buildMenuButton(context, l10n.battleSimulation, Icons.grid_on, "/battlescreen"),
                            _buildMenuButton(context, l10n.initiativeTracker, Icons.list_alt, "/initiative"),
                            _buildMenuButton(context, l10n.createNewCreature, Icons.add_circle_outline, "/create"),
                            _buildMenuButton(context, l10n.consultBestiary, Icons.public, "/api"),
                            _buildMenuButton(context, l10n.mySavedCreatures, Icons.storage, "/repository"),
                            if (!authService.isGuest)
                              _buildMenuButton(context, l10n.publicBestiary, Icons.cloud_sync, "/public"),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_version.isNotEmpty)
                    Positioned(
                      bottom: 12,
                      right: 16,
                      child: _buildVersionTag(context),
                    ),
                ],
              ),
            ),
            // Mostrar anuncio real si no es VIP y el anuncio se cargó
            if (!authService.isVip && _bannerAd != null && _isAdLoaded)
              Container(
                alignment: Alignment.center,
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionTag(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('v$_version', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => _showChangelog(context),
          child: Icon(Icons.history, size: 20, color: Theme.of(context).colorScheme.primary),
        ),
      ],
    );
  }

  void _showChangelog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final changelog = isEn ? appChangelogEN : appChangelogES;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.changelogTitle),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: changelog.length,
            itemBuilder: (context, index) {
              final entry = changelog[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${l10n.version} ${entry.version} (${entry.date})",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  ...entry.changes.map((change) => Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 2.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("• "),
                        Expanded(child: Text(change)),
                      ],
                    ),
                  )),
                  const Divider(),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.close)),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String text, IconData icon, String? route) {
    return Padding(
      key: ValueKey("btn_$text"),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pushNamed(context, route!),
        icon: Icon(icon),
        label: Text(text, style: const TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(300, 55),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }
}
