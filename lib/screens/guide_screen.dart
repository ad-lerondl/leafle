import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comment fonctionne Leafle ?'),
        backgroundColor: kForestPrimary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: kBackground,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _card(
            context,
            icon: '🌱',
            title: "L'énergie de Leafle",
            lines: const [
              "Leafle perd de l'énergie avec le temps.",
              "Plus votre forêt est grande, plus il se fatigue vite.",
              "Si Leafle est à court d'énergie, la forêt souffre.",
              "Gagnez des points en accomplissant vos routines pour nourrir Leafle et garder la forêt en bonne santé.",
            ],
          ),
          const SizedBox(height: 12),
          _card(
            context,
            icon: '⭐',
            title: 'Points et embonpoint',
            lines: const [
              "En faisant vos routines (et vos anti‑routines), vous gagnez des points, qui sont mis en réserve.",
              "Votre embonpoint est directement lié à vos points en réserve: 1 niveau tous les 100 points.",
              "Plus l'embonpoint de Leafle est élevé, plus il perd de l'énergie rapidement !",
            ],
          ),
          const SizedBox(height: 12),
          _card(
            context,
            icon: '📈',
            title: 'Progression du jour',
            lines: const [
              "Chaque routine a un nombre d'étoiles.",
              "Si la somme des étoiles de vos routines dépasse 100, les gains sont proportionnels sur une base de 100 points max par jour.",
              "Dans l'onglet Routines, la progression affiche les points gagnés et le maximum du jour (ex: 42 / 100).",
            ],
          ),
          const SizedBox(height: 12),
          _card(
            context,
            icon: '🌳',
            title: 'Planter des arbres',
            lines: const [
              "Dépensez vos points pour planter des arbres (petit, moyen, grand).",
              "Une grande forêt est belle… mais cela demande plus d'énergie à Leafle.",
            ],
          ),
          const SizedBox(height: 12),
          _card(
            context,
            icon: '🌟',
            title: 'Arbres dorés (bonus)',
            lines: const [
              "Complétez TOUTES vos routines un jour pour obtenir un arbre doré automatique !",
              "Les arbres dorés sont très résistants (-60% de dégâts) et se soignent rapidement.",
              "Un excellent objectif quotidien pour garder votre forêt en bonne santé.",
            ],
          ),
          const SizedBox(height: 12),
          _card(
            context,
            icon: '🧚',
            title: 'Mini‑Leafle (assistants)',
            lines: const [
              "Les assistants réduisent la vitesse de perte d'énergie.",
              "Ils deviennent utiles quand la forêt grandit.",
            ],
          ),
          const SizedBox(height: 12),
          _card(
            context,
            icon: '🚫',
            title: 'Anti-routines : réduire ses dépendances',
            lines: const [
              "Les anti-routines vous permettent d'identifier vos dépendances (réseaux sociaux, café, etc.).",
              "Fixez un seuil quotidien à ne pas dépasser (ex: 30 min d'écran).",
              "Renseignez votre valeur du jour. Si vous restez sous le seuil, vous gagnez des points.",
              "C'est une manière de prendre conscience et de progressivement réduire vos comportements problématiques.",
            ],
          ),
          const SizedBox(height: 12),
          _card(
            context,
            icon: '🔁',
            title: 'L\'équilibre',
            lines: const [
              "Gagnez des points pour nourrir Leafle → Leafle grossit et son embonpoint augmente → Leafle se fatigue plus vite.",
              "Dépensez des points (arbres, assistants) pour retrouver un bon rythme.",
            ],
          ),
          const SizedBox(height: 20),
          _donationCard(context),
          const SizedBox(height: 12),
          _contactCard(context),
        ],
      ),
    );
  }

  Widget _donationCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kForestPrimary.withValues(alpha: 0.8), kForestPrimaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kForestPrimary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('💚', style: TextStyle(fontSize: 24)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Soutenir le projet',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Si Leafle vous aide à améliorer vos habitudes quotidiennes ou à réduire vos dépendances, pensez à soutenir le développement de l\'application ! Merci par avance pour votre générosité !! 🌳💚',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: () async {
                final Uri url = Uri.parse('https://donate.stripe.com/28E9AT5y5fXv8kDgMvdMI01');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.platformDefault);
                } else {
                  await Clipboard.setData(ClipboardData(text: url.toString()));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              '😢 Impossible d\'ouvrir le lien automatiquement \n✅ Lien de paiement sécurisé copié dans le presse-papier : collez-le directement dans votre navigateur préféré.'),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 8)),
                    );
                  }
                }
              },
              icon: const Icon(Icons.favorite, color: Colors.white),
              label: const Text(
                'Faire un don',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: const BorderSide(color: Colors.white, width: 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kForestPrimary.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('💬', style: TextStyle(fontSize: 24)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Bugs ou suggestions ?',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kForestPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Salut, moi c\'est Adam ! Si vous trouvez des bugs ou avez des suggestions d\'amélioration, n\'hésitez pas à me contacter ! Et si vous aimez Leafle, un petit message sur les réseaux sociaux ou un soutien financier (oui, je suis étudiant et j\'ai un régime alimentaire à base de pâtes...! 😅) fait toujours plaisir 😊',
            style: TextStyle(color: Colors.grey[800], fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final Uri url = Uri.parse('https://www.instagram.com/ad_lerondl');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.platformDefault);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Impossible d\'ouvrir Instagram'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.camera_alt, size: 20),
                  label: const Text('Instagram', style: TextStyle(fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE1306C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final Uri url = Uri.parse('https://t.me/ad_lerondl');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.platformDefault);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Impossible d\'ouvrir Telegram'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.send, size: 20),
                  label: const Text('Telegram', style: TextStyle(fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0088CC),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '@ad_lerondl',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, {required String icon, required String title, required List<String> lines}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kForestPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...lines.map((l) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(l, style: TextStyle(color: Colors.grey[800], fontSize: 14)),
              )),
        ],
      ),
    );
  }
}
