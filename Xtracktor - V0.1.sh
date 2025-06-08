#!/usr/bin/env bash

# === CONFIG ===
EXTRACT_XISO_DIR="$HOME/extract-xiso-bin"
EXTRACT_XISO_BIN="$EXTRACT_XISO_DIR/extract-xiso"
GITHUB_RELEASE_URL="https://github.com/XboxDev/extract-xiso/releases/download/build-202505152050/extract-xiso_macOS.zip"

# === Barre de progression analyse ===
draw_progress_bar() {
  local progress=$1
  local total=$2
  local width=40
  local filled=$((progress * width / total))
  local empty=$((width - filled))
  local bar=$(printf "%${filled}s" | tr ' ' '#')
  bar+=$(printf "%${empty}s" | tr ' ' '-')
  printf "\r🗂️  Analyse ISO: [%s] (%d/%d)" "$bar" "$progress" "$total"
}

# === Barre de progression extraction (animation fausse) ===
fake_extract_progress() {
  local steps=20
  for ((i = 1; i <= steps; i++)); do
    sleep 0.1
    local bar=$(printf "%-${steps}s" | tr ' ' '.')
    local done=$(printf "%-${i}s" | tr ' ' '#')
    printf "\r    ⏳ Extraction: [%s%s] %d%%" "$done" "${bar:$i}" $((i * 100 / steps))
  done
  echo ""
}

# === Téléchargement auto de extract-xiso ===
if [ ! -x "$EXTRACT_XISO_BIN" ]; then
  echo "🔧 Téléchargement de extract-xiso pour macOS..."
  mkdir -p "$EXTRACT_XISO_DIR"
  curl -L "$GITHUB_RELEASE_URL" -o "$EXTRACT_XISO_DIR/extract-xiso.zip" || { echo "❌ Échec du téléchargement."; exit 1; }
  unzip -o "$EXTRACT_XISO_DIR/extract-xiso.zip" -d "$EXTRACT_XISO_DIR" || { echo "❌ Échec de la décompression."; exit 1; }
  chmod +x "$EXTRACT_XISO_BIN"
  echo "✅ extract-xiso prêt à l’emploi."
fi

# === Demande des chemins avec glissé-déposé autorisé ===
echo "📂 Glisse et dépose le dossier source contenant les ISO Xbox 360, puis appuie sur Entrée :"
read -e SRC_DIR
SRC_DIR="${SRC_DIR/#\~/$HOME}"
SRC_DIR="${SRC_DIR%/}" # Retire le slash final

echo "📁 Glisse et dépose le dossier de destination, puis appuie sur Entrée :"
read -e DEST_DIR
DEST_DIR="${DEST_DIR/#\~/$HOME}"
DEST_DIR="${DEST_DIR%/}"

# Nettoyage des éventuelles quotes autour du chemin (glisser-déposer met parfois des guillemets)
SRC_DIR="${SRC_DIR%\"}"
SRC_DIR="${SRC_DIR#\"}"
DEST_DIR="${DEST_DIR%\"}"
DEST_DIR="${DEST_DIR#\"}"

if [ ! -d "$SRC_DIR" ]; then
  echo "❌ Dossier source invalide : $SRC_DIR"
  exit 1
fi

if [ ! -d "$DEST_DIR" ]; then
  echo "📁 Création du dossier destination..."
  mkdir -p "$DEST_DIR"
fi

# === Récupération des fichiers ISO ===
iso_files=()
while IFS= read -r -d $'\0' file; do
  iso_files+=("$file")
done < <(find "$SRC_DIR" -type f -iname "*.iso" -print0)

total_files=${#iso_files[@]}
if [ "$total_files" -eq 0 ]; then
  echo "❌ Aucun fichier ISO trouvé dans $SRC_DIR"
  exit 1
fi

echo "🔍 $total_files fichier(s) ISO détecté(s)."

# === Boucle d’extraction ===
counter=0
for iso_file in "${iso_files[@]}"; do
  ((counter++))
  draw_progress_bar "$counter" "$total_files"

  relative_path="${iso_file#$SRC_DIR/}"
  base_dir="$(dirname "$relative_path")"
  iso_name="$(basename "$iso_file" .iso)"
  output_dir="$DEST_DIR/$base_dir/$iso_name"

  mkdir -p "$output_dir"

  echo ""
  echo "📦 Extraction de : $iso_file"
  LOGFILE=$(mktemp)

  "$EXTRACT_XISO_BIN" -d "$output_dir" -x "$iso_file" > "$LOGFILE" 2>&1 &
  pid=$!

  while kill -0 "$pid" 2>/dev/null; do
    fake_extract_progress
  done

  wait "$pid"
  ret=$?

  if [ $ret -eq 0 ]; then
    echo "✅ Terminé : $iso_name"
  else
    echo "❌ Échec extraction : $iso_name"
    echo "Détails de l’erreur :"
    cat "$LOGFILE"
  fi

  rm "$LOGFILE"
done

echo -e "\n🎉 Tous les fichiers ont été extraits avec succès."
