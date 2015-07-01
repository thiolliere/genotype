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
