utilisation de hardon collider pour gérer les collisions 

utilisation de state manager pour les différents état du jeu :
	* menu arène (choix des arènes)
	* arène (spectateur ou joureur)
	
une arène est une carte avec des objets, des monstres, et de manière facultative des hommes.

la configuration se fait directement dans le dossier utilisateur.

est configurable : 
	* character.lua : script les actions d'un joueur
	* spectator.lua : script les actions d'un spectateur
	* interface.lua : script l'interface en jeu
	* le client pour choisir l'arène

ce que contient le $game (inchangeable)
	* les types d'objets : mur, projectile, chair ...
	* les armes : épée, bouclier, arc, ...
	* les déplacements possible
	
arène : 
	* l'arène est une carte qui contient des monstres, murs et humains, et des contraintes.
	* On peut créer différents type d'arène : par exemple
		* celles d'affrontement : contrainte : nombres , categories et positions initial des monstres
		chacun des adversaires place ses pions et sont character parfois.
		* celles d'exploration : contrainte : en fait les mêmes.
		sauf que la carte contient déja des monstres opposant à tout les partis 

important : la façon dont on place les monstres

comme les monstres doivent évoluer, il faut lors du lancement d'une arène 
que les monstres soient pris dans des populations, et à la fin de l'arène
on peut évaluer leur comportements. Ceci implique qu'ils soient déja bien 
entrainé car leurs progressions sera lente à priori.

les monstres doivent être entrainé dans des arènes petites confectionné
par vos soins et ou vous jouer les deux partis ou le seul s'il n'y en a 
qu'un.

dès qu'on tue un monstre dans une arène on a accès a son réseaux de 
neuronnes.

catégorie de monstre :
	la catégorie d'un monstre est calculé en fonction de ses attributs
comme les rapidité, l'endurance, les armes, la force ...

gestion des monstres : 
	chacun dispose de population de monstre : batch
	une batch contient : 
		type d'évolution
		parametre
	
	evaluation en fonction de l'arène comment garder une cohérence
	avec les autres évaluation ??
	mieux : on evalue et evolue que lors des testes en interne avec 
	donc des réglages adapté et des tests en séries.

	les individus auront un historique de leurs famille précis : 
		si par exemple on tue un très fort monstre : 
		on le multiplie pour en faire une population de 200
		et on evolue cette population --> inceste 
		il faut garder un trace.

	le gros probleme est quand on passe d'une évaluation à une autre, d'où 
	l'idée d'évoluer en interne sur de nombreux tests. Mais il peut etre possible
	de faire mieux, il faut pouvoir laisser le choix à l'utilisateur 
	de faire ce qu'il veut.

lorsqu'on lance une arène, qu'elle soit d'entrainement ou de défi, on choisis
les populations de monstres, et si on veut l'evaluation ainsi que les moments de
renouvellements (la mort d'un monstre - bien trop rapide, la dixième mort du monstre)

Les joueurs et les monstres sont des entités.
Une entités peut être dirigé en direct ou de manière scripté, en fait il n'y aura
aucune différence du point de vue des autres, les entités sont entièrement scriptable,
et les informations entièrement partagé.

en réalité il y a l'autorité qui recoit les actions des entités de chacun des partis.
il simule les actions et renvoie aux partis les informations qu'ils doivent recevoire.
les partis ne sont pas omniscient, chaque partis a un point de vue. il est possible à
deux partis de partagé leurs informations par le réseaux de la manière dont ils veulent.
Il existera peut être un moyen générique de le faire.

l'apprentissage automatique neat est une proposition. les comportements pouvant être
scripté comme bon leur semble.
Il y aura certainement des "abus" par exemple en transformant la chose en RTS, cela n'a
aucun impacte dans la mesure ou il s'agit de PVE - s'amuse qui voudra.

il faut donc definir : 
	* les actions possible d'une entité
	* les informations recueillies par une entité

il faudra ensuite définir les arènes, 

entité : 
	position : x, y
	deplacement : orientation, vitesse
	objet 2 main : épée+bouclier : épée, etat : "rangé","dégainé","attaque" + orientation,"defence" ...
	touché :"touché" : après avoir recu un coup est repoussé
		"normal" 
		"saigne"
		...

type d'objet : lance, épée+bouclier, hallebarde, arbalète, arc

ce qu'à l'utilisateur : un nombre d'entité, des actions pour chacunes, et des informations

chaque entité transmet des informations à une autre entité selon des conditions sur les
deux entités.

condition de distance + perception de l'informé : 
	si distance < perceptino alors envoye toutes les informations

condition de distance + perception partielle : position
	si distance < perception partielle alors envoye de la position

entité :
	forme :
	position : x, y
	vitesse : x, y
	acceleration : x, y
	+ objet en main et information sur l'objet
	+ etat : étourdit ... ce sont des modifications des caractéristique d'une entité
	comme la vitesse max, ...


pour les condition de visibilité :
une condition standard est la perception : 
si une entité est visible elle est rangé dans une grille,
les entités verronts les autre entités des case des grilles suivant
leur perception + pour toutes les entités invisible suivant leur condition de visibilité.

clients envoyent au serveur : actions :
	entité nommé truc fait cette fonction avec ces arguments
serveur envoyent aux teams : informations.
	entité nommé truc ici dans tel état

