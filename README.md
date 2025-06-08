# The Extractor XISO
🧩 Script d'extraction d'ISO Xbox 360 avec extract-xiso (macOS/Linux)

Ce script permet d'extraire automatiquement tous les fichiers .iso Xbox 360 depuis un dossier source vers un dossier de destination, en utilisant l'utilitaire extract-xiso. Il est compatible macOS (64 bits) et Linux, tant que extract-xiso est placé dans le même dossier que le script.

📦 Fonctionnalités

Détection automatique de tous les fichiers .iso dans un dossier source.
Extraction dans des sous-dossiers nommés proprement.
Affichage d'une barre de progression globale et d'une animation pour chaque extraction.
Compatible glisser-déposer pour définir les chemins dans le terminal.
Affiche les erreurs détaillées si une extraction échoue.
🔧 Prérequis

macOS 64 bits (Intel ou Apple Silicon) ou Linux 64 bits.
L'outil extract-xiso :
Pour macOS, tu peux extraire le binaire depuis :
👉 X360_ISO_Hacker.app > Contents/Resources/extract-xiso
Disponible ici
Pour Linux, télécharge une version compatible depuis GitHub ou des sources communautaires.
Le fichier extract-xiso doit être placé dans le même dossier que ce script et avoir les permissions d'exécution :
chmod +x extract-xiso
▶️ Utilisation

Place le script et le binaire extract-xiso dans le même dossier.
Rends le script exécutable :
chmod +x ton_script.sh
Lance-le :
./ton_script.sh
🖱️ Glisse-dépose le dossier source contenant les .iso Xbox 360 dans le terminal, puis appuie sur Entrée.
🖱️ Glisse-dépose le dossier de destination, puis appuie sur Entrée.
L’extraction démarre automatiquement, avec suivi de progression.
📁 Structure générée

Chaque ISO est extrait dans un sous-dossier structuré comme suit :

[dossier destination]/[chemin relatif depuis source]/[nom de l'ISO sans extension]/
🔒 Remarques

Le dossier système $SystemUpdate (présent dans certains ISO) est ignoré pendant l'extraction.
Le script fonctionne sans dépendances externes autres que bash et extract-xiso.
📞 Support

En cas de problème :

Vérifie que extract-xiso est bien un exécutable 64 bits.
Consulte les logs affichés si une extraction échoue.
Assure-toi d’avoir les bons droits sur les répertoires source et destination.
