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
    src="./assets/oc-web-dev-bootcamp-projects-banners/mon-vieux-grimoire-openclassrooms.webp"
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
**Je n'avais jamais écrit d'ExpressJS, ni utilisé Mongoose avant de me lancer.**  
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
      validator: emailValidator,
      message: emailValidatorMsg
    }
  },

  password: { type: String, required: true }
});
```

{{< alert >}}
Concernant les mots de passe : ils seront déjà validés, puis hashés, avant d'être transmis à Mongoose. **Il s'agit d'une fonctionnalité critique et l'utilisation d'un _hook_ de _Mongoose_ me paraissait trop _unsafe_.**  
Exceptionnellement, **j'ai préféré redescendre d'un niveau d'abstraction.**
{{< /alert >}}

#### Créer des contrôleurs

{{< wpm-wip >}}

## Services

### Sécuriser les mots de passe

{{< wpm-wip >}}

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
