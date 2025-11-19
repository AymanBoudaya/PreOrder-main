import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../data/repositories/etablissement/etablissement_repository.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/popups/loaders.dart';
import '../../controllers/user_controller.dart';
import '../../../shop/controllers/etablissement_controller.dart';
import '../../../shop/models/etablissement_model.dart';
import '../../../shop/models/statut_etablissement_model.dart';

class AdminGestionEtablissementsScreen extends StatefulWidget {
  const AdminGestionEtablissementsScreen({super.key});

  @override
  State<AdminGestionEtablissementsScreen> createState() =>
      _AdminGestionEtablissementsScreenState();
}

class _AdminGestionEtablissementsScreenState
    extends State<AdminGestionEtablissementsScreen> {
  final EtablissementController _etablissementController =
      Get.put(EtablissementController(EtablissementRepository()));
  final UserController _userController = Get.find<UserController>();

  bool _isLoading = false;
  List<Etablissement> _etablissements = [];

  @override
  void initState() {
    super.initState();
    _loadEtablissements();
  }

  Future<void> _loadEtablissements() async {
    setState(() => _isLoading = true);
    try {
      final userRole = _userController.userRole;
      final user = _userController.user.value;

      // Vérifier le rôle de l'utilisateur
      if (userRole == 'Gérant' && user.id.isNotEmpty) {
        // Les gérants ne voient que leurs propres établissements
        final data =
            await _etablissementController.fetchEtablissementsByOwner(user.id);
        setState(() => _etablissements = data ?? []);
      } else if (userRole == 'Admin') {
        // Les admins voient tous les établissements
        final data = await _etablissementController.getTousEtablissements();
        setState(() => _etablissements = data);
      } else {
        // Rôle non autorisé
        setState(() => _etablissements = []);
      }
    } catch (e) {
      // print('Erreur chargement établissements: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _changerStatut(Etablissement etab) async {
    final userRole = _userController.userRole;

    // Seuls les admins peuvent changer le statut
    if (userRole != 'Admin') {
      TLoaders.warningSnackBar(
        title: 'Permission refusée',
        message:
            'Seuls les administrateurs peuvent modifier le statut des établissements',
      );
      return;
    }

    StatutEtablissement? nouveauStatut = await showDialog<StatutEtablissement>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Modifier le statut"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: StatutEtablissement.values.map((statut) {
              return RadioListTile<StatutEtablissement>(
                title: Text(THelperFunctions.getStatutText(statut)),
                value: statut,
                groupValue: etab.statut,
                activeColor: THelperFunctions.getStatutColor(statut),
                onChanged: (value) {
                  Navigator.pop(context, value);
                },
              );
            }).toList(),
          ),
        );
      },
    );

    if (nouveauStatut != null && nouveauStatut != etab.statut) {
      setState(() => _isLoading = true);
      final success = await _etablissementController.changeStatutEtablissement(
          etab.id!, nouveauStatut);
      if (success) {
        _loadEtablissements(); // Rafraîchir la liste
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userRole = _userController.userRole;

    // Vérifier que l'utilisateur est Admin ou Gérant
    if (userRole != 'Admin' && userRole != 'Gérant') {
      return const Scaffold(
        body: Center(
          child: Text(
            "Accès refusé — réservé aux administrateurs et gérants",
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: TAppBar(
        title: const Text("Gestion des établissements"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEtablissements,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _etablissements.isEmpty
              ? const Center(child: Text("Aucun établissement trouvé"))
              : ListView.builder(
                  itemCount: _etablissements.length,
                  itemBuilder: (context, index) {
                    final etab = _etablissements[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: THelperFunctions.getStatutColor(etab.statut),
                          child: const Icon(Icons.store, color: Colors.white),
                        ),
                        title: Text(etab.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(etab.address),
                            const SizedBox(height: 4),
                            Text(
                              THelperFunctions.getStatutText(etab.statut),
                              style: TextStyle(
                                color: THelperFunctions.getStatutColor(etab.statut),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: userRole == 'Admin'
                            ? IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _changerStatut(etab),
                              )
                            : null, // Les gérants ne peuvent pas modifier le statut
                      ),
                    );
                  },
                ),
    );
  }
}
