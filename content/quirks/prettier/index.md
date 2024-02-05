---
title: "Ma config' Prettier (pour VSCode)"
date: 2023-06-04
draft: false
description: 'Si vous souhaitez me copier, vous pouvez utiliser les mêmes fichiers de configuration que moi pour utiliser Prettier.'
topics: ['Workflow', 'Débutant']
slug: 'ma-configuration-prettier-pour-visual-studio-code'
---

---

{{< lead >}} **Si vous souhaitez me copier, vous pouvez utiliser les mêmes fichiers de configuration que moi.** {{< /lead >}}

{{< alert "circle-info" >}} Bien que cet article couvre en priorité VSCode, **vous n'aurez pas grand chose à modifier pour vous en sortir si vous
utilisez un autre IDE/éditeur de code.** {{< /alert >}}

---

# Ma configuration Prettier

Je crée toujours un dossier `.vscode` à la racine de mes dossiers de travail, ainsi qu'un fichier `.prettierrc`.

Mon fichier `.prettierrc` :

```json
{
  "singleQuote": true,
  "printWidth": 150,
  "proseWrap": "always",
  "tabWidth": 2,
  "useTabs": false,
  "trailingComma": "none",
  "bracketSpacing": true,
  "bracketSameLine": false,
  "semi": true
}
```

Mon fichier `.vscode/extensions.json` :

```json
{
  "recommendations": ["esbenp.prettier-vscode"]
}
```

Mon fichier `.vscode/settings.json` :

```json
{
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.bracketPairColorization.enabled": true,
  "editor.formatOnSave": true,
  "editor.formatOnPaste": true,
  "editor.wordWrap": "on",
  "editor.codeActionsOnSave": {
    "source.organizeImports": true
  }
}
```

N'oubliez pas de modifier ou créer votre fichier `.gitignore`, dans le même dossier que votre fichier `.prettierrc`, et d'y ajouter ces règles :

```yaml
.vscode/* !.vscode/settings.json !.vscode/extensions.json
```

_Happy coding_.
