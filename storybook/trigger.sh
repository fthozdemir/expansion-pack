#!/bin/bash

RED='\033[0;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
NC='\033[0m'

echo -e "${CYAN}========================="
echo "Storybook Expansion"
echo "========================="
echo -e "${NC}"

#region  //*=========== Install Packages ===========
echo -e "${NC}"
echo -e "${GREEN}[Step 1] Initializing Storybook ${NC}"
echo -e "This may take a while to download."
echo ""
echo y | pnpm dlx storybook@latest init
echo -e ""
echo ""
echo npx storybook@latest add @storybook/addon-themes
echo -e ""

echo -e "Installing Dev Packages: ${GREEN}plop inquirer-fuzzy-path"
echo -e "${NC}"
pnpm install -D  plop inquirer-fuzzy-path


echo -e "${GREEN}[Step 2] Adding BROWSER=none to pnpm storybook${NC}"
npx -y npe scripts.storybook "storybook dev -p 6006 --ci"

echo -e "${GREEN}[Step 3] Disabling Telemetry data of Storybook${NC}"
# Insert the core configuration in .storybook/main.ts
awk '/const config: StorybookConfig = {/ {
    print
    print "  core: {"
    print "    disableTelemetry: true, // 👈 Disables telemetry"
    print "  },"
    next
}1' .storybook/main.ts > .storybook/main.tmp && mv .storybook/main.tmp .storybook/main.ts

# endregion  //*======== Install Packages ===========

#region  //*=========== Create Directories ===========
mkdir -p src/generators
#endregion  //*======== Create Directories ===========

#region  //*=========== Downloading Files ===========
echo ""
echo -e "${GREEN}[Step 4] Downloading files${NC}"
echo ""

DIRNAME="storybook"

files=(
  "plopfile.js"
  "src/generators/story.js"
)
for i in "${files[@]}"
do
  echo "Downloading... $i"
  curl -LJs -o $i https://raw.githubusercontent.com/fthozdemir/expansion-pack/main/$DIRNAME/$i
done

echo -e "${GREEN}[Step 6] Adding import to .storybook/preview.ts${NC}"
# Add import statement to the first line of .storybook/preview.ts
PREVIEW_TS=".storybook/preview.ts"
IMPORT_STATEMENT='import "@/styles/globals.css";'

if ! grep -q "$IMPORT_STATEMENT" "$PREVIEW_TS"; then
  { echo "$IMPORT_STATEMENT"; cat "$PREVIEW_TS"; } > temp && mv temp "$PREVIEW_TS"
  if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to add import statement to $PREVIEW_TS.${NC}"
    exit 1
  fi
else
  echo -e "${GREEN}Import statement already exists in $PREVIEW_TS.${NC}"
fi

echo ""
echo -e "${CYAN}============================================"
echo "🔋 Storybook Expansion Completed"
echo "Run pnpm plop to generate your storybook components"
echo "Run pnpm storybook to start the storybook"

