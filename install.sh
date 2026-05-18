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
mkdir -p .claude/skills/analyze
mkdir -p .claude/skills/catchup
mkdir -p .claude/skills/commit
mkdir -p .claude/skills/e2e
mkdir -p .claude/skills/fix-issue
mkdir -p .claude/skills/merge
mkdir -p .claude/skills/refactor
mkdir -p .claude/skills/research
mkdir -p .claude/skills/review
mkdir -p .claude/skills/security-scan
mkdir -p .claude/skills/tdd
mkdir -p .claude/skills/update-project
mkdir -p .claude/skills/update-readme
mkdir -p .claude/skills/verify
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
    ".claude/database.md"
    ".claude/standards.md"
    ".claude/issue-creation.md"
    ".claude/settings.json.example"
    ".claude/settings-hooks-examples.md"

    # New SKILL.md format (preferred)
    ".claude/skills/analyze/SKILL.md"
    ".claude/skills/catchup/SKILL.md"
    ".claude/skills/commit/SKILL.md"
    ".claude/skills/e2e/SKILL.md"
    ".claude/skills/fix-issue/SKILL.md"
    ".claude/skills/merge/SKILL.md"
    ".claude/skills/refactor/SKILL.md"
    ".claude/skills/research/SKILL.md"
    ".claude/skills/review/SKILL.md"
    ".claude/skills/security-scan/SKILL.md"
    ".claude/skills/tdd/SKILL.md"
    ".claude/skills/update-project/SKILL.md"
    ".claude/skills/update-readme/SKILL.md"
    ".claude/skills/verify/SKILL.md"

    ".husky/pre-commit.example"
)

for file in "${files[@]}"; do
    # Skip .gitignore if it already exists (don't overwrite project-specific ignores)
    if [ "$file" = ".gitignore" ] && [ -f ".gitignore" ]; then
        echo -e "  ${YELLOW}Skipping ${file} (already exists — not overwriting)${NC}"
        continue
    fi

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
echo -e "  2. ${BLUE}COPY${NC} .claude/settings.json.example to .claude/settings.json"
echo -e "     Add your stack's permissions and hooks (see .claude/settings-hooks-examples.md)"
echo -e "  3. ${BLUE}COPY${NC} CLAUDE.local.md.example to CLAUDE.local.md for personal notes"
echo -e "  4. ${BLUE}SETUP PRE-COMMIT${NC}: cp .husky/pre-commit.example .husky/pre-commit && chmod +x .husky/pre-commit"
echo -e "     Then uncomment your stack's section in .husky/pre-commit"
echo -e "  5. ${BLUE}COMMIT${NC}: git add CLAUDE.md .claude/ .husky/ .gitignore && git commit -m 'Add project guidelines'"
echo -e "  6. ${BLUE}TEST${NC} it works - ask Claude: 'What are our commit message conventions?'\n"

echo -e "${BLUE}Tip:${NC} Press ${YELLOW}#${NC} in Claude Code to quickly edit CLAUDE.md during conversation\n"
