#!/bin/bash
# Project Starter Template Installer
# Fetches project starter template from GitHub repository
# Usage: curl -fsSL <url-to-this-script> | bash

set -e

# GitHub repository configuration
GITHUB_USER="${TEMPLATE_GITHUB_USER:-ParkAndre}"
GITHUB_REPO="${TEMPLATE_GITHUB_REPO:-project-starter-template}"
GITHUB_BRANCH="${TEMPLATE_GITHUB_BRANCH:-main}"
BASE_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}📦 Project Starter Template Installer${NC}"
echo -e "${BLUE}======================================${NC}\n"

# Create directories
echo -e "${YELLOW}Creating directories...${NC}"
mkdir -p .claude
mkdir -p .commands
mkdir -p .husky

# Download files
echo -e "${YELLOW}Downloading template files...${NC}"

files=(
    "CLAUDE.md"
    "CLAUDE.local.md.example"
    ".gitignore"
    ".claude/security.md"
    ".claude/testing.md"
    ".claude/api-design.md"
    ".claude/structure.md"
    ".claude/database.md"
    ".claude/standards.md"
    ".claude/issue-creation.md"
    ".claude/settings.json.example"
    ".commands/README.md"
    ".commands/analyze.md"
    ".commands/research.md"
    ".commands/update-project.md"
    ".commands/commit.md"
    ".commands/merge.md"
    ".commands/e2e.md"
    ".husky/pre-commit.example"
)

for file in "${files[@]}"; do
    echo -e "  Downloading ${file}..."
    if command -v curl &> /dev/null; then
        curl -fsSL "${BASE_URL}/${file}" -o "${file}"
    elif command -v wget &> /dev/null; then
        wget -q "${BASE_URL}/${file}" -O "${file}"
    else
        echo -e "${YELLOW}⚠️  Neither curl nor wget found. Please install one.${NC}"
        exit 1
    fi
done

echo -e "\n${GREEN}✓ All files downloaded successfully!${NC}\n"

# Update .gitignore if it exists
if [ -f ".gitignore" ]; then
    if ! grep -q "CLAUDE.local.md" .gitignore; then
        echo -e "${YELLOW}Updating .gitignore...${NC}"
        echo "" >> .gitignore
        echo "# Claude Code local settings (personal, not committed)" >> .gitignore
        echo "CLAUDE.local.md" >> .gitignore
        echo ".claude/settings.local.json" >> .gitignore
        echo -e "${GREEN}✓ Updated .gitignore${NC}"
    fi
fi

echo -e "\n${BLUE}======================================${NC}"
echo -e "${GREEN}✓ Installation complete!${NC}"
echo -e "${BLUE}======================================${NC}\n"

echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. ${BLUE}CUSTOMIZE${NC} CLAUDE.md 'Commands' section with your project commands"
echo -e "  2. ${BLUE}COPY${NC} .claude/settings.json.example to .claude/settings.json and customize hooks"
echo -e "  3. ${BLUE}COPY${NC} CLAUDE.local.md.example to CLAUDE.local.md for personal notes"
echo -e "  4. ${BLUE}SETUP HUSKY${NC}: bun add -d husky && bunx husky init && cp .husky/pre-commit.example .husky/pre-commit"
echo -e "  5. ${BLUE}COMMIT${NC}: git add CLAUDE.md .claude/ .commands/ .husky/ .gitignore && git commit -m 'Add project guidelines'"
echo -e "  6. ${BLUE}TEST${NC} it works - ask Claude: 'What are our commit message conventions?'\n"

echo -e "${BLUE}Tip:${NC} Press ${YELLOW}#${NC} in Claude Code to quickly edit CLAUDE.md during conversation\n"
