---
title: "Mon vieux grimoire (back-end d'un site de notation de livres)"
date: 2023-06-06
draft: false
description: "Avant dernier projet du parcours de développeur web d'OpenClassrooms : développer le back-end d'un site web de présentation de fiches produits."
topics: ['TypeScript', 'ExpressJS', 'MongoDB', 'Backend', 'Bootcamp OC', 'Intermédiaire']
slug: "mon-vieux-grimoire-backend"
series: ["Mes projets réalisés en formation chez OpenClassrooms"]
series_order: 6
---

---

{{< lead >}}
Avant dernier projet du [**parcours de développeur web** d'_OpenClassrooms_,](https://openclassrooms.com/fr/paths/717-developpeur-web#?) Mon vieux grimoire consiste en **la réalisation d'un CRUD**.  

Faisons un **système d'inscription et d'authentification sécurisés**, puis un **système de création, lecture, modification et suppression de fiches produits**, et enfin des **_pentests_ sur notre _API_ !**
{{< /lead >}}

---

# Mon vieux grimoire

<div class="wpm blog-post-illustration-figure is-resized centered-figcaption">
{{< figure
    src="/img/oc-web-dev-bootcamp-projects-banners/mon-vieux-grimoire-openclassrooms.webp"
    alt="Bannière de Mon vieux grimoire"
    default=true
    loading="lazy"
>}}
</div>

## Résultat du projet

### Code source (GitHub)

{{< alert "circle-info" >}}
Cliquez sur l'encadré ci-dessous pour **accéder au code source de mon projet**.  
{{< /alert >}}
&nbsp;
{{< github repo="gustaveWPM/OC-Mon-Vieux-Grimoire#?" >}}

---

{{< alert >}}
**Ce projet N'A PAS et N'AURA PAS de démo mise en production !**  
Compte tenu du fait qu'il s'agit d'un projet **qu'il faudrait que je surveille et modère afin d'éviter de nombreux abus largement assez prévisibles**, et d'à quel point **il est simple de l'exécuter en local**, j'ai fait le choix de ne **jamais mettre en production ce projet.**
{{< /alert >}}

---

## Pistes pour la réalisation du projet

{{< alert >}}
**Je n'avais jamais écrit d'ExpressJS, ni utilisé _Mongoose_ avant de me lancer.**  
Néanmoins, je n'ai rien réalisé d'expérimental dans ce projet. 
{{< /alert >}}

**Afin de réaliser ce projet, il m'a fallu expérimenter avec l'écosystème de _TypeScript_.**  
Cela a comporté son lot d'essais et d'erreurs, et de choix que je me permettrai de détailler dans cet article.

---

{{< alert "circle-info" >}}
Avant de commencer à travailler, je vous recommande de comprendre (dans les grandes lignes) le fonctionnement d'ExpressJS.  
[:down_arrow: Vous trouverez en annexe une sélection de ressources pédagogiques](#liens-externes)
{{< /alert >}}

#### Avant de se lancer...

**Pour ce projet, je vous recommanderais d'utiliser [:link: Prettier](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode) pour automatiquement formater votre code.**  

{{< alert "circle-info" >}}
Si vous souhaitez me copier, **vous pouvez utiliser les mêmes fichiers de configuration _Prettier_ et _VSCode_ que moi.**  
[:link: Ma configuration Prettier]({{< ref "quirks/prettier" >}}#?)
{{< /alert >}}

**Pour la suite, vous pouvez également vous épauler d'une IA :**
- [:link: ChatGPT,](https://chat.openai.com)
- [:link: Perplexity,](https://perplexity.ai)
- [:link: GitHub Copilot,](https://github.com/features/copilot)
- ou autre outil IA de votre choix.

{{< alert >}}
**N'utilisez jamais du code que vous n'arrivez pas à raisonner !**  
N'hésitez pas à demander à votre agent conversationnel de reformuler sa réponse afin qu'elle soit plus simple, ou plus élégante, au moindre doute.
{{< /alert >}}
&nbsp;
{{< alert >}}
**Ne comptez JAMAIS sur une IA pour s'occuper de la sécurité de votre back-end à votre place !**  
_(Ça se passe de commentaires...)_
{{< /alert >}}

##### Faites du _TypeScript_ !

Voici deux des nombreux points qui font de _TypeScript_ un choix beaucoup plus intelligent que du _JavaScript_, surtout pour un projet de backend **qui se doit d'avoir une sécurité accrue** :
- _TypeScript_ **détecte les erreurs de typage lors de sa compilation**,
- _TypeScript_ **permet à votre éditeur de code d'être plus intelligent.**


---

## Suivez-moi !

### Rappels des contraintes (arbitraires) de l'exercice

- **Une fois qu'un livre a été noté par un utilisateur, il ne devient plus possible de changer la note de ce dernier**,
- **La note d'un livre ne peut aller que de 0 à 5.**

Nous sécuriserons notre back-end en conséquence.  

Autre contrainte : le backend doit impérativement se lancer sur le port `4000` de la machine.  
Le front-end fournit a été codé pour communiquer sur le port `4000`.

#### Lancer un serveur ExpressJS

##### Variables d'environnement

Les variables d'environnement offrent un moyen sécurisé de stocker des informations sensibles et spécifiques sans les inclure directement dans le code source.

**Vous manipulez quelque chose qui est _secret_ ?  
Vous devez utiliser une variable d'environnement !**

Quelques exemples de cas d'utilisation :
- Une clé API,
- Une clé de chiffrement,
- Un mot de passe...

Vous pourrez donc avoir un fichier `.env`, **que vous ne partagerez JAMAIS sur _GitHub_ ni ailleurs**, exception faite pour les personnes avec qui vous partagez ces dits _secrets_.

À tout hasard :
```env
# * ... Example .env file

ATLAS_USERNAME="john"
ATLAS_PASSWORD="doe"
ATLAS_CLUSTER_URI="clust0.wxcvbn123456789x.mongodb.net"
ATLAS_DB_NAME="my-shop"
TOKEN_SECRET="oEc5LA*JV#SZ!CGb2wU&KgWeG@s^"
```

La librairie [:link: Dotenv](https://www.npmjs.com/package/dotenv) vous permettra de **charger les informations de ce fichier `.env`** dans une variable globale de Node.js, [:link: `process.env`](https://nodejs.dev/fr/learn/how-to-read-environment-variables-from-nodejs/).

Comme cette variable est globale, **il ne vous suffira que d'appeler une seule fois l'importation de _Dotenv_ au début du flot d'exécution de votre code serveur** pour peupler `process.env` définitivement.

---

##### Configuration

Dans un fichier `Config/ServerConfig.ts` :

```ts
export namespace ServerConfig {
  export const PORT: string = '4000';
  export const IMAGES_FOLDER: string = 'images';
  export const IMAGES_FOLDER_RELATIVE_PATH_FROM_APP_CTX: string = `../../${IMAGES_FOLDER}`;

  export const UNKNOWN_ERROR = 'Erreur inconnue';
  /* ... */
}

export default ServerConfig;
```

Le port `4000` est imposé par ce projet.  

Le dossier `images/` est quant à lui présent au chemin `backend/images`.  
Mais mon fichier `app.ts` est quant à lui présent au chemin `backend/src/app`.

Comme c'est un chemin qui demande d'abord de revenir deux fois au dossier précédent, puis ensuite d'aller dans le dossier `images/`, j'ai donc écrit : `../../images`.

---

##### Instanciation

Nous aurons besoin de trois étapes pour instancier notre serveur :
- Un connecteur pour accéder à notre base de données sur [:link: Atlas,](https://www.mongodb.com/atlas/database)
- Un _binder_ pour injecter nos contrôleurs, ainsi que des autres _middlewares_ dont on pourrait avoir besoin,
- Un _getter_ pour essayer de créer l'instance de notre serveur, et nous la retourner si celle-ci a bien été créée avec succès.

###### Une piste pour le connecteur...

```ts
const { USERNAME, PASSWORD, CLUSTER_URI, DB_NAME } = AtlasConfig;
const URI = `mongodb+srv://${USERNAME}:${PASSWORD}@${CLUSTER_URI}/${DB_NAME}?retryWrites=true&w=majority`;

return mongoose
  .connect(URI)
  /* ... */
```

###### Une piste pour le _binder_...

```ts
const { AUTH_API_ROUTE, BOOKS_API_ROUTE } = ApiConfig;
app.use(AUTH_API_ROUTE, usersController);
app.use(BOOKS_API_ROUTE, booksController);

/* ... */

app.use((_: Request, res: Response, next: NextFunction) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content, Accept, Content-Type, Authorization');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS');
  next();
});
/* ... */
```

###### Le _Getter_ de l'instance

```ts
export async function getApp(): Promise<Express> {
  try {
    await tryToConnectToMongoDB();
    const app = express();
    appBinder(app);
    return app;
  } catch (error) {
    throw error;
  }
}
```

Si vous jetez un œil au [:link: fichier app.ts](https://github.com/gustaveWPM/OC-Mon-Vieux-Grimoire/blob/main/backend/src/app/app.ts) de mon projet, vous constaterez qu'il est extrêmement court. Il n'y a effectivement rien besoin de plus pour lancer un serveur ExpressJS.

{{< alert >}}
**Si vous voyez du code inutilement compliqué pour faire strictement la même chose, c'est tout simplement qu'il n'est pas à jour.**
{{< /alert >}}

---

**Pour des raisons _Legacy_ qui me sont propres**, j'ai fait le choix d'intégrer à la fois le _middleware_ pour pouvoir parser le _body_ de mes requêtes API en tant que _JSON_ ou en tant qu'_URL Encoded_.  

**Le parsing des _URL encodées_ pourrait tout à fait être ignoré.**

---

#### Créer des entités

_Mongoose_ est un _ORM_ qui permet de définir des _schémas_.

Par exemple :

```ts
import { Document, Schema, model } from 'mongoose';
import uniqueValidator from 'mongoose-unique-validator';

export interface UserDocument extends Document {
  email: string;
  password: string;
}

const userSchema: Schema = new Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true }
});

userSchema.plugin(uniqueValidator);
userSchema.index({ email: 'text' });

export default model<UserDocument>('User', userSchema);
```

Ce code est très simple à comprendre, et c'est toute la force de _Mongoose_.  
La seule subtilité à noter ici est **l'utilisation d'un _index_ sur le champ "email".** Cela permet de s'assurer que **la recherche en base de données d'un utilisateur grâce à son adresse email restera toujours rapide.**  

{{< alert >}}
Faites néanmoins attention avec les indexs de type `text`, car **ceux-ci peuvent devenir volumineux avec le nombre croissant de nouvelles entrées en base de données**.
{{< /alert >}}

##### Rajouter des contraintes sur nos entités

Les schémas _Mongoose_ ne sont pas juste des substituts à un typage que l'on ferait avec une simple interface _TypeScript_ (ici `UserDocument`).  

Je souhaiterais attirer l'attention sur deux propriétés des objets _Mongoose_ dans le cadre de ce projet :

- `min` et `max` permettent de définir une valeur minimale et maximale à un nombre (**intéressant pour notre système de notation de 0 à 5**),
- `validate` permet de mettre en place une logique de validation du champ (**extrêmement intéressant pour tous les petits cas épineux**).

À titre d'exemple, nous allons ici sécuriser les manipulations des _emails_ dans notre back-end.  
Il vous appartiendra de réfléchir à comment sécuriser les autres champs, bien que nous détaillerons aussi le cas de `year` en raison du fait qu'il s'agit d'un autre cas intéressant à creuser.

{{< alert "circle-info" >}}
L'avantage d'imposer des contraintes directement dans un modèle _Mongoose_ est que cela nous permettra **d'éviter de potentielles erreurs d'inattention** : il s'agit d'une vérification que l'on **délègue à l'_ORM_**, et donc à un **plus haut niveau d'abstraction**. Ce n'est pas une garantie absolue de sécurité, mais cela reste **une façon de faire que vous devriez privilégier dès lors que c'est possible**.
{{< /alert >}}

```ts
const userSchema: Schema = new Schema({
  email: {
    type: String,
    required: true,
    unique: true,
    validate: {
      validator: myEmailValidator,
      message: "Adresse email invalide: {VALUE} n'est pas une adresse email valide. Soit l'adresse email que vous avez entrée n'est pas une adresse email correcte, soit votre fournisseur d'adresse email est bloqué par notre système."
    }
  },

  password: { type: String, required: true }
});
```

Pour ce qui est de la fonction `myEmailValidator`, celle-ci ne peut prendre qu'un seul et unique argument (qui sera la valeur à valider).  

On peut partir sur quelque chose d'assez simple :

```ts
import { validate as emailValidator } from 'email-validator';

function isLowerCase(input: string): boolean {
  for (let i = 0; input[i]; i++) {
    if (input[i] !== input[i].toLowerCase()) {
      return false;
    }
  }
  return true;
}

function myEmailValidator(inputEmail: string): boolean {
  if (!isLowerCase(inputEmail)) {
    return false;
  }

  const isValid = emailValidator(inputEmail);
  return isValid;
}
```

J'en profite pour me forcer à ce que l'adresse email soit envoyée tout en minuscules à _Mongoose_, et ce pour être sûr que je ne ferai jamais l'erreur d'oublier un appel à `.toLowerCase()` sur les adresses emails que je dois enregistrer en base de données. **En effet, pour s'assurer au maximum de l'unicité des adresses emails, autant toujours les enregistrer sans aucun caractère majuscule pour les « Normaliser ».**

{{< alert >}}
Concernant les mots de passe : ils seront déjà validés, puis hashés, avant d'être transmis à _Mongoose_. **Il s'agit d'une fonctionnalité critique et l'utilisation d'un _hook_ de _Mongoose_ me paraissait trop _unsafe_ (et non standard).**  
**Pour des raisons de portabilité**, j'ai préféré redescendre d'un niveau d'abstraction.
{{< /alert >}}

## Services

### Sécuriser les mots de passe

Afin de sécuriser les mots de passe, nous allons faire deux choses :
- **Auditer le mot de passe choisi par l'utilisateur** pour le valider ou le rejeter (afin d'éliminer `1234`, `abcabcabc`...)
- **Hasher le mot de passe avant de le stocker en base de données**

#### Audit du mot de passe

Commençons par créer un _middleware_ pour **isoler la logique d'audit de mot de passe et la rendre réutilisable.**

```ts
import { NextFunction, Request, Response } from 'express';
// import zxcvbn, { ... } from 'zxcvbn';

function buildAndThrowFailedPasswordAuditErrorMsg(passwordAudit: Partial<ZXCVBNResult>) {
  let errorMsg = Config.TOO_SHORT_PASSWORD_ERROR;

  const feedback = (passwordAudit as ZXCVBNResult).feedback;
  if (!feedback) {
    throw new Error(errorMsg);
  }

  if (feedback.warning && feedback.warning.length > 0) {
    errorMsg += '\n';
    errorMsg += `ZXCVBN Feedback warning: ${feedback.warning}`;
  }

  if (feedback.suggestions && feedback.suggestions.length > 0) {
    errorMsg += '\n';
    errorMsg += `ZXCVBN Feedback suggestions: ${feedback.suggestions.join('\n')}\n`;
  }

  throw new Error(errorMsg);
}

function getPasswordAuditResult(inputPassword: string): Partial<ZXCVBNResult> {
  const notApprovedPasswordDefaultAuditValues = { score: 0 as ZXCVBNScore };
  if (inputPassword.length < Config.MIN_PASSWORD_LEN || inputPassword.length > Config.MAX_PASSWORD_LEN) {
    return notApprovedPasswordDefaultAuditValues;
  }

  const uniqCharsSet = new Set(inputPassword);
  if (uniqCharsSet.size < Config.MIN_PASSWORD_DIFFERENT_CHARS) {
    return notApprovedPasswordDefaultAuditValues;
  }

  let inputPasswordToTest = inputPassword;
  if (inputPassword.startsWith(PasswordsConfig.PASSWORD_EXAMPLE)) {
    inputPasswordToTest = inputPassword.substring(PasswordsConfig.PASSWORD_EXAMPLE.length);
  }

  const passwordAudit = zxcvbn(password);
  return passwordAudit;
}

export function auditPassword(req: Request, res: Response, next: NextFunction) {
  try {
    const { email, password: givenPassword } = req.body;
    const formattedEmail = tryToFormatEmail(email); // * ... Ma fonction interne qui va appliquer .trim().toLowerCase()

    const passwordAudit: Partial<ZXCVBNResult> = getPasswordAuditResult(givenPassword);
    if ((passwordAudit.score as ZXCVBNScore) < PasswordsConfig.MIN_ZXCVBN_SCORE) { // * ... Dans mon cas, MIN_ZXCVBN_SCORE vaut 3
      buildAndThrowFailedPasswordAuditErrorMsg(passwordAudit);
    }

    next();
  } catch (error) {
    printError(error);
    res.status(StatusCodes.INTERNAL_SERVER_ERROR).json(errorToObj(error));
  }
}

export default auditPassword;
```

**[:link: ZXCVBN](https://github.com/dropbox/zxcvbn) est une superbe librairie pour vérifier la qualité d'un choix de mot de passe**, que je vous conseille d'aller découvrir un peu plus en détails.  
Cette librairie standardise un **score de sécurité allant de 1 à 4**, et donne même **des conseils pour améliorer un mot de passe** lorsqu'il est détecté comme insuffisamment sécurisé.

#### Hash du mot de passe

Continuons avec un _middleware_ qui nous permettra d'**hasher le mot de passe.**

```ts
import { NextFunction, Request, Response } from 'express';
// import ServerConfig from '...';

const HASH_N = 10;

export async function hashPassword(req: Request, res: Response, next: NextFunction) {
  try {
    const { password: givenPassword } = req.body;
    const hashedPassword = await bcrypt.hash(givenPassword, HASH_N);

    if (!hashedPassword) {
      throw new Error(ServerConfig.UNKNOWN_ERROR);
    }
    req.body.password = hashedPassword;
    next();
  } catch (error) {
    printError(error);
    res.status(StatusCodes.INTERNAL_SERVER_ERROR).json(errorToObj(error));
  }
}
```

C'est aussi simple que ça. :tada:

---

Nous finirons enfin par un dernier middleware qui s'occupera de **l'enregistrement en base de données** du nouveau membre :
```ts
// import {...}

export async function userSignup(req: Request, res: Response) {
  try {
    const { email: formattedEmail, password: hashedPassword } = req.body;
    const user = new User({
      email: formattedEmail,
      password: hashedPassword
    });

    await user.save();
    res.status(StatusCodes.CREATED).json({ message: 'Utilisateur créé' });
  } catch (error) {
    printError(error);
    res.status(StatusCodes.INTERNAL_SERVER_ERROR).json(errorToObj(error));
  }
}
```

---

## Créer un contrôleur

```ts
import express, { Router } from 'express';
import { userLogin } from '../services/User';

import auditPassword from '../middlewares/usersManager/auditPassword';
import hashPassword from '../middlewares/usersManager/hashPassword';
import userSignup from '../middlewares/usersManager/userSignup';

const usersController: Router = express.Router();

usersController.post('/signup', auditPassword, hashPassword, userSignup);
// usersController.post('/login', userLogin);

export default usersController;
```

On observe ici la chaîne de _middlewares_ :
- `auditPassword`
  - `hashPassword`
    - `userSignup`

Cette chaîne a l'avantage d'être **très élégante et très modulable**.  
Ainsi, lorsqu'il faudrait rajouter une logique de changement de mot de passe, nous n'aurions qu'à faire :
- `auditPassword`
  - `hashPassword`
    - `userUpdate`

C'est pour cela que je souhaitais attirer votre attention là-dessus.  
Je pense qu'il s'agit d'un bon premier exemple afin de comprendre comment bien structurer ses _middlewares_ : **évitez le plus possible les monolithes**.  

À la place : **codez de petits middlewares indépendants, qui effectuent chacun leurs vérifications en interne afin de pouvoir les réutiliser de façon sécurisée n'importe où dans votre code.**

{{< alert >}}
**Ne partez jamais du principe qu'un _middleware_ sera forcément appelé après un autre, et donc de vous autoriser à omettre des vérifications.**  
Considérez chacun de vos _middlewares_ comme étant **autonome** !
{{< /alert >}}

### Sécuriser son CRUD

{{< wpm-wip >}}

## Pentest avec Burp Suite

### Tester son API

{{< wpm-wip >}}

### Tout casser

{{< wpm-wip >}}

---

## Annexes

### Captures d'écran

### Liens externes

{{< alert "circle-info" >}}
**Si vous êtes dév : il y a aussi quelques liens en bonus pour vous.**
{{< /alert >}}

{{< wpm-wip >}}
